//
//
import Foundation
import ApplicationsWrapper
import SQLite
import LocalConsole

let consoleManager = LCManager.shared

let concurrentUIBackgroundQueue = DispatchQueue(label: "it.concurrentUI", qos: .userInteractive, attributes: .concurrent)
let concurrentQueue = DispatchQueue(label: "it.concurrent", qos: .default, attributes: .concurrent)
let concurrentAppsQueue = DispatchQueue(label: "it.concurrent4sd", qos: .default, attributes: .concurrent)
let concurrentAppGroupsRetrieverQueue = DispatchQueue(label: "it.concurrent4", qos: .default, attributes: .concurrent)
let concurrentAppBundlesRetrieverQueue = DispatchQueue(label: "it.concurrent5", qos: .default, attributes: .concurrent)
let concurrentAppPluginsQueue = DispatchQueue(label: "it.concurrent56", qos: .default, attributes: .concurrent)
let concurrentDbShrinkingQueue = DispatchQueue(label: "it.dbShrinkingQueue", qos: .default, attributes: .concurrent)
let concurrentDeletionQueue = DispatchQueue(label: "it.concurrentDeletion", qos: .default, attributes: .concurrent)
let group = DispatchGroup()
let queue = OperationQueue()
//var c = 0
var totalErasableFiles = 0
var totalAppsCache: Int64 = 0
var appBundleListASF = appBundleList
var appBundleListCDA: [OrderedDictionary<String, AppInfo>] = []// = appBundleList
var appBundleListSAG: [OrderedDictionary<String, AppInfo>] = []
var appBundleListCBA: [OrderedDictionary<String, AppInfo>] = []
var languagesFilesCBA: [OrderedDictionary<String, langInfo>] = []
var languagesFilesCDA: [OrderedDictionary<String, langInfo>] = []
var languagesFilesSAG: [OrderedDictionary<String, langInfo>] = []
var languagesFilesSYS: [OrderedDictionary<String, langInfo>] = [[:]]

var undeterminedLanguagesFilesCBA: [OrderedDictionary<String, langInfo>] = []
var undeterminedLanguagesFilesCDA: [OrderedDictionary<String, langInfo>] = []
var undeterminedLanguagesFilesSAG: [OrderedDictionary<String, langInfo>] = []
var undeterminedLanguagesFilesSYS: [OrderedDictionary<String, langInfo>] = [[:]]

//var categoriesToProcess: [String : (files: [URL], hasFinishedDeletion: Bool)] = [:]

var totalSharedAppGroupErasablesSize: Int64 = 0
var totalCustomPathAppSpecificErasablesSize: Int64 = 0
var totalPluginsSize: Int64 = 0
var totalContainersDataSize: Int64 = 0

let numberOfContDataThreads = 4
let numberOfContBundleThreads = 6
let numberOfSAGThreads = 4
let numberOfDeletionThreads = 4

let currentLanguage = Locale.current.languageCode! //.preferredLanguages.first!

var AppLang: Int64 = 0
var contBundleLang: Int64 = 0
var contDataLang: Int64 = 0
var contSharedLang: Int64 = 0
var bytesCountedTwice: Int64 = 0
var excludedLanguagesSize: Int64 = 0
var isFirstScan = true

let DEBUGGING = false
//let DEBUGGING = false

public extension FileManager {    
    
    func getAppSharedGroups() {
            var appsInfoDatabaseURL = URL(fileURLWithPath: "/private/var/root/Library/MobileContainerManager/containers.sqlite3")
        if DEBUGGING {
            appsInfoDatabaseURL = URL(fileURLWithPath: "/private/var/mobile/Documents/D/containers.sqlite3")
        }
        
        //Makes a copy of the database which contains the correlation between appGroupContainers and app bundle's identifier to operate safely on it
        createTempDir()
        tempDBFolder.deleteAllContents()
        let dbCopyResult: (outcome: Int, safeDBURL: URL?) = copyDatabaseToTemporaryFolderV2(dbURL: appsInfoDatabaseURL)
        if dbCopyResult.outcome >= 0 {
            if let appDBsafe = dbCopyResult.safeDBURL {
                
                let db: Connection
                do {
                    db = try Connection(appDBsafe.path, readonly: true)
                } catch {
                    // consoleManager.print("Errore nella connessione al DB \(error)")
                    logArr.append("Errore nella connessione al DB \(error)")
                    return
                }
                
                // Forcing the database to terminate the last transaction by invoking a vacuum operation, otherwise it isn't readable
                do {
                    //            let x = try db.run("PRAGMA journal_mode=DELETE")
                } catch {
                    // consoleManager.print(error)
                    logArr.append(error.localizedDescription)
                }
                do {
                    //                    let x = try db.vacuum()
                    //                    db.interrupt()
                } catch {
                    print(error)
                    logArr.append(error.localizedDescription)
                }
                do {
                    //            let walStatementResult = try db.run("PRAGMA wal_checkpoint(truncate)")
                } catch {
                    // consoleManager.print(error)
                    logArr.append(error.localizedDescription)
                }
                
                do {
                    let appGroupsTable = Table("code_signing_data")
                    let appBundlesTable = Table("code_signing_info")
                    let bundle_id = Expression<Int>("id")
                    let cs_info_id = Expression<Int>("cs_info_id")
                    let bundleName = Expression<String>("code_signing_id_text")
                    let data_blob = Expression<SQLite.Blob?>("data") // Blob field is optional due to SQLite.Blob? - remove the ? to make it require "Not Null"
                    
                    //SELECT data, code_signing_id_text
                    //FROM code_signing_data
                    //INNER JOIN code_signing_info ON code_signing_info.id = code_signing_data.cs_info_id
                    let resultSet =  try db.prepare(appGroupsTable.select(data_blob, bundleName).join(appBundlesTable, on: appBundlesTable[bundle_id] == appGroupsTable[cs_info_id]).order(bundleName))
                    for result in resultSet {
                        let blobData = Data(result[data_blob]!.bytes)
                        var appBundle = result[bundleName]
                        
                        // Cast the blob data as a plist [String: [String:[String]]]
                        if let plist = try PropertyListSerialization.propertyList(from: blobData, options: [], format: nil) as? [String: Any] {
                            
                            // The entitlements key is where the app groups information is stored
                            if let entitlements = plist["com.apple.MobileContainerManager.Entitlements"] as? [String: Any] {
                                //                        let appDevIDAndBundle = entitlementsPlist["application-identifier"] as? String
                                //                        if let appDevID = entitlementsPlist["com.apple.developer.team-identifier"] as? String {
                                //                            if c >= 0 {
                                //                               // consoleManager.print(appBundle + "---" + appDevID)
                                //                                logArr.append(appBundle + "---" + appDevID)
                                //                                c += 1
                                //                            }
                                //                            // Some app bundles have their dev team ID suffix for some reason, this erases it
                                //                            if appBundle.hasPrefix(appDevID) {
                                //                                appBundle = String(appBundle.dropFirst(11)) // 11 because the dev team ID is 10 characters plus the final .
                                //                            }
                                //                        }
                                
//                                let appName = appBundleList[appBundle]
                                
                                //                                if appName == "Settings" {
                                //                                    consoleManager.print(entitlements)
                                //                                    //                                                                logArr.append(appBundle + "---" + appDevID)
                                //                                    c += 1
                                //                                }
                                
                                // Retrieving application group names and associating them to the app name
                                // blocca la view
                                if let appGroupsNames = entitlements["com.apple.security.application-groups"] as? [String] {
                                    //                                    if appName == "Find My" {
                                    //                                        print(entitlements)
                                    //                                    }
                                    //                                    if appName == "FindMy" {
                                    //                                        print(entitlements)
                                    //                                    }
//                                    print("NAME: \(appName) , BUNDLE: \(appBundle)")
                                    for group in appGroupsNames {
//                                        if appName != nil {
                                            print("group: \(group) : \(appBundle)")
                                            if group != nil {
                                                if appGroupList[group] == nil {
//                                                    appGroupList[group] = appName
                                                    appGroupList[group] = appBundle
                                                }
//                                            }
                                        } else {
                                            //                                    logArr.append("nome non trovato per " + appBundle)
                                            //                                                logArr.append(appBundle + "| G |" + group)
                                        }
                                    }
                                } else {
                                    print("Errore: application groups voice not found for: \(appBundle)")
                                }
                                
                                //                        // Retrieving application system group names and associating them to the app name
                                //                        if let appSysGroupsNames = entitlementsPlist["com.apple.security.system-group-containers"] as? [String] {
                                //                            for group in appSysGroupsNames {
                                //                                if !(appName == nil) {
                                //                                    appGroupList[group] = appName
                                //                                } else {
                                //                                    logArr.append("nome non trovato per " + appBundle)
                                //                                    logArr.append(appBundle + "| G |" + group)
                                //                                }
                                //                            }
                                //                        }
                                
                                //
                                //
                                //                                    if c > 15 {
                                //                                        break
                                //                                    }
                                //
                            } else {
                                print("Errore: entitlements voice not found in data blob for: \(appBundle)")
                                consoleManager.print("Errore: entitlements voice not found in data blob for: \(appBundle)")
                            }
                        } else {
                            print("Errore: the retrieved blob is not a plist")
                            consoleManager.print("Errore: the retrieved blob is not a plist")
                        }
                    }
                } catch {
                    // consoleManager.print(error)
                    print(error)
                    consoleManager.print(error)
                }
                
                for dbExt in sqlDBSupportingFilesExtension {
                    let pathToDelete = URL(fileURLWithPath: appDBsafe.path.appending(dbExt))
                    print(pathToDelete)
                    do {
                        try FileManager.default.removeItem(at: pathToDelete)
                    } catch {
                        print(error)
                    }
                }
                
            }
        } else {
            // consoleManager.print("Couldn't copy the \"\(appsInfoDatabaseURL.lastPathComponent)\" database to the temporary folder")
        }
    }
    
    func getAppInfoAndCustomPaths() { //(finished: () -> Void) {
        //        var totalCustomPathAppSpecificErasablesSize: Int64 = 0
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        
//        var appPaths: [URL] = [URL(fileURLWithPath: "/private/var/mobile/Documents/CBA"),
//        ]
        //                               ]
        //solo per test
//        for path in appPaths {
//            // We have to enumerate all directory contents, including subdirectories.
//            let rootEnumerator = self.enumerator(at: path,
//                                                 //                let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/provaContainersDataApp"),
//                                                 includingPropertiesForKeys: [],
//                                                 options: [.skipsSubdirectoryDescendants],
//                                                 //errorHandler: errorHandler)!
//                                                 errorHandler: nil)!
//            // We'll sum up content size here:
//
//            //                logArr.append(appBundleList.debugDescription)
//            // Perform the traversal.
//            for item in rootEnumerator {
//                let contentItemURL = item as! URL
//                appPaths.append(contentItemURL)
//            }
//        }
//        appPaths.append(URL(fileURLWithPath: "/private/var/mobile/Documents/A")
//        )
        //
        
        var appsPaths = [URL(fileURLWithPath: "/Applications/")]
        var rootUserAppsPath = URL(fileURLWithPath: "/private/var/containers/Bundle/Application/")
        if DEBUGGING {
            rootUserAppsPath = URL(fileURLWithPath: "/private/var/mobile/Documents/CBA/")
        }
        let rootEnumerator = self.enumerator(at: rootUserAppsPath,
                                                                                              includingPropertiesForKeys: [],
                                                                                              options: [.skipsSubdirectoryDescendants],
                                                                                              //errorHandler: errorHandler)!
                                                                                              errorHandler: nil)!
                                             //            // We'll sum up content size here:
                                             //
                                             //            //                logArr.append(appBundleList.debugDescription)
                                             //            // Perform the traversal.
                                                         for item in rootEnumerator {
                                                             let contentItemURL = item as! URL
                                                             appsPaths.append(contentItemURL)
                                                         }
        
        for path in appsPaths {
            // We have to enumerate all directory contents, including subdirectories.
            let rootEnumerator = self.enumerator(at: path,
                                                 //                let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/provaContainersDataApp"),
                                                 includingPropertiesForKeys: [],
                                                 options: [.skipsSubdirectoryDescendants],
                                                 //errorHandler: errorHandler)!
                                                 errorHandler: nil)!
            // We'll sum up content size here:
            
            //                logArr.append(appBundleList.debugDescription)
            // Perform the traversal.
            for item in rootEnumerator {
                
                
                
                // Bail out on errors from the errorHandler.
                //if enumeratorError != nil { break }
                
                // Add up individual file sizes.
                let contentItemURL = item as! URL
                //                if let app = contentItemURL.applicationItem {
                //                    // questo metodo ottiene il nome dell'app non dall'info plist cfbundledisplay, ad es. whatsapp cosi non ha la W iniziale come carattere speciale
                //                    let appName = app.localizedName()//.unaccent()
                var bundleID = ""
                
                var appName = ""
                if contentItemURL.path.hasSuffix(".app") {
                    let appPlist = contentItemURL.appendingPathComponent("Info.plist")
                    //                                            print("APP TROVATA")
                    do {
                        let infoPlistData = try Data(contentsOf: appPlist)
                        
                        if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                            //                                                    print(plist)
                            if contentItemURL.path.contains("Aliexpress") {
                                print(plist)
                            }
                            var appCurrentLanguagePlist = contentItemURL.appendingPathComponent("\(currentLanguage.before(first: "-")).lproj").appendingPathComponent("InfoPlist.strings")
                            if !fileExists(atPath: appCurrentLanguagePlist.path) {
                                appCurrentLanguagePlist = contentItemURL.appendingPathComponent("\(currentLanguage).lproj").appendingPathComponent("InfoPlist.strings")
                            }
                            do {
                                let infoPlistCurrentLanguageData = try Data(contentsOf: appCurrentLanguagePlist)
                                    
                                    if let CLPlist = try PropertyListSerialization.propertyList(from: infoPlistCurrentLanguageData, options: [], format: nil) as? [String: Any] {
                                        if let app = CLPlist["CFBundleDisplayName"] as? String {
                                            appName = app
                                        }
                                    }
                            } catch {
                                
                            }
                            if appName == "" {
                                    if let app = plist["CFBundleDisplayName"] as? String {
                                    appName = app
                                } else {
                                    if let bundleName = plist["CFBundleName"] as? String {
                                        appName = bundleName
                                    } else {
                                        appName = ((String)(contentItemURL.lastPathComponent.dropLast(4)))
                                        print("Nome app non trovato per: " + contentItemURL.lastPathComponent)
                                    }
                                }
                            }
                            if let ID = plist["CFBundleIdentifier"] as? String {
                                bundleID = ID
                                //                                    appBundleList[appUUID] = AppInfo(name: appName)
                            } else {
                                print("BUNDLE ID NON TROVATO")
                            }
                        } else {
                            print("Couldn't read Info.plist for \(contentItemURL.lastPathComponent.dropLast(4))")
                        }
                    } catch {
                        // consoleManager.print(error.localizedDescription)
                        print("Error reading Info.plist for \(contentItemURL.lastPathComponent.dropLast(4))")
                    }
                }
                
//                if appName == "" {
//                    //                        consoleManager.print("Nome app non trovato per: \(app.applicationIdentifier()), path:" + contentItemURL.path)
////                                            print("Nome app non trovato per: " + contentItemURL.lastPathComponent)
//                } else {
//                    print(appName)
//
//                }
                //                    if app.applicationIdentifier() == "" {
                //                        consoleManager.print("Bundle non trovato per: \(appName), path:" + contentItemURL.path)
                //                    }
                
                //                    logArr.append("          Analizzo " + appName)
                if !bundleID.isEmpty {
//                    appBundleList[bundleID].appName = appName
                    // Questo non funziona, ad es associa tutti i gruppi negli entitlements di siri (ovvero tutti i gruppi delle app apple) al nome app Siri
                    //                            if let sharedGroups = app.entitlements["com.apple.security.application-groups"] as? [String] {
                    //                                consoleManager.print("app: \(appName) group:")
                    //                                for group in sharedGroups {
                    //                                    consoleManager.print(group)
                    ////                                    appGroupList[group] = appName
                    //                                }
                    //                            } else {
                    //                                //                        logArr.append("++++++++++++++++++APP GROUP NOT CASTED FOR " + appName + "+++++++++++++++++++++++++++++")
                    //                            }
                    if appBundleList[bundleID] == nil { //se lancio la cancellazione di qualcosa prima che questa categoria ha terminato crasha: Thread 4: Fatal error: Index out of range ||||| bundleID:   "xyz.willy.Zebra" //app bundle list esiste è ordinato ed ha tutte le app, zebra esiste come chiave ma non esiste il suo valore, zebra è all'ultima posizione dell'array delle chiavi
                        //                        logArr.append("NO As " + appName)
                        if !DEBUGGING {
//                            if path == appsPaths.first {
                                if let app = contentItemURL.applicationItem {
                                    appBundleList[bundleID] = AppInfo(appName: appName, icon: ApplicationsManager.shared.icon(forApplication: app), isInstalled: true)
                                }
//                            } else {
//                                if let app = path.applicationItem {
//                                    appBundleList[appName] = AppInfo(icon: ApplicationsManager.shared.icon(forApplication: app), isInstalled: true)
//                                }
//                            }
                        } else {
                            appBundleList[bundleID] = AppInfo(appName: appName, isInstalled: true)
                        }
                    } else {
//                        if isFirstScan {
                            if !DEBUGGING {
                                if let app = contentItemURL.applicationItem {
                                    appBundleList[bundleID]!.icon = ApplicationsManager.shared.icon(forApplication: app)
                                }
                            }
                                appBundleList[bundleID]!.appName = appName
                                appBundleList[bundleID]!.isInstalled = true
                            //                                appBundleList[appName]?.icon = ApplicationsManager.shared.icon(forApplication: app)
//                        }
                        //                                else {
                        //                                    // Resetting calculated sizes for the new scans after the first one
                        //                                    appBundleList[appName]?.size = 0
                        //                                    for erasable in appBundleList[appName]?.erasables.keys {
                        //                                        appBundleList[appName]?.erasables[erasable]?.bytes = 0
                        //                                        appBundleList[appName]?.erasables[erasable]?.formatted = ""
                        //                                    }
                        //
                        //                                    for index in appBundleList[appName]?.appSpecificErasables.indices {
                        //                                        appBundleList[appName]?.appSpecificErasables[index].bytes = 0
                        //                                        appBundleList[appName]?.appSpecificErasables[index].formatted = ""
                        //                                    }
                        //
                        //                                    for plugin in appBundleList[appName]?.plugins.keys {
                        //                                        appBundleList[appName]?.plugins[plugin]?.bytes = 0
                        //                                        appBundleList[appName]?.plugins[plugin]?.formatted = ""
                        //                                    }
                        //                                }
                        
                    }
                }
                                else {
//                                    consoleManager.isVisible = true
                                    if !contentItemURL.path.hasSuffix(".plist") {
                                        consoleManager.print("Non è un'app: " + contentItemURL.path)
                                        print("Non è un'app: " + contentItemURL.path)
                                    }
                                }
            }
        }
    }
    
    func allocatedSizeOfApps() throws {//} -> Int64  {
        
        // Emptying appdbs for future scans
        appDatabases = [:]
        totalSharedAppGroupErasablesSize = 0
        totalPluginsSize = 0
        totalContainersDataSize = 0
        totalCustomPathAppSpecificErasablesSize = 0
        contDataLang = 0
        contBundleLang = 0
        contSharedLang = 0
        bytesCountedTwice = 0
        excludedLanguagesSize = 0
        
        //
        //        concurrentAppBundlesRetrieverQueue.async {
        //            group.wait()
        //                group.enter()
        consoleManager.print("✳️✳️✳️✳️getAppInfoAndCustomPaths STARTED")
        
        appSpecificFiles()
        getAppInfoAndCustomPaths()// { //se lancio la cancellazione di qualcosa prima che questa categoria ha terminato crasha: Thread 4: Fatal error: Index out of range
        //                group.leave()
        //        consoleManager.print("\(appBundleList.keys.caseInsensitiveSorted(.orderedAscending))")
        //        consoleManager.print("\(appBundleList.keys.caseInsensitiveSorted(.orderedAscending))")
//        print(appBundleList.keys.sorted(by: { $0 < $1 }))
//        print(appBundleList.sorted(by: { $0.0 < $1.0 }))
        consoleManager.print("🆘🆘🆘🆘getAppInfoAndCustomPaths FINISHED")
        //            }
        //        }
        
        //        var totalSharedAppGroupErasablesSize: Int64 = 0
        //        var totalCustomPathAppSpecificErasablesSize: Int64 = 0
        //        var totalPluginsSize: Int64 = 0
        //        var totalContainersDataSize: Int64 = 0
        
        //        concurrentAppBundlesRetrieverQueue.async (flags: .barrier) {
        //        concurrentAppBundlesRetrieverQueue.async {
        //            group.wait()
        //                group.enter()
        consoleManager.print("✳️✳️✳️✳️getAppSharedGroups STARTED")
        //fa bloccare la view
        self.getAppSharedGroups() //{
        //                group.leave()
        //        logArr.append("\(appGroupList.keys.sorted())")
        print(appGroupList["com.apple.mobilenotes"])
        print(appGroupList)
        consoleManager.print("🆘🆘🆘🆘getAppSharedGroups FINISHED")
        //            }
        //        }
        //        concurrentAppBundlesRetrieverQueue.async {
        //            group.wait()
        //            group.enter()
        consoleManager.print("✳️✳️✳️✳️allocatedSizes STARTED")
        
        appSpecificCustomPathDatabases()
        
        
        do {
            //funziona perfettament
            //            try totalContainersDataSize =
            self.allocatedSizeOfAllContainersDataApplication()
//            let formattedSize = ByteCountFormatter.string(fromByteCount: totalContainersDataSize, countStyle: .memory)
            // consoleManager.print(formattedSize)
        } catch {
            // consoleManager.print("RRRORE")
        }
        
        do {
            //            try totalPluginsSize =
            self.allocatedSizeOfAppsPlugins()
//            let formattedSize = ByteCountFormatter.string(fromByteCount: totalPluginsSize, countStyle: .memory)
            // consoleManager.print(formattedSize)
        } catch {
            // consoleManager.print("RRRORE")
        }
        
        
        //                }
        //                concurrentAppGroupsRetrieverQueue.async (flags: .barrier) {
        do {
            // fa crasgare
            //            try totalSharedAppGroupErasablesSize =
            self.allocatedSizeOfAllSharedAppGroup()
//            let formattedSize = ByteCountFormatter.string(fromByteCount: totalSharedAppGroupErasablesSize, countStyle: .memory)
            //            consoleManager.print(formattedSize)
        } catch {
            // consoleManager.print("RRRORE")
        }
        //        }
        //        }
        
        //        finished()
        //
        isFirstScan = false
        
        concurrentAppsQueue.async (flags: .barrier) {
            
            concurrentAppGroupsRetrieverQueue.async (flags: .barrier) {
                concurrentAppPluginsQueue.async (flags: .barrier) {
                    
                    let retrievedData2 = [appBundleListSAG, appBundleListCDA]
                    for listArr in retrievedData2 {
                        for list in listArr {
                            for key in list.keys {
                                if appBundleList[key] != nil {
                                    appBundleList[key]!.size += list[key]!.size
                                    
                                    // App Specific
                                    appBundleList[key]!.appSpecificErasablesSize += list[key]!.appSpecificErasablesSize
                                    for index in list[key]!.appSpecificErasables.indices {
                                        if list[key]!.appSpecificErasables[index].appPath != .custom {
//                                            if list[key]!.appSpecificErasables[index].appPath == .ContSharedApp || list[key]!.appSpecificErasables[index].appPath == .ContDataApp {
                                            appBundleList[key]!.appSpecificErasables[index].filesFound.append(contentsOf: list[key]!.appSpecificErasables[index].filesFound)
                                            appBundleList[key]!.appSpecificErasables[index].bytes += list[key]!.appSpecificErasables[index].bytes
                                            appBundleList[key]!.appSpecificErasablesSize += list[key]!.appSpecificErasablesSize
                                        }
                                    }
                                    
                                    for erasable in list[key]!.erasables {
                                        // If this type of erasable is already present in the appBundleList
                                        if appBundleList[key]!.erasables.keys.contains(erasable.key) {
                                            appBundleList[key]!.erasables[erasable.key]!.bytes += erasable.value.bytes
                                            appBundleList[key]!.erasables[erasable.key]!.filesFound += erasable.value.filesFound
                                            //                                appBundleList[key]!.erasables[erasable.key]!.isChecked = false
                                        } else {
                                            // This type of erasable must be created in the appBundleList
                                            appBundleList[key]!.erasables[erasable.key] = erasable.value
                                        }
                                    }
                                } else {
                                    appBundleList[key] = list[key]
                                }
                            }
                            
                        }
                        
                    }
                    
                    for key in appBundleListASF.keys {
                        if !(appBundleListASF[key]!.appSpecificErasables.isEmpty) {
                            appBundleList[key]!.appSpecificErasablesSize += appBundleListASF[key]!.appSpecificErasablesSize
                            appBundleList[key]!.size += appBundleListASF[key]!.size
                            for index in appBundleList[key]!.appSpecificErasables.indices {
                                if appBundleListASF[key]!.appSpecificErasables[index].appPath == .custom {
                                    appBundleList[key]!.appSpecificErasables[index].filesFound.append(contentsOf: appBundleListASF[key]!.appSpecificErasables[index].filesFound)
                                    appBundleList[key]!.appSpecificErasables[index].bytes += appBundleListASF[key]!.appSpecificErasables[index].bytes
                                    appBundleList[key]!.appSpecificErasablesSize += appBundleListASF[key]!.appSpecificErasablesSize
                                    //                            appBundleList[key]!.appSpecificErasables[index].formatted = appBundleList[key]!.appSpecificErasables[index].bytes.formatBytes()
                                }
                            }
                            for erasable in appBundleListASF[key]!.erasables {
                                // If this type of erasable is already present in the appBundleList
                                if appBundleList[key]!.erasables.keys.contains(erasable.key) {
                                    appBundleList[key]!.erasables[erasable.key]!.bytes += erasable.value.bytes
                                    //                            appBundleList[key]!.erasables[erasable.key]!.formatted = erasable.value.formatted
                                    appBundleList[key]!.erasables[erasable.key]!.filesFound += erasable.value.filesFound
                                    //                                appBundleList[key]!.erasables[erasable.key]!.isChecked = false
                                } else {
                                    // This type of erasable must be created in the appBundleList
                                    appBundleList[key]!.erasables[erasable.key] = erasable.value
                                }
                            }
                        }
                    }
                    
                    for list in appBundleListCBA {
                        for key in list.keys {
                            for plugin in list[key]!.plugins.keys {
                                // If this type of plugin is already present in the appBundleList
                                if (appBundleList[key]!.plugins[plugin] != nil) {
                                    appBundleList[key]!.plugins[plugin]!.bytes += list[key]!.plugins[plugin]!.bytes
                                    //                                appBundleList[key]!.plugins[plugin.key]!.isChecked = false
                                } else {
                                    // This type of plugin must be created in the appBundleList
                                    appBundleList[key]!.plugins[plugin] = list[key]!.plugins[plugin]
                                }
                            }
                        }
                    }
                    
                    for bundle in appBundleList.keys {
                        appBundleList[bundle]!.formattedSize = appBundleList[bundle]!.size.formatBytes()
                        for plugin in appBundleList[bundle]!.plugins.keys {
                            appBundleList[bundle]!.plugins[plugin]!.formatted = appBundleList[bundle]!.plugins[plugin]!.bytes.formatBytes()
                        }
                        for index in appBundleList[bundle]!.appSpecificErasables.indices {
                            appBundleList[bundle]!.appSpecificErasables[index].formatted = appBundleList[bundle]!.appSpecificErasables[index].bytes.formatBytes()
                        }
                        
                        for erasable in appBundleList[bundle]!.erasables.keys {
                            appBundleList[bundle]!.erasables[erasable]!.formatted = appBundleList[bundle]!.erasables[erasable]!.bytes.formatBytes()
                            
                        }
                    }
                    print("Finito di assemblare appBundleList")
                    print(appBundleList.keys)
                    let retrievedLanguages = [languagesFilesCDA, languagesFilesCBA, languagesFilesSAG, languagesFilesSYS]
                    for langArr in retrievedLanguages {
                        for langList in langArr {
                            for lang in langList.keys {
                                if languagesList[lang] == nil {
//                                    let x = langList[lang]!.name
                                    languagesList[lang] = langInfo(name: langList[lang]!.name)
                                }
                                languagesList[lang]!.foundFiles += langList[lang]!.foundFiles
                                languagesList[lang]!.size.bytes += langList[lang]!.size.bytes
                                //                    if languagesFiles[lang] == nil {
                                //                        languagesFiles[lang] = langList[lang]
                                //                    } else {
                                //                        languagesFiles[lang]! += langList[lang]!
                                //                    }
                            }
                        }
                    }
                    let retrievedUndeterminedLanguages = [undeterminedLanguagesFilesSAG, undeterminedLanguagesFilesCDA, undeterminedLanguagesFilesCBA, undeterminedLanguagesFilesSYS]
                    for langArr in retrievedUndeterminedLanguages {
                        for langList in langArr {
                            for lang in langList.keys {
                                if languagesList[lang] == nil {
                                    let x = langList[lang]!.name
                                    languagesList[lang] = langInfo(name: langList[lang]!.name)
                                }
                                languagesList[lang]!.foundFiles += langList[lang]!.foundFiles
                                languagesList[lang]!.size.bytes += langList[lang]!.size.bytes
                                //                    if languagesFiles[lang] == nil {
                                //                        languagesFiles[lang] = langList[lang]
                                //                    } else {
                                //                        languagesFiles[lang]! += langList[lang]!
                                //                    }
                            }
                        }
                    }
                    // Excluding user languages
                    let possibleDeviceLanguagesReferences: [[String]?] = [Locale.preferredLanguages, [Locale.current.regionCode ?? "", Locale.current.languageCode ?? "", Locale.current.identifier], UserDefaults.standard.stringArray(forKey: "AppleLanguages")] //TEST ,[""], []]
                    for langArray in possibleDeviceLanguagesReferences {
                        for languageCode in langArray ?? [] {
                            let lang = languageCode.lowercased()
                            print("found user language: \(lang)")
                            if languagesList[lang] != nil {
                                print("removing user lang: \(lang)")
                                excludedLanguagesSize += languagesList[lang]!.size.bytes
                                languagesList.removeValue(forKey: lang)
                            }
                            if let code = lang.components(separatedBy: ["-","_"]).first {
                                if languagesList[code] != nil {
                                    print("removing user lang: \(code)")
                                    excludedLanguagesSize += languagesList[code]!.size.bytes
                                    languagesList.removeValue(forKey: code)
                                }
                                
                                for key in languagesList.keys {
                                    if let keyLangCode = key.components(separatedBy: ["-","_"]).first {
                                        if keyLangCode == code {
                                            excludedLanguagesSize += languagesList[key]!.size.bytes
                                            languagesList.removeValue(forKey: key)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Excluding English
                    for key in languagesList.keys {
                        if let keyLangCode = key.components(separatedBy: ["-","_"]).first {
                            if keyLangCode == "en" {
                                excludedLanguagesSize += languagesList[key]!.size.bytes
                                languagesList.removeValue(forKey: key)
                            }
                        }
                    }
                    
                    // Excluding Base
                    if languagesList["base"] != nil {
                        excludedLanguagesSize += languagesList["base"]!.size.bytes
                        languagesList.removeValue(forKey: "base")
                    }
                    
                    for lang in languagesList.keys {
                        print(lang)
                        languagesList[lang]!.size.formatted = languagesList[lang]!.size.bytes.formatBytes()
                    }
                    print("Dimensione totalSharedAppGroupErasablesSize2: " + totalSharedAppGroupErasablesSize.formatBytes())
                    print("Dimensione totalPluginsSize2: " + totalPluginsSize.formatBytes())
                    print("Dimensione totalContainersDataSize2: " + totalContainersDataSize.formatBytes())
                    print("Dimensione totalCustomPathAppSpecificErasablesSize2: " + totalCustomPathAppSpecificErasablesSize.formatBytes())
                    let langSize = ((contDataLang + contBundleLang + contSharedLang - excludedLanguagesSize))
                    print("Dimensione langSize2: " + langSize.formatBytes())
                    print("Dimensione bytesCountedTwice2: " + bytesCountedTwice.formatBytes())
                    totalAppsCache = totalSharedAppGroupErasablesSize + totalContainersDataSize// + totalPluginsSize// + totalCustomPathAppSpecificErasablesSize
                    print("Dimensione totalAppsCache2: " + totalAppsCache.formatBytes())
                    //                    languages.sort()
                    print(languagesList.keys)
                    print("app plugins finito")
                    
                    var xx:Int64 = 0
                    for app in appBundleList.values {
                        xx += app.size
                    }
                    print("Dimensione app xx2: " + xx.formatBytes())
                }
            }
            
            //            languagesFilesCBA = [:]
            //            languagesFilesCDA = [:]
            //            languagesFilesSAG = [:]
            
//            print("Dimensione totalSharedAppGroupErasablesSize: " + totalSharedAppGroupErasablesSize.formatBytes())
//            print("Dimensione totalPluginsSize: " + totalPluginsSize.formatBytes())
//            print("Dimensione totalContainersDataSize: " + totalContainersDataSize.formatBytes())
//            print("Dimensione totalCustomPathAppSpecificErasablesSize: " + totalCustomPathAppSpecificErasablesSize.formatBytes())
//            let langSize = ((contDataLang + contBundleLang + contSharedLang - excludedLanguagesSize))
//            print("Dimensione langSize: " + langSize.formatBytes())
//            print("Dimensione bytesCountedTwice: " + bytesCountedTwice.formatBytes())
//            totalAppsCache = totalSharedAppGroupErasablesSize + totalPluginsSize + totalContainersDataSize// + totalCustomPathAppSpecificErasablesSize //+ langSize - bytesCountedTwice
//            print("Dimensione totalAppsCache: " + totalAppsCache.formatBytes())
//            print("Dimensione totalAppsCache: " + totalAppsCache.formatBytes())
//            print(languagesList.keys)
            
            var xx:Int64 = 0
            for app in appBundleList.values {
                xx += app.size
            }
            print("Dimensione app xx: " + xx.formatBytes())
        }
        //        return totalCustomPathAppSpecificErasablesSize
        //        return totalSharedAppGroupErasablesSize + totalPluginsSize + totalContainersDataSize + totalCustomPathAppSpecificErasablesSize
    }
    
    func appSpecificFiles() {
        // Custom app specific paths
        concurrentAppsQueue.async {
            appBundleListASF = appBundleList
            for bundleID in appBundleList.keys {
                if !(appBundleListASF[bundleID]!.appSpecificErasables.isEmpty) {
                    //                                logArr.append("------------------------------App specific trovata per" + appName)
                    //                                logArr.append("step 1")
                    for index in appBundleListASF[bundleID]!.appSpecificErasables.indices {
                        //                                    logArr.append("step 2")
                        if appBundleListASF[bundleID]!.appSpecificErasables[index].appPath == .custom {
                            //                                        logArr.append("step 3")
                            for path in appBundleListASF[bundleID]!.appSpecificErasables[index].subPaths {
                                //                                            logArr.append("step 4")
                                let customPathEnumerator = self.enumerator(at: URL(fileURLWithPath: path),
                                                                           includingPropertiesForKeys: [],
                                                                           options: [],
                                                                           //errorHandler: errorHandler)!
                                                                           errorHandler: nil)!
                                // We'll sum up content size here:
                                var erasableFileSize: Int64 = 0
                                // Perform the traversal.
                            filesLoop: for item in customPathEnumerator {
                                // Bail out on errors from the errorHandler.
                                //if enumeratorError != nil { break }
                                
                                // Add up individual file sizes.
                                let contentItemURL = item as! URL
                                //logArr.append(contentItemURL.description)
                                if appBundleListASF[bundleID]!.appSpecificErasables[index].fileNameContains.isEmpty { //if no filename regex is specified, delete the whole folder
                                    //                                                logArr.append("step 5")
                                    if !appBundleListASF[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                        for fileExt in appBundleListASF[bundleID]!.appSpecificErasables[index].fileExtensions {
                                            if contentItemURL.path.hasSuffix(fileExt) {
                                                do {
                                                    erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                                    //totalErasableFiles += 1
                                                } catch {
                                                    // consoleManager.print(error)
                                                }
                                                if let type = appBundleListASF[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListASF[bundleID]!.size += erasableFileSize
                                                if appBundleListASF[bundleID]!.erasables[type] == nil {
                                                    appBundleListASF[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListASF[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListASF[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                } else {
                                                    totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                    appBundleListASF[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                    appBundleListASF[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                    appBundleListASF[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                }
                                                //                                                            appBundleList[appName]?.size += erasableFileSize
                                                //                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                //                                                                logArr.append("\(erasableFileSize)")
                                                //                                                                logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                                //logArr.append(contentItemURL.description)
                                                continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                            }
                                        }
                                    } else { // If no extension is specified
                                        //                                                    logArr.append("step 6")
                                        do {
                                            erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                            //totalErasableFiles += 1
                                        } catch {
                                            // consoleManager.print(error)
                                        }
                                        if let type = appBundleListASF[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListASF[bundleID]!.size += erasableFileSize
                                                if appBundleListASF[bundleID]!.erasables[type] == nil {
                                                    appBundleListASF[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListASF[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListASF[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                        } else {
                                            totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                            appBundleListASF[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                            appBundleListASF[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                            appBundleListASF[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                        }
                                        //                                                    appBundleList[appName]?.size += erasableFileSize
                                        //                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                        //                                                        logArr.append("\(erasableFileSize)")
                                        //                                                        logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                        //logArr.append(contentItemURL.description)
                                        continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                    }
                                }
                                for nameSubString in appBundleListASF[bundleID]!.appSpecificErasables[index].fileNameContains {
                                    if contentItemURL.path.contains(nameSubString) {
                                        if !appBundleListASF[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                            //                                                        logArr.append("step 7")
                                            for fileExt in appBundleListASF[bundleID]!.appSpecificErasables[index].fileExtensions {
                                                if contentItemURL.path.hasSuffix(fileExt) {
                                                    do {
                                                        erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                                        //totalErasableFiles += 1
                                                    } catch {
                                                        // consoleManager.print(error)
                                                    }
                                                    if let type = appBundleListASF[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListASF[bundleID]!.size += erasableFileSize
                                                if appBundleListASF[bundleID]!.erasables[type] == nil {
                                                    appBundleListASF[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListASF[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListASF[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                    } else {
                                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                        appBundleListASF[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                        appBundleListASF[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                        appBundleListASF[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                    }
                                                    //                                                                appBundleList[appName]?.size += erasableFileSize
                                                    //                                                    totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                    //                                                                logArr.append("\(erasableFileSize)")
                                                    //                                                                logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                                    //logArr.append(contentItemURL.description)
                                                    continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                                }
                                            }
                                        } else { // If no extension is specified
                                            //                                                        logArr.append("step 8")
                                            do {
                                                erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                                //totalErasableFiles += 1
                                            } catch {
                                                // consoleManager.print(error)
                                            }
                                            if let type = appBundleListASF[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListASF[bundleID]!.size += erasableFileSize
                                                if appBundleListASF[bundleID]!.erasables[type] == nil {
                                                    appBundleListASF[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListASF[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListASF[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                            } else {
                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                appBundleListASF[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                appBundleListASF[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                appBundleListASF[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            }
                                            //                                                        appBundleList[appName]?.size += erasableFileSize
                                            //                                            totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                            //                                                        logArr.append("\(erasableFileSize)")
                                            //                                                        logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                            //logArr.append(contentItemURL.description)
                                            continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                        }
                                    }
                                }
                            }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func appSpecificCustomPathDatabases() {
        for appName in appSpecificDatabases.keys {
            for index in appSpecificDatabases[appName]!.indices {
                if appSpecificDatabases[appName]?[index].dbPathType == .custom {
                    if appSpecificDatabases[appName]![index].fileNameContains.isEmpty {
                        // No filename specified, so the path points at the file
                        let dbName = appSpecificDatabases[appName]![index].db.name
                        for dbPath in appSpecificDatabases[appName]![index].db.paths {
                        var db = Database(name: dbName, paths: [dbPath])
                        //                            appDatabases[appName]!.dbs[index].db.paths = [contentItemURL.path]
//                        print("🟪3🟪🟪 compressing" + pathStr)
                        // Move db into shrinking folder
                        concurrentDbShrinkingQueue.async {
                            //                                var maxIndex = appDatabases[appName]?.count - 1
                            //                                print("concurrent db shrinking 1, max index: \(maxIndex), current index: \(index)")
                            shrinkDatabase(&db)
                        }
                            concurrentDbShrinkingQueue.async(flags: .barrier) {
                                if db.canBeShrinked {
                                    //                                    print(appDatabases[appName]!.dbs[index])
                                    if appDatabases[appName] == nil {
                                        appDatabases[appName] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                                    } else {
                                        appDatabases[appName]!.dbs.append(db)
                                        appDatabases[appName]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                                    }
                                    //                                    appDatabases[appName]!.dbs[index].db.size = db.size
                                    //                                    appDatabases[appName]!.dbs[index].db.shrinkedSize = db.shrinkedSize
                                    //                                    appDatabases[appName]!.dbs[index].db.spaceFreed = db.spaceFreed
                                    //                                        appDatabases[appName]!.dbs[index].db.canBeShrinked = db.canBeShrinked
                                    //                                        appDatabases[appName]!.dbs[index].db.paths = [pathStr]
                                } else {
                                    // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                    //                                    appDatabases[appName]!.dbs.remove(at: index)
                                    //quando lo rimuovo l'indice cambia
                                    // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                    if !(appDatabases[appName] == nil) {
                                        for index in appDatabases[appName]!.dbs.indices {
                                            if dbName == appDatabases[appName]!.dbs[index].name {
                                                appDatabases[appName]!.dbs.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                    outerLoop: for dbPath in appSpecificDatabases[appName]![index].db.paths {
                            let folderEnumerator = self.enumerator(at: URL(fileURLWithPath:dbPath),
                                                                   //                let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/provaContainersDataApp"),
                                                                   includingPropertiesForKeys: [],
                                                                   options: [],
                                                                   //errorHandler: errorHandler)!
                                                                   errorHandler: nil)!
                            // We'll sum up content size here:
                            
                            //                logArr.append(appBundleList.debugDescription)
                            // Perform the traversal.
                            for item in folderEnumerator {
                                let contentItemURL = item as! URL
                                for nameSubString in appSpecificDatabases[appName]![index].fileNameContains {
                                    if contentItemURL.path.hasSuffix(nameSubString) {
                                        // deve essere reso thread safe
                                        let dbName = appSpecificDatabases[appName]![index].db.name
                                        var db = Database(name: dbName, paths: [contentItemURL.path])
                                        //                            appDatabases[appName]!.dbs[index].db.paths = [contentItemURL.path]
                                        // Move db into shrinking folder
                                        concurrentDbShrinkingQueue.async {
                                            //                                var maxIndex = appDatabases[appName]?.count - 1
                                            //                                print("concurrent db shrinking 1, max index: \(maxIndex), current index: \(index)")
                                            shrinkDatabase(&db)
                                        }
                                        concurrentDbShrinkingQueue.async(flags: .barrier) {
                                            if db.canBeShrinked {
                                                //                                    print(appDatabases[appName]!.dbs[index])
                                                if appDatabases[appName] == nil {
                                                    appDatabases[appName] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                                                } else {
                                                    appDatabases[appName]!.dbs.append(db)
                                                    appDatabases[appName]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                                                }
                                                //                                    appDatabases[appName]!.dbs[index].db.size = db.size
                                                //                                    appDatabases[appName]!.dbs[index].db.shrinkedSize = db.shrinkedSize
                                                //                                    appDatabases[appName]!.dbs[index].db.spaceFreed = db.spaceFreed
                                                //                                        appDatabases[appName]!.dbs[index].db.canBeShrinked = db.canBeShrinked
                                                //                                        appDatabases[appName]!.dbs[index].db.paths = [pathStr]
                                            } else {
                                                // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                                //                                    appDatabases[appName]!.dbs.remove(at: index)
                                                //quando lo rimuovo l'indice cambia
                                                // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                                if !(appDatabases[appName] == nil) {
                                                    for index in appDatabases[appName]!.dbs.indices {
                                                        if dbName == appDatabases[appName]!.dbs[index].name {
                                                            appDatabases[appName]!.dbs.remove(at: index)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        continue outerLoop
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func allocatedSizeOfAllSharedAppGroup() -> Int64  {
        concurrentAppsQueue.async {
            // The error handler simply stores the error and stops traversal
            var enumeratorError: Error? = nil
            func errorHandler(url: URL, error: Error) -> Bool {
                enumeratorError = error
                logArr.append(url.description)
                logArr.append(error.localizedDescription)
                return false
            }
            // We have to enumerate all directory contents, including subdirectories.
                        let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Containers/Shared/AppGroup"),
//            let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/CSA"),
                                                 includingPropertiesForKeys: [],
                                                 options: [.skipsSubdirectoryDescendants],
                                                 //errorHandler: errorHandler)!
                                                 errorHandler: nil)!
            // We'll sum up content size here:
            //            var totalSharedAppGroupErasablesSize: Int64 = 0
            //            appBundleListSAG = appBundleList
            //            appBundleListSAG.sort()
            //            print(appBundleListSAG.keys)
            let appFolders = rootEnumerator.allObjects
            // Chunk size
            let numberOfElementsPerThread = appFolders.count / numberOfSAGThreads
            let extraLastElement = appFolders.count - numberOfElementsPerThread * numberOfSAGThreads  // i.e. remainder
            if !appFolders.isEmpty {
                for op in 0..<numberOfSAGThreads {
                    //                concurrentAppsQueue.async {
                    concurrentAppGroupsRetrieverQueue.async {
                        var start = op * numberOfElementsPerThread
                        var end = start + numberOfElementsPerThread - 1
                        if (op == numberOfSAGThreads - 1) {
                            end = appFolders.count - 1
                        }
                        print("thread: \(op) start: \(start) end: \(end)")
                        var appBundleListSAG2 = appBundleList
                        var languagesFilesSAG2 = languagesList
                        var undeterminedLanguages: OrderedDictionary<String, langInfo> = [:]
                        for item in appFolders[start..<end] {
                            // Bail out on errors from the errorHandler.
                            //if enumeratorError != nil { break }
                            
                            // Add up individual file sizes.
                            let contentItemURL = item as! URL
                            
                            let appUUID = contentItemURL.lastPathComponent
                            do {
                                try totalSharedAppGroupErasablesSize += self.allocatedSizeOfSharedAppGroup(at: contentItemURL, appBundleList: &appBundleListSAG2, foundLanguages: &languagesFilesSAG2, undeterminedLanguages: &undeterminedLanguages)
                            } catch {
                                logArr.append("Errore nel calcolo shared AppGroup per \(contentItemURL.path)")
                                // consoleManager.print("errore 21: \(error)")
                            }
                        }
                        appBundleListSAG.append(appBundleListSAG2)
                        languagesFilesSAG.append(languagesFilesSAG2)
                        undeterminedLanguagesFilesSAG.append(languagesFilesSAG2)
                        if (op == numberOfSAGThreads - 1) {
                            print("🟨🟨🟨APP SHARED GROUP ANALYZED")
                            print(totalSharedAppGroupErasablesSize.formatBytes())
                        }
                    }
                }
            }
            //            var cc
            //        logArr.append("🟨🟨🟨\(cc)")
            //ricostruzione del risultato dei thread
            //            if foundDatabases[appName] == nil {
            //                foundDatabases[appName] = Array<appDatabase>([(appDatabase(db: db, fileNameContains: []))])
            //            } else {
            //                foundDatabases[appName]!.append(appDatabase(db: db, fileNameContains: []))
            //                dbIndex = foundDatabases[appName]!.count - 1
            //            }
            
            //            for app in appBundleListSAG.keys {
            //                appBundleList[app]!.size += appBundleListSAG[app]!.size
            //                for erasable in appBundleListSAG[app]!.erasables.keys {
            //                    if appBundleList[app]!.erasables[erasable] != nil {
            //                        appBundleList[app]!.erasables[erasable]?.bytes += appBundleListSAG[app]!.erasables[erasable]!.bytes
            //                    } else {
            //                        appBundleList[app]!.erasables[erasable] = appBundleListSAG[app]!.erasables[erasable]
            //                    }
            //                }
            //            }
        }
        return totalSharedAppGroupErasablesSize
    }
    
    // internal per langInfo
    internal func allocatedSizeOfSharedAppGroup(at appFolderURL: URL, appBundleList: inout OrderedDictionary<String, AppInfo>, foundLanguages: inout OrderedDictionary<String, langInfo>, undeterminedLanguages: inout OrderedDictionary<String, langInfo>) throws -> Int64  {
        //        let appGroupUUID = appFolderURL.lastPathComponent
        var bundleID: String = ""
        var foundDatabases: [appDatabase] = []
        let appPlist = appFolderURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
        do {
            let infoPlistData = try Data(contentsOf: appPlist)
            
            if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                if let appGroupName = plist["MCMMetadataIdentifier"] as? String {
                    if appGroupName == "" {
                        logArr.append("ERRORE 17 groupname vuoto")
                        return 0
                    }
                    //                    if appGroupName.contains("hatsapp") {
                    //                        print("trovat")
                    //                    }
                    if let app = appGroupList[appGroupName] {
                        bundleID = app
                        //                        if appName.contains("WhatsApp") {
                        //                            print("trovat")
                        //                        }
                        //                        if appName.contains("WhatsApp") { //special w
                        //                            print("trovat")
                        //                        }
                        //
                        //                            if appFolderURL.path.contains("5F8628E5-27F5-488C-8AB2-A8A18AEE2E02") {
                        //                                logArr.append(plist.description)
                        //                                logArr.append("🟨🟨🟨 group name:" + appGroupName + " nome:" + appName)
                        //                            }
                    } else {
                        print("Errore 5: \(appGroupName)")
                        return 0
                    }
                    //                    appGroupList[appGroupName] = AppGroupInfo(uuid: appGroupUUID)
                } else {
                    logArr.append("Errore 6")
                    return 0
                }
            } else {
                logArr.append("Errore 7")
                return 0
            }
        } catch {
            logArr.append("Errore 8")
            // consoleManager.print(error.localizedDescription)
            return 0
        }
        print("SharedAppGroup per " + bundleID)
        if bundleID == "ph.telegra.Telegraph" {
            print("trovato")
        }
        
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            //            logArr.append(url.description)
            //            logArr.append(error.localizedDescription)
            return false
        }
        var erasableFileSize: Int64 = 0
        var totalGroupErasablesSize: Int64 = 0
        // We have to enumerate all directory contents, including subdirectories.
        let folderFilesEnumerator = self.enumerator(at: appFolderURL,
                                                    includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                    options: [],
                                                    //errorHandler: errorHandler)!
                                                    errorHandler: nil)!
        // Perform the traversal.
    fileTraversal2: for item in folderFilesEnumerator {
        // Bail out on errors from the errorHandler.
        //if enumeratorError != nil { break }
        // Add up individual file sizes.
        let contentItemURL = item as! URL
        let pathStr = contentItemURL.path
        let start = pathStr.index(pathStr.startIndex, offsetBy: appFolderURL.path.count)
        let relativePath = contentItemURL.path[start...]
        for erasable in AppGroupsErasables {
            for nameSubString in erasable.fileNameContains {
                if relativePath.contains(nameSubString) {
                    erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                    //totalErasableFiles += 1
                    if appBundleList[bundleID]?.erasables[erasable.name] != nil {
                        appBundleList[bundleID]!.erasables[erasable.name]?.bytes += erasableFileSize
                        appBundleList[bundleID]!.erasables[erasable.name]?.filesFound.append(contentItemURL)
                    } else {
                        appBundleList[bundleID]?.erasables[erasable.name] = erasableData(bytes: erasableFileSize, filesFound: [contentItemURL])
                    }
                    appBundleList[bundleID]?.size += erasableFileSize
                    totalGroupErasablesSize += erasableFileSize
                    continue fileTraversal2 // If the current file matches a plugin, there is no need to check if it belongs to another plugin
                }
            }
        }
        
        //FA CRASHARE
        // If the file does not match an erasable category parameters check if it matches an app specific parameter
        //prova
        if appBundleList[bundleID] != nil { // con questo non dovrebbe crashare piu
            if !(appBundleList[bundleID]!.appSpecificErasables.isEmpty) {  //Thread 5: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            //appName = "Weather", disinstallata ma non eliminata
            // altra volta con bundleID =   "com.spotify.client.imessage"
            for index in appBundleList[bundleID]!.appSpecificErasables.indices {
                if appBundleList[bundleID]?.appSpecificErasables[index].appPath == .ContSharedApp {
                    //                    logArr.append("Ⓜ️Ⓜ️Ⓜ️Ⓜ️checking app specific for app " + appName)
                    //                if appName == "Notes" {
                    //                    logArr.append("Ⓜ️ Analyzing" + contentItemURL.path)
                    //                }
                    for subpath in appBundleList[bundleID]!.appSpecificErasables[index].subPaths {
                        if relativePath.contains(subpath) {
                            //                                                    if appName == "Notes" {
                            //                                                        logArr.append("Ⓜ️Ⓜ️Ⓜ️Ⓜ️Ⓜ️Ⓜ️Ⓜ️Ⓜ️ match for app " + appName)
                            //                                                    }
                            //                        if debug {
                            ////                            logArr.append("Ⓜ️Ⓜ️Ⓜ️Ⓜ️match for app " + appName)
                            //                        }
                            if appBundleList[bundleID]!.appSpecificErasables[index].fileNameContains.isEmpty {
                                if appBundleList[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                    // If no extension is specified
                                    //                                if debug {
                                    //                                    logArr.append("match 1")
                                    //                                }
                                    erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                    //totalErasableFiles += 1
                                    
                                                                                if let type = appBundleList[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleList[bundleID]!.size += erasableFileSize
                                                if appBundleList[bundleID]!.erasables[type] == nil {
                                                    appBundleList[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleList[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleList[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                        totalGroupErasablesSize += erasableFileSize
                                    } else {
                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                        appBundleList[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                        appBundleList[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                        appBundleList[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                    }
                                    //                                    appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                    //                                    appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                    //                                    appBundleList[appName]?.size += erasableFileSize
                                    //                                    totalGroupErasablesSize += erasableFileSize
                                    //                                break
                                    //logArr.append(contentItemURL.description)
                                    continue fileTraversal2 // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                }
                                else {
                                    //if there are extensions
                                    for fileExt in appBundleList[bundleID]!.appSpecificErasables[index].fileExtensions {
                                        if relativePath.hasSuffix(fileExt) {
                                            //                                        if debug {
                                            //                                            logArr.append("match 2")
                                            //                                        }
                                            erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                            //totalErasableFiles += 1
                                            
                                                                                        if let type = appBundleList[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleList[bundleID]!.size += erasableFileSize
                                                if appBundleList[bundleID]!.erasables[type] == nil {
                                                    appBundleList[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleList[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleList[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                totalGroupErasablesSize += erasableFileSize
                                            } else {
                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                appBundleList[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                appBundleList[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                appBundleList[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            }
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            //                                            appBundleList[appName]?.size += erasableFileSize
                                            //                                            totalGroupErasablesSize += erasableFileSize
                                            //                                        break
                                            //logArr.append(contentItemURL.description)
                                            continue fileTraversal2 // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                        }
                                    }
                                }
                            } else {
                                for nameSubString in appBundleList[bundleID]!.appSpecificErasables[index].fileNameContains {
                                    if relativePath.contains(nameSubString) {
                                        if !appBundleList[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                            for fileExt in appBundleList[bundleID]!.appSpecificErasables[index].fileExtensions {
                                                if relativePath.hasSuffix(fileExt) {
                                                    //                                                if debug {
                                                    //                                                    logArr.append("match 3")
                                                    //                                                }
                                                    erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                                    //totalErasableFiles += 1
                                                    
                                                                                                if let type = appBundleList[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleList[bundleID]!.size += erasableFileSize
                                                if appBundleList[bundleID]!.erasables[type] == nil {
                                                    appBundleList[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleList[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleList[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                        totalGroupErasablesSize += erasableFileSize
                                                    } else {
                                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                        appBundleList[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                        appBundleList[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                        appBundleList[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                    }
                                                    //                                                    appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                                    //                                                    appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                    //                                                    appBundleList[appName]?.size += erasableFileSize
                                                    //                                                    totalGroupErasablesSize += erasableFileSize
                                                    //logArr.append(contentItemURL.description)
                                                    //                                                break
                                                    continue fileTraversal2 // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                                }
                                            }
                                        } else { // If no extension is specified
                                            //                                        if debug {
                                            //                                            logArr.append("match 4")
                                            //                                        }
                                            erasableFileSize = try contentItemURL.regularFileAllocatedSize()
                                            //totalErasableFiles += 1
                                            
                                            if let type = appBundleList[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleList[bundleID]!.size += erasableFileSize
                                                if appBundleList[bundleID]!.erasables[type] == nil {
                                                    appBundleList[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleList[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleList[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                totalGroupErasablesSize += erasableFileSize
                                            } else {
                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                appBundleList[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                appBundleList[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                appBundleList[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            }
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            //                                            appBundleList[appName]?.size += erasableFileSize
                                            //                                            totalGroupErasablesSize += erasableFileSize
                                            //logArr.append(contentItemURL.description)
                                            //                                        break
                                            continue fileTraversal2 // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
        if appSpecificDatabases[bundleID] != nil {
            for index in appSpecificDatabases[bundleID]!.indices {
                if appSpecificDatabases[bundleID]?[index].dbPathType == .ContSharedApp {
                    for nameSubString in appSpecificDatabases[bundleID]![index].fileNameContains {
                        if relativePath.hasSuffix(nameSubString) {
                            // deve essere reso thread safe
                            let dbName = appSpecificDatabases[bundleID]![index].db.name
                            var db = Database(name: dbName, paths: [pathStr])
                            //                            appDatabases[appName]!.dbs[index].db.paths = [contentItemURL.path]
                            print("🟪3🟪🟪 compressing" + pathStr)
                            // Move db into shrinking folder
                            concurrentDbShrinkingQueue.async {
                                //                                var maxIndex = appDatabases[appName]?.count - 1
                                //                                print("concurrent db shrinking 1, max index: \(maxIndex), current index: \(index)")
                                shrinkDatabase(&db)
                            }
                            concurrentDbShrinkingQueue.async(flags: .barrier) {
                                if db.canBeShrinked {
                                    //                                    print(appDatabases[appName]!.dbs[index])
                                    if appDatabases[bundleID] == nil {
                                        appDatabases[bundleID] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                                    } else {
                                        appDatabases[bundleID]!.dbs.append(db)
                                        appDatabases[bundleID]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                                    }
                                    //                                    appDatabases[appName]!.dbs[index].db.size = db.size
                                    //                                    appDatabases[appName]!.dbs[index].db.shrinkedSize = db.shrinkedSize
                                    //                                    appDatabases[appName]!.dbs[index].db.spaceFreed = db.spaceFreed
                                    //                                        appDatabases[appName]!.dbs[index].db.canBeShrinked = db.canBeShrinked
                                    //                                        appDatabases[appName]!.dbs[index].db.paths = [pathStr]
                                } else {
                                    // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                    //                                    appDatabases[appName]!.dbs.remove(at: index)
                                    //quando lo rimuovo l'indice cambia
                                    // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                    if !(appDatabases[bundleID] == nil) {
                                        for index in appDatabases[bundleID]!.dbs.indices {
                                            if dbName == appDatabases[bundleID]!.dbs[index].name {
                                                appDatabases[bundleID]!.dbs.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            }
                            // Calculate size difference
                            continue fileTraversal2
                        }
                    }
                }
            }
        }
        
        //        for sqlExt in sqlDBExtension {
        //            if contentItemURL.path.hasSuffix(sqlExt) {
        //                var db = Database(name: contentItemURL.lastPathComponent, paths: [contentItemURL.path])
        //                var dbIndex = 0
        //                if foundDatabases[appName] == nil {
        //                    foundDatabases[appName] = Array<appDatabase>([(appDatabase(db: db, fileNameContains: []))])
        //                } else {
        //                    foundDatabases[appName]!.append(appDatabase(db: db, fileNameContains: []))
        //                    dbIndex = foundDatabases[appName]!.count - 1
        //                }
        //                logArr.append("🟪4🟪🟪 compressing" + contentItemURL.path)
        //                // Move db into shrinking folder
        //                concurrentDbShrinkingQueue.async {
        //                    var maxIndex = foundDatabases[appName]!.count - 1
        //                consoleManager.print("concurrent db shrinking 2, max index: \(maxIndex), current index: \(dbIndex)")
        //                    print("concurrent db shrinking 2, max index: \(maxIndex), current index: \(dbIndex)")
        //                    shrinkDatabase(foundDatabases[appName]![dbIndex].db)
        //                }
        //                // Calculate size difference
        //                continue fileTraversal2
        //            }
        //        }
        
        if relativePath.hasSuffix("-wal") {
            var dBAlreadyFound = false
            // Search if this database was already found
            if appDatabases[bundleID] != nil {
                for appDB in appDatabases[bundleID]!.dbs {
                    for path in appDB.paths {
                        if pathStr.contains(path) {
                            dBAlreadyFound = true
                        }
                    }
                }
            }
            
            if appUnshrinkableDatabases[bundleID] != nil { //TODO crasha appUnshrinkableDatabases non è thread safe, appName Index out of range
                for appDB in appUnshrinkableDatabases[bundleID]!.dbs {
                    for path in appDB.paths {
                        if pathStr.contains(path) {
                            dBAlreadyFound = true
                        }
                    }
                }
            }
            
            let dBPath = pathStr.dropLast(4).string
            
            if appSpecificDatabases[bundleID] != nil {
                for index in appSpecificDatabases[bundleID]!.indices {
                    if appSpecificDatabases[bundleID]?[index].dbPathType == .ContSharedApp {
                        for nameSubString in appSpecificDatabases[bundleID]![index].fileNameContains {
                            if dBPath.hasSuffix(nameSubString) {
                                dBAlreadyFound = true
                            }
                        }
                    }
                }
            }
            
            if !dBAlreadyFound {
                let dbName = (dBPath as NSString).lastPathComponent
                var db = Database(name: dbName, paths: [dBPath])
                concurrentDbShrinkingQueue.async {
                    shrinkDatabase(&db)
                }
                concurrentDbShrinkingQueue.async(flags: .barrier) {
                    if db.canBeShrinked {
                        if appDatabases[bundleID] == nil {
                            appDatabases[bundleID] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                        } else {
                            appDatabases[bundleID]!.dbs.append(db)
                            appDatabases[bundleID]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                        }
                    } else {
                        if appUnshrinkableDatabases[bundleID] == nil {
                            appUnshrinkableDatabases[bundleID] = DatabasesInfo(dbs: [db])
                        } else {
                            appUnshrinkableDatabases[bundleID]!.dbs.append(db)
                        }
                    }
                }
            }
        }
        
        for sqlExt in sqlDBExtension {
            if relativePath.hasSuffix(sqlExt) {
                let dbName = contentItemURL.lastPathComponent
                var db = Database(name: dbName, paths: [pathStr])
                //                var dbIndex = foundDatabases.count - 1
                //                logArr.append("🟪3🟪🟪 compressing" + pathStr)
                // Move db into shrinking folder
                if appUnshrinkableDatabases[bundleID] == nil { //appUnshrinkableDatabases non è thread safe
                    appUnshrinkableDatabases[bundleID] = DatabasesInfo(dbs: [db])
                } else {
                    appUnshrinkableDatabases[bundleID]!.dbs.append(db)
                }
                concurrentDbShrinkingQueue.async {
                    //                    var maxIndex = foundDatabases.count - 1
                    //                    consoleManager.print("concurrent db shrinking 3, max index: \(maxIndex), current index: \(dbIndex)")
                    //                    print("concurrent db shrinking 3, max index: \(maxIndex), current index: \(dbIndex)")
                    shrinkDatabase(&db)
                }
                
                concurrentDbShrinkingQueue.async(flags: .barrier) {
                    if db.canBeShrinked {
                        if appDatabases[bundleID] == nil {
                            appDatabases[bundleID] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                        } else {
                            var dBAlreadyFound = false
                            // Search if this database was already found
                            for appDB in appDatabases[bundleID]!.dbs {
                                for path in appDB.paths {
                                    if pathStr.contains(path) {
                                        dBAlreadyFound = true
                                    }
                                }
                            }
                            if !dBAlreadyFound {
                                appDatabases[bundleID]!.dbs.append(db)
                                appDatabases[bundleID]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                            }
                        }
                        // Remove from the unshrinkable databases
                        if !(appUnshrinkableDatabases[bundleID] == nil) {
                            for index in appUnshrinkableDatabases[bundleID]!.dbs.indices {
                                if dbName == appUnshrinkableDatabases[bundleID]!.dbs[index].name {
                                    appUnshrinkableDatabases[bundleID]!.dbs.remove(at: index)
                                    break
                                }
                            }
                        }
                    } else {
                        // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                        if !(appDatabases[bundleID] == nil) {
                            for index in appDatabases[bundleID]!.dbs.indices {
                                if dbName == appDatabases[bundleID]!.dbs[index].name {
                                    appDatabases[bundleID]!.dbs.remove(at: index)
                                    break
                                }
                            }
                        }
                    }
                }
                // Calculate size difference
                continue fileTraversal2
            }
        }
        
        if relativePath.contains(".lproj") {
            let pathComponents = relativePath.components(separatedBy: "/")
            for comp in (relativePath.components(separatedBy: "/")) {
                if comp.contains(".lproj") {
                    //                    let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_").string
                    let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_")
                    let size = contentItemURL.regularFileAllocatedSize()
                    contSharedLang += size
                    if foundLanguages[lang] == nil {
                        let langID = lang.before(first: "_")
                        if let altLang = alternativeLanguageNames[langID] {
                            foundLanguages[altLang] = langInfo(name: altLang)
                            foundLanguages[altLang]!.foundFiles.append(contentItemURL)
                            foundLanguages[altLang]!.size.bytes += size
                        } else {
                            if foundLanguages[langID] == nil {
                                // If it matches an extra language code
                                if let extraLanguageName = getExtraLanguageName(for: langID) {
                                    // Add it to foundLanguages
                                    foundLanguages[langID] = langInfo(name: extraLanguageName)
                                    foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                    foundLanguages[langID]!.size.bytes += size
                                } else {
                                    if undeterminedLanguages[lang] == nil {
                                        undeterminedLanguages[lang] = langInfo(name: lang)
                                    }
                                    undeterminedLanguages[lang]!.foundFiles.append(contentItemURL)
                                    undeterminedLanguages[lang]!.size.bytes += size
                                }
                            } else {
                                foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                foundLanguages[langID]!.size.bytes += size
                            }
                        }
                    } else {
                        foundLanguages[lang]!.foundFiles.append(contentItemURL)
                        foundLanguages[lang]!.size.bytes += size
                    }
                    totalErasableFiles += 1
                    break
                }
            }
            continue fileTraversal2
        }
    }
        return totalGroupErasablesSize
    }
    
    func allocatedSizeOfAllContainersDataApplication() -> Int64  {
        concurrentAppsQueue.async {
            // The error handler simply stores the error and stops traversal
            var enumeratorError: Error? = nil
            func errorHandler(url: URL, error: Error) -> Bool {
                enumeratorError = error
                logArr.append(url.description)
                logArr.append(error.localizedDescription)
                return false
            }
            var CDAPath = URL(fileURLWithPath: "/private/var/mobile/Containers/Data/Application")
            if DEBUGGING {
                CDAPath = URL(fileURLWithPath: "/private/var/mobile/Documents/CDA")
            }
            // We have to enumerate all directory contents, including subdirectories.
                var rootEnumerator = self.enumerator(at: CDAPath,
                                                 includingPropertiesForKeys: [],
                                                 options: [.skipsSubdirectoryDescendants],
                                                 //errorHandler: errorHandler)!
                                                 errorHandler: nil)!
            // We'll sum up content size here:
            //            var totalContainersDataErasablesSize: Int64 = 0
            
//            appBundleListCDA = appBundleList
            //            appBundleListCDA.sort()
            //            var resultarraytoavoidhavingtousesyncronization = []
            //            // Chunk size
            //            let numberOfElementsPerThread = rootEnumerator.underestimatedCount / numberOfContDataThreads
            //
            //            let arr = rootEnumerator.allObjects
            
            //            int threadCount = 4;
            //            ExecutorService executorService = Executors.newFixedThreadPool(threadCount);
            //            int numberOfTasks = 22;
            //            int chunkSize = numberOfTasks / threadCount;
            //            int extras = numberOfTasks % threadCount;
            //
            //            int startIndex, endIndex = 0;
            //
            //            for(int threadId = 0; threadId < threadCount; threadId++){
            //                startIndex = endIndex;
            //                if(threadId < (threadCount-extras)) {
            //                    endIndex = Math.min(startIndex + chunkSize, numberOfTasks);
            //                }else{
            //                    endIndex = Math.min(startIndex + chunkSize + 1, numberOfTasks);
            //                }
            //
            //
            //                int finalStartIndex = startIndex;
            //                int finalEndIndex = endIndex;
            //                executorService.submit(() -> {
            //                    log.info("Running tasks from startIndex: {}, to endIndex: {}, total : {}", finalStartIndex, finalEndIndex-1, finalEndIndex-finalStartIndex);
            //                    for (int i = finalStartIndex; i < finalEndIndex; i++) {
            //                        process(i);
            //                    }
            //                });
            //            }
            
            let appFolders = rootEnumerator.allObjects
            // Chunk size
            let numberOfElementsPerThread = appFolders.count / numberOfContBundleThreads
            let extraLastElement = appFolders.count - numberOfElementsPerThread * numberOfContBundleThreads  // i.e. remainder
            if !appFolders.isEmpty {
                for op in 0..<numberOfContBundleThreads {
                    //                concurrentAppsQueue.async {
                    concurrentAppPluginsQueue.async {
                        var start = op * numberOfElementsPerThread
                        var end = start + numberOfElementsPerThread - 1
                        if (op == numberOfContBundleThreads - 1) {
                            end = appFolders.count - 1
                        }
                        //                    print("thread: \(op) start: \(start) end: \(end)")
                        var appBundleListCDA2 = appBundleList
                        var languagesFilesCDA2 = languagesList
                        var undeterminedLanguages: OrderedDictionary<String, langInfo> = [:]
                        for item in appFolders[start..<end] {
                            // Bail out on errors from the errorHandler.
                            //if enumeratorError != nil { break }
                            
                            // Add up individual file sizes.
                            let contentItemURL = item as! URL
                            
                            let appUUID = contentItemURL.lastPathComponent
                            do {
                                try totalContainersDataSize += self.allocatedSizeOfContainersDataApplication(at: contentItemURL, appBundleListCDA: &appBundleListCDA2, foundLanguages: &languagesFilesCDA2, undeterminedLanguages: &undeterminedLanguages)
                            } catch {
                                logArr.append("Errore nel calcolo cont Data per \(contentItemURL.path)")
                                // consoleManager.print("Errore nel calcolo cont Data per \(contentItemURL.path) : \(error)")
                            }
                        }
                        
                        appBundleListCDA.append(appBundleListCDA2)
                        languagesFilesCDA.append(languagesFilesCDA2)
                        undeterminedLanguagesFilesCDA.append(undeterminedLanguages)
                        if (op == numberOfContBundleThreads - 1) {
                            print("🟦🟦🟦APP CONTAINERS DATA ANALYZED")
                            print(totalPluginsSize.formatBytes())
                        }
                    }
                }
            }
            
            
            
        
    }
//            for app in appBundleListCDA.keys {
//                appBundleList[app]!.size += appBundleListCDA[app]!.size
//                for erasable in appBundleListCDA[app]!.erasables.keys {
//                    if appBundleList[app]!.erasables[erasable] != nil {
//                        appBundleList[app]!.erasables[erasable]?.bytes += appBundleListCDA[app]!.erasables[erasable]!.bytes
//                    } else {
//                        appBundleList[app]!.erasables[erasable] = appBundleListCDA[app]!.erasables[erasable]
//                    }
//                }
//            }
        
        return totalContainersDataSize//totalContainersDataErasablesSize
    }
    
    internal func allocatedSizeOfContainersDataApplication(at appFolderURL: URL, appBundleListCDA: inout OrderedDictionary<String, AppInfo>, foundLanguages: inout OrderedDictionary<String, langInfo>, undeterminedLanguages: inout OrderedDictionary<String, langInfo>) -> Int64  {
        
            //        let appBundleUUID = appFolderURL.lastPathComponent
            var bundleID: String = ""
        var foundDatabases: [appDatabase] = []
            let appPlist = appFolderURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
            do {
                let infoPlistData = try Data(contentsOf: appPlist)
                
                if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    //                if c < 4 {
                    //                    logArr.append(plist.description)
                    //                    c+=1
                    //                }
                    ////                TEMPORANEO
                    //                if let name = plist["CFBundleDisplayName"] as? String {
                    //                    appName = name
                    //                } else {
                    //                    logArr.append("Errore 11")
                    //                    return 0
                    //                }
                    //
                    if let appBundleName = plist["MCMMetadataIdentifier"] as? String {
//                        if let app = appBundleList[appBundleName] {
//                            bundleID = app.appName
//                        } else {
//                            logArr.append("Errore 1: \(appBundleName)")
//                            return 0
//                        }
//                        //                    appGroupList[appGroupName] = AppGroupInfo(uuid: appGroupUUID)
                        bundleID = appBundleName
                    } else {
                        logArr.append("Errore 2")
                        return 0
                    }
                } else {
                    logArr.append("Errore 3")
                    return 0
                }
            } catch {
                logArr.append("Errore 4")
                // consoleManager.print(error.localizedDescription)
                return 0
            }
        var totalBundleErasablesSize: Int64 = 0
        if bundleID == "ph.telegra.Telegraph" {
            print("x")
        }
        if appBundleListCDA[bundleID] != nil {
            // The error handler simply stores the error and stops traversal
            var enumeratorError: Error? = nil
            func errorHandler(url: URL, error: Error) -> Bool {
                enumeratorError = error
                logArr.append(url.description)
                logArr.append(error.localizedDescription)
                return false
            }
            var erasableFileSize: Int64 = 0
            // We have to enumerate all directory contents, including subdirectories.
            let pluginEnumerator = self.enumerator(at: appFolderURL,
                                                   includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                   options: [],
                                                   //errorHandler: errorHandler)!
                                                   errorHandler: nil)!
            // Perform the traversal.
            //        print("Containers Data per \(appName)")
            //        concurrentAppGroupsRetrieverQueue.async {
        filesLoopCDA: for item in pluginEnumerator {
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            //           // consoleManager.print(contentItemURL)
            let pathStr = contentItemURL.path
            let start = pathStr.index(pathStr.startIndex, offsetBy: appFolderURL.path.count)
            let relativePath = contentItemURL.path[start...]
            for erasable in AppGroupsErasables {
                for nameSubString in erasable.fileNameContains {
                    //consoleManager.print("checking \(nameSubString)")
                    if pathStr.contains(nameSubString) {
                        //                       // consoleManager.print("contains \(nameSubString)")
                        erasableFileSize = contentItemURL.regularFileAllocatedSize()
                        //totalErasableFiles += 1
                        if appBundleListCDA[bundleID]?.erasables[erasable.name] != nil {
                            appBundleListCDA[bundleID]?.erasables[erasable.name]?.bytes += erasableFileSize
                            appBundleListCDA[bundleID]?.erasables[erasable.name]?.filesFound.append(contentItemURL)
                        } else {
                            appBundleListCDA[bundleID]?.erasables[erasable.name] = erasableData(bytes: erasableFileSize, filesFound: [contentItemURL])
                        }
                        //                        if appGroupList[appGroupName]?.erasableCategories[erasable.name] != nil {
                        //                            appGroupList[appGroupName]?.erasableCategories[erasable.name]?.bytes += erasableFileSize
                        //                        } else {
                        //                            appGroupList[appGroupName]?.erasableCategories[erasable.name] = (erasableFileSize, "")
                        //                        }
                        appBundleListCDA[bundleID]?.size += erasableFileSize
                        totalBundleErasablesSize += erasableFileSize
                        //                        logArr1.append(contentItemURL.description)
                        continue filesLoopCDA // If the current file matches a plugin, there is no need to check if it belongs to another plugin
                    }
                }
            }
            //                    if !appBundleList[bundleID]!.appSpecificErasables.isEmpty {     //Thread 5: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            //                                                                                    //bundleID = "com.matchstic.reprovision.ios"
            //ESISTONO CARTELLE DI APP GIÀ ELIMINATE, VANNO MESSE IN UNA CATEGORIA A PARTE
            for index in appBundleListCDA[bundleID]!.appSpecificErasables.indices {    //Thread 12: Fatal error: Unexpectedly found nil while unwrapping an Optional value
                //bundleID = "com.muirey03.cr4shedgui"
                //                if appName == "Instagram" {
                ////                    logArr.append("checking index " + index.description)
                //                }
                if appBundleListCDA[bundleID]?.appSpecificErasables[index].appPath == .ContDataApp {
                    //                    if appName == "Instagram" {
                    //                                                                logArr.append("Ⓜ️Ⓜ️Ⓜ️Ⓜ️checking CONT DATA app specific for app " + appName)
                    //                    }
                    //                    logArr.append("Analyzing" + appBundleList[appName]?.appSpecificErasables[index].erasableName)
                    for subpath in appBundleListCDA[bundleID]!.appSpecificErasables[index].subPaths {
                        if pathStr.contains(subpath) {
                            if appBundleListCDA[bundleID]!.appSpecificErasables[index].fileNameContains.isEmpty { //if no filename regex is specified, delete the whole folder
                                if !appBundleListCDA[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                    for fileExt in appBundleListCDA[bundleID]!.appSpecificErasables[index].fileExtensions {
                                        if pathStr.hasSuffix(fileExt) {
                                            //                                            logArr.append("match 5")
                                            erasableFileSize = contentItemURL.regularFileAllocatedSize()
                                            //totalErasableFiles += 1
                                            
                                            if let type = appBundleListCDA[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListCDA[bundleID]!.size += erasableFileSize
                                                if appBundleListCDA[bundleID]!.erasables[type] == nil {
                                                    appBundleListCDA[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListCDA[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListCDA[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                totalBundleErasablesSize += erasableFileSize
                                            } else {
                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                appBundleListCDA[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                appBundleListCDA[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                appBundleListCDA[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            }
                                            
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            //                                            appBundleList[appName]?.size += erasableFileSize
                                            //                                            totalBundleErasablesSize += erasableFileSize
                                            //                                                                logArr.append("\(erasableFileSize)")
                                            //                                                                logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                            //logArr.append(contentItemURL.description)
                                            break
                                            //                                            continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                        }
                                    }
                                } else { // If no extension is specified
                                    //                                    logArr.append("match 6")
                                    erasableFileSize = contentItemURL.regularFileAllocatedSize()
                                    //totalErasableFiles += 1
                                    if let type = appBundleListCDA[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListCDA[bundleID]!.size += erasableFileSize
                                                if appBundleListCDA[bundleID]!.erasables[type] == nil {
                                                    appBundleListCDA[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListCDA[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListCDA[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                        totalBundleErasablesSize += erasableFileSize
                                    } else {
                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                        appBundleListCDA[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                        appBundleListCDA[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                        appBundleListCDA[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                    }
                                    //                                    appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                    //                                    appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                    //                                    appBundleList[appName]?.size += erasableFileSize
                                    //                                    totalBundleErasablesSize += erasableFileSize
                                    //                                                        logArr.append("\(erasableFileSize)")
                                    //                                                        logArr.append("\(totalCustomPathAppSpecificErasablesSize)")
                                    //                                    logArr.append(contentItemURL.path)
                                    break
                                    //                                    continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                }
                            } else {
                                for nameSubString in appBundleListCDA[bundleID]!.appSpecificErasables[index].fileNameContains {
                                    if pathStr.contains(nameSubString) {
                                        if !appBundleListCDA[bundleID]!.appSpecificErasables[index].fileExtensions.isEmpty {
                                            for fileExt in appBundleListCDA[bundleID]!.appSpecificErasables[index].fileExtensions {
                                                if pathStr.hasSuffix(fileExt) {
                                                    //                                                    logArr.append("match 7")
                                                    erasableFileSize = contentItemURL.regularFileAllocatedSize()
                                                    //totalErasableFiles += 1
                                                    if let type = appBundleListCDA[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListCDA[bundleID]!.size += erasableFileSize
                                                if appBundleListCDA[bundleID]!.erasables[type] == nil {
                                                    appBundleListCDA[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListCDA[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListCDA[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                        totalBundleErasablesSize += erasableFileSize
                                                    } else {
                                                        totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                        appBundleListCDA[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                        appBundleListCDA[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                        appBundleListCDA[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                    }
                                                    //                                                    appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                                    //                                                    appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                                    //                                                    appBundleList[appName]?.size += erasableFileSize
                                                    //                                                    totalBundleErasablesSize += erasableFileSize
                                                    //                                                    logArr.append(contentItemURL.path)
                                                    break
                                                    //                                                    continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                                }
                                            }
                                        } else { // If no extension is specified
                                            //                                            logArr.append("match 8")
                                            erasableFileSize = contentItemURL.regularFileAllocatedSize()
                                            //totalErasableFiles += 1
                                            if let type = appBundleListCDA[bundleID]!.appSpecificErasables[index].erasableType {
                                                appBundleListCDA[bundleID]!.size += erasableFileSize
                                                if appBundleListCDA[bundleID]!.erasables[type] == nil {
                                                    appBundleListCDA[bundleID]!.erasables[type] = erasableData(bytes: erasableFileSize)
                                                } else {
                                                    appBundleListCDA[bundleID]!.erasables[type]!.bytes += erasableFileSize
                                                }
                                                appBundleListCDA[bundleID]!.erasables[type]!.filesFound.append(contentItemURL)
                                                totalBundleErasablesSize += erasableFileSize
                                            } else {
                                                totalCustomPathAppSpecificErasablesSize += erasableFileSize
                                                appBundleListCDA[bundleID]!.appSpecificErasablesSize += erasableFileSize
                                                appBundleListCDA[bundleID]?.appSpecificErasables[index].bytes += erasableFileSize
                                                appBundleListCDA[bundleID]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            }
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].bytes += erasableFileSize
                                            //                                            appBundleList[appName]?.appSpecificErasables[index].filesFound.append(contentItemURL)
                                            //                                            appBundleList[appName]?.size += erasableFileSize
                                            //                                            totalBundleErasablesSize += erasableFileSize
                                            //                                            logArr.append(contentItemURL.path)
                                            break
                                            //                                        continue filesLoop // If the current file matches an app specific erasables category, there is no need to check if it belongs to another app specific category
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //                    }
            if appSpecificDatabases[bundleID] != nil {
                for index in appSpecificDatabases[bundleID]!.indices {
                    if appSpecificDatabases[bundleID]?[index].dbPathType == .ContDataApp {
                        for nameSubString in appSpecificDatabases[bundleID]![index].fileNameContains {
                            if pathStr.hasSuffix(nameSubString) {
                                // deve essere reso thread safe
                                let dbName = appSpecificDatabases[bundleID]![index].db.name
                                var db = Database(name: dbName, paths: [pathStr])
                                //                            appDatabases[appName]!.dbs[index].db.paths = [contentItemURL.path]
                                print("🟪3🟪🟪 compressing" + pathStr)
                                // Move db into shrinking folder
                                concurrentDbShrinkingQueue.async {
                                    //                                    var maxIndex = appDatabases[appName]!.count - 1
                                    //                                    print("concurrent db shrinking 1, max index: \(maxIndex), current index: \(index)")
                                    shrinkDatabase(&db)
                                }
                                concurrentDbShrinkingQueue.async(flags: .barrier) {
                                    if db.canBeShrinked {
                                        //                                        print(appDatabases[appName]!.dbs[index])
                                        if appDatabases[bundleID] == nil {
                                            appDatabases[bundleID] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                                        } else {
                                            appDatabases[bundleID]!.dbs.append(db)
                                            appDatabases[bundleID]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                                        }
                                        //                                    appDatabases[appName]!.dbs[index].db.size = db.size
                                        //                                    appDatabases[appName]!.dbs[index].db.shrinkedSize = db.shrinkedSize
                                        //                                    appDatabases[appName]!.dbs[index].db.spaceFreed = db.spaceFreed
                                        //                                        appDatabases[appName]!.dbs[index].db.canBeShrinked = db.canBeShrinked
                                        //                                        appDatabases[appName]!.dbs[index].db.paths = [pathStr]
                                    } else {
                                        // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                        //                                    appDatabases[appName]!.dbs.remove(at: index)
                                        //quando lo rimuovo l'indice cambia
                                        // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                                        if !(appDatabases[bundleID] == nil) {
                                            for index in appDatabases[bundleID]!.dbs.indices {
                                                if dbName == appDatabases[bundleID]!.dbs[index].name {
                                                    appDatabases[bundleID]!.dbs.remove(at: index)
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                // Calculate size difference
                                continue filesLoopCDA
                            }
                        }
                    }
                }
            }
            
            // PARE CHE NON CE NE SIA NESSUNO
            for sqlExt in sqlDBExtension {
                if pathStr.hasSuffix(sqlExt) {
                    let dbName = contentItemURL.lastPathComponent
                    var db = Database(name: dbName, paths: [pathStr])
                    //                var dbIndex = foundDatabases.count - 1
                    //                    logArr.append("🟪2🟪🟪 compressing" + pathStr)
                    // Move db into shrinking folder
                    concurrentDbShrinkingQueue.async {
                        //                    var maxIndex = foundDatabases.count - 1
                        //                    consoleManager.print("concurrent db shrinking 3, max index: \(maxIndex), current index: \(dbIndex)")
                        //                    print("concurrent db shrinking 3, max index: \(maxIndex), current index: \(dbIndex)")
                    }
                    
                    concurrentDbShrinkingQueue.async(flags: .barrier) {
                        if db.canBeShrinked {
                            if appDatabases[bundleID] == nil {
                                appDatabases[bundleID] = DatabasesInfo(dbs: [db], totalShrinkableSize: (db.spaceFreed.bytes, ""))
                            } else {
                                appDatabases[bundleID]!.dbs.append(db)
                                appDatabases[bundleID]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
                            }
                        } else {
                            // Remove it so the app doesn't show in the list if there are no others shrinkable databases
                            if !(appDatabases[bundleID] == nil) {
                                for index in appDatabases[bundleID]!.dbs.indices {
                                    if dbName == appDatabases[bundleID]!.dbs[index].name {
                                        appDatabases[bundleID]!.dbs.remove(at: index)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    // Calculate size difference
                    continue filesLoopCDA
                }
            }
            
            //            for sqlExt in sqlDBExtension {
            //                if contentItemURL.path.hasSuffix(sqlExt) {
            //                    var db = Database(name: contentItemURL.lastPathComponent, paths: [contentItemURL.path])
            //                    var dbIndex = 0
            //                    if appDatabases[appName] == nil {
            //                        appDatabases[appName] = Array<appDatabase>([(appDatabase(db: db, fileNameContains: []))])
            //                    } else {
            //                        appDatabases[appName]!.dbs.append(db)
            //                                appDatabases[appName]!.totalShrinkableSize.bytes += db.spaceFreed.bytes
            //                        dbIndex = appDatabases[appName]!.count - 1
            //                    }
            //                    logArr.append("🟪4🟪🟪 compressing" + contentItemURL.path)
            //                    // Move db into shrinking folder
            //                    concurrentDbShrinkingQueue.async {
            //                        var maxIndex = appDatabases[appName]!.count - 1
            //                        consoleManager.print("concurrent db shrinking 4, max index: \(maxIndex), current index: \(dbIndex)")
            //                        print("concurrent db shrinking 4, max index: \(maxIndex), current index: \(dbIndex)")
            //                        shrinkDatabase(appDatabases[appName]![dbIndex].db)
            //                    }
            //                    continue filesLoop
            //                    // Calculate size difference
            //                }
            //            }
            
            //            for mongoExt in mongoDBExtension {
            //                if relativePath.hasSuffix(mongoExt) {
            //                    // Move db into srinking folder
            //                    // Calculate size difference
            //
            //                    //                let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            //                    //                    // totalBytes refers to the size of the file on disk in bytes (data + free space)
            //                    //                    // usedBytes refers to the number of bytes used by data in the file
            //                    //
            //                    //                    // Compact if the file is over 100MB in size and less than 50% 'used'
            //                    //                    let oneHundredMB = 100 * 1024 * 1024
            //                    //                    return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            //                    //                })
            //                    //                do {
            //                    //                    // Realm is compacted on the first open if the configuration block conditions were met.
            //                    //                    let realm = try Realm(configuration: config)
            //                    //                } catch {
            //                    //                    // handle error compacting or opening Realm
            //                    //                }
            //
            //                    continue filesLoop
            //                }
            //            }
            if pathStr.contains(".lproj") {
                for comp in (pathStr.components(separatedBy: "/")) {
                    if comp.contains(".lproj") {
                        let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_")
                        let size = contentItemURL.regularFileAllocatedSize()
                        contDataLang += size
                        if foundLanguages[lang] == nil {
                            let langID = lang.before(first: "_")
                            if let altLang = alternativeLanguageNames[langID] {
                                foundLanguages[altLang] = langInfo(name: altLang)
                                foundLanguages[altLang]!.foundFiles.append(contentItemURL)
                                foundLanguages[altLang]!.size.bytes += size
                            } else {
                                if foundLanguages[langID] == nil {
                                    // If it matches an extra language code
                                    if let extraLanguageName = getExtraLanguageName(for: langID) {
                                        // Add it to foundLanguages
                                        foundLanguages[langID] = langInfo(name: extraLanguageName)
                                        foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                        foundLanguages[langID]!.size.bytes += size
                                    } else {
                                        if undeterminedLanguages[lang] == nil {
                                            undeterminedLanguages[lang] = langInfo(name: lang)
                                        }
                                        undeterminedLanguages[lang]!.foundFiles.append(contentItemURL)
                                        undeterminedLanguages[lang]!.size.bytes += size
                                    }
                                } else {
                                    foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                    foundLanguages[langID]!.size.bytes += size
                                }
                            }
                        } else {
                            foundLanguages[lang]!.foundFiles.append(contentItemURL)
                            foundLanguages[lang]!.size.bytes += size
                        }
                        totalErasableFiles += 1
                        break
                    }
                }
                continue filesLoopCDA
            }
            
        }
            
            //            if let app = appBundleList[appName] {
            //                for erasable in app.erasables.keys {
            //                    if let type = appBundleList[appName]?.erasables[erasable] {
            //                        appBundleList[appName]!.erasables[erasable]!.formatted = (appBundleList[appName]!.erasables[erasable]!.bytes.formatBytes())
            //                    }
            //                }
            //            }
            
        } else {
            // TROVATA una cartella di un'app gia' eliminata oppure una cartella estranea che non e' un'app
        }
        return totalBundleErasablesSize
    }
    
    
    func allocatedSizeOfAppsPlugins() -> Int64  {
        concurrentAppsQueue.async {
            // The error handler simply stores the error and stops traversal
            var enumeratorError: Error? = nil
            func errorHandler(url: URL, error: Error) -> Bool {
                enumeratorError = error
                //                logArr.append(url.description)
                //                logArr.append(error.localizedDescription)
                return false
            }
            // We have to enumerate all directory contents, including subdirectories.
                        let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/containers/Bundle/Application"),
//            let rootEnumerator = self.enumerator(at:URL(fileURLWithPath: "/private/var/mobile/Documents/CBA"),
                                                 includingPropertiesForKeys: [],
                                                 options: [.skipsSubdirectoryDescendants],
                                                 //errorHandler: errorHandler)!
                                                 errorHandler: nil)!
            // We'll sum up content size here:
            //            var totalPluginsSize: Int64 = 0
            //            appBundleListCBA = appBundleList
            
            let appFolders = rootEnumerator.allObjects
            // Chunk size
            if !appFolders.isEmpty {
            let numberOfElementsPerThread = appFolders.count / numberOfContBundleThreads
            let extraLastElement = appFolders.count - numberOfElementsPerThread * numberOfContBundleThreads  // i.e. remainder

                for op in 0..<numberOfContBundleThreads {
                    //                concurrentAppsQueue.async {
                    concurrentAppPluginsQueue.async {
                        var start = op * numberOfElementsPerThread
                        var end = start + numberOfElementsPerThread - 1
                        if (op == numberOfContBundleThreads - 1) {
                            end = appFolders.count - 1
                        }
                        //                    print("thread: \(op) start: \(start) end: \(end)")
                        var appBundleListCBA2 = appBundleList
                        var languagesFilesCBA2 = languagesList
                        var undeterminedLanguages: OrderedDictionary<String, langInfo> = [:]
                        for item in appFolders[start..<end] {
                            // Bail out on errors from the errorHandler.
                            //if enumeratorError != nil { break }
                            
                            // Add up individual file sizes.
                            let contentItemURL = item as! URL
                            
                            let appUUID = contentItemURL.lastPathComponent
                            do {
                                try totalPluginsSize += self.allocatedSizeOfApp(at: contentItemURL, appBundleList: &appBundleListCBA2, foundLanguages: &languagesFilesCBA2, undeterminedLanguages: &undeterminedLanguages)
                            } catch {
                                // consoleManager.print("errore 21: \(error)")
                            }
                        }
                        appBundleListCBA.append(appBundleListCBA2)
                        languagesFilesCBA.append(languagesFilesCBA2)
                        undeterminedLanguagesFilesCBA.append(undeterminedLanguages)
                        if (op == numberOfContBundleThreads - 1) {
                            print("🟫🟫🟫APP CONTAINERS BUNDLE ANALYZED")
                            print(totalPluginsSize.formatBytes())
                        }
                    }
                }
            }
//            //Last chunk with all the remaining content
//            start = end + 1;
//            end = arraySize - 1;
//            InsertionSort(&array[start], end + 1);
        
//            var start = 0
//            var end = numberOfElementsPerThread
//            while (start < appFolders.count) {
//
//                start = end
//                end = start + numberOfElementsPerThread
//            }
//            for (start = 0, end = chunk_size;
//                 start < array_size;
//                 start = end, end = start + chunk_size)
//            {
//                if (bonus) {
//                    end++;
//                    bonus--;
//                }
//
//                /* do something with array slice over [start, end) interval */
//            }
            // Perform the traversal.
//            for item in rootEnumerator {
//                // Bail out on errors from the errorHandler.
//                //if enumeratorError != nil { break }
//
//                // Add up individual file sizes.
//                let contentItemURL = item as! URL
//
//                let appUUID = contentItemURL.lastPathComponent
//                do {
//                    try totalPluginsSize += self.allocatedSizeOfApp(at: contentItemURL)
//                } catch {
//                    // consoleManager.print("errore 21: \(error)")
//                }
//
//            }
//            for app in appBundleListCBA.keys {
//                appBundleList[app]!.size += appBundleListCBA[app]!.size
//                appBundleList[app]!.plugins = appBundleListCBA[app]!.plugins
//            }
        }
        return totalPluginsSize
    }
    
    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    internal func allocatedSizeOfApp(at directoryURL: URL, appBundleList: inout OrderedDictionary<String, AppInfo>, foundLanguages: inout OrderedDictionary<String, langInfo>, undeterminedLanguages: inout OrderedDictionary<String, langInfo>) -> Int64 {
            // The error handler simply stores the error and stops traversal
            var enumeratorError: Error? = nil
            func errorHandler(url: URL, error: Error) -> Bool {
                enumeratorError = error
                //            logArr.append(url.description)
                //            logArr.append(error.localizedDescription)
                return false
            }
            // We have to enumerate all directory contents, including subdirectories.
            let rootEnumerator = self.enumerator(at: directoryURL,
                                                 includingPropertiesForKeys: [],
                                                 options: [.skipsSubdirectoryDescendants],
                                                 //errorHandler: errorHandler)!
                                                 errorHandler: nil)!
            // We'll sum up content size here:
            var totalAppPluginsSize: Int64 = 0
            // We'll sum up content size here:
            var pluginFileSize: Int64 = 0
            var appFolderURL: URL
            var wasAlreadyCounted = false
            var bundleID = ""
            // Perform the traversal.
            for item in rootEnumerator {
                // Bail out on errors from the errorHandler.
                //if enumeratorError != nil { break }
                
                // Add up individual file sizes.
                let contentItemURL = item as! URL
//                print(contentItemURL)
                
                
                //            if let app = contentItemURL.applicationItem {
                //                // questo metodo ottiene il nome dell'app non dall'info plist cfbundledisplay, ad es. whatsapp cosi non ha la W iniziale come carattere speciale
                //                let appName = app.localizedName()
                //                appFolderURL = contentItemURL
                
                
//                if contentItemURL.path.contains(".app/") {
                if contentItemURL.path.hasSuffix(".app") {
                    appFolderURL = contentItemURL
                    
                    let appPlist = appFolderURL.appendingPathComponent("Info.plist")
                    do {
                        let infoPlistData = try Data(contentsOf: appPlist)
                        
                        if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
//                            if let app = plist["CFBundleDisplayName"] as? String {
//                                appName = app
//                                //                                    appBundleList[appUUID] = AppInfo(name: appName)
//                            }
                            if let id = plist["CFBundleIdentifier"] as? String {
                                bundleID = id
                                //                                    appBundleList[appUUID] = AppInfo(name: appName)
                            }
                        }
                    } catch {
                        print("errore info plist cba")
                        // consoleManager.print(error.localizedDescription)
                    }
                    
//                    // We have to enumerate all directory contents, including subdirectories.
//                    let pluginEnumerator = self.enumerator(at: appFolderURL.appendingPathComponent(appPluginSubfolder),
//                                                           includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
//                                                           options: [],
//                                                           //errorHandler: errorHandler)!
//                                                           errorHandler: nil)!
//                    // Perform the traversal.
//                    for item in pluginEnumerator {
//                        // Bail out on errors from the errorHandler.
//                        //if enumeratorError != nil { break }
//
//                        // Add up individual file sizes.
//                        let contentItemURL = item as! URL
////                        let pathStr = contentItemURL.path
////                        let start = pathStr.index(pathStr.startIndex, offsetBy: appFolderURL.path.count)
////                        let relativePath = contentItemURL.path[start...]
//
//                        for plugin in AppPlugins {
//                            if contentItemURL.path.contains(plugin.fileNameContains) {
////                            if relativePath.contains(plugin.fileNameContains) {
//                                pluginFileSize = contentItemURL.regularFileAllocatedSize()
//                                //totalErasableFiles += 1
//                                if appBundleListCBA[appName]?.plugins[plugin.name] != nil {
//                                    appBundleListCBA[appName]?.plugins[plugin.name]?.bytes += pluginFileSize
//                                    appBundleListCBA[appName]?.plugins[plugin.name]?.filesFound.append(contentItemURL)
//                                } else {
//                                    appBundleListCBA[appName]?.plugins[plugin.name] = erasableData(bytes: pluginFileSize, filesFound: [contentItemURL])
//                                }
//                                appBundleListCBA[appName]?.size += pluginFileSize
//                                totalPluginsSize += pluginFileSize
//                                break // If the current file matches a plugin, there is no need to check if it belongs to another plugin
//                            }
//                        }
//                    }
                    
                    // We have to enumerate all directory contents, including subdirectories.
                    let appBundleEnumerator = self.enumerator(at: appFolderURL,
                                                              includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                              options: [],
                                                              //errorHandler: errorHandler)!
                                                              errorHandler: nil)!
                    // Perform the traversal.
                    for item in appBundleEnumerator {
                        // Bail out on errors from the errorHandler.
                        //if enumeratorError != nil { break }
                        
                        // Add up individual file sizes.
                        let contentItemURL = item as! URL
                        wasAlreadyCounted = false
                        
                        if contentItemURL.path.contains(appPluginSubfolder) {
                            for plugin in AppPlugins {
                                if contentItemURL.path.contains(plugin.fileNameContains) {
                                    //                            if relativePath.contains(plugin.fileNameContains) {
                                    pluginFileSize = contentItemURL.regularFileAllocatedSize()
                                    //totalErasableFiles += 1
                                    if appBundleList[bundleID]?.plugins[plugin.name] != nil {
                                        appBundleList[bundleID]?.plugins[plugin.name]?.bytes += pluginFileSize
                                        appBundleList[bundleID]?.plugins[plugin.name]?.filesFound.append(contentItemURL)
                                    } else {
                                        appBundleList[bundleID]?.plugins[plugin.name] = erasableData(bytes: pluginFileSize, filesFound: [contentItemURL])
                                    }
//                                    appBundleList[appName]?.size += pluginFileSize
                                    totalAppPluginsSize += pluginFileSize
                                    wasAlreadyCounted = true
                                    break // If the current file matches a plugin, there is no need to check if it belongs to another plugin
                                }
                            }
//                            continue
                            // i file lproj dei plugin vanno aggiunti
                        }
                        
                        if contentItemURL.path.contains(".lproj") {
                            for comp in (contentItemURL.path.components(separatedBy: "/")) {
                                if comp.contains(".lproj") {
//                                    let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_").string
                                    let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_")
                                    let size = contentItemURL.regularFileAllocatedSize()
                                    contBundleLang += size
//                                    print("thread \(threadN) trovato \(lang) app \(appName) aggiungo \(contentItemURL)")
                                    if foundLanguages[lang] == nil {
                                        let langID = lang.before(first: "_")
                                        if let altLang = alternativeLanguageNames[langID] {
                                            foundLanguages[altLang] = langInfo(name: altLang)
                                            foundLanguages[altLang]!.foundFiles.append(contentItemURL)
                                            foundLanguages[altLang]!.size.bytes += size
                                        } else {
                                            if foundLanguages[langID] == nil {
                                                // If it matches an extra language code
                                                if let extraLanguageName = getExtraLanguageName(for: langID) {
                                                    // Add it to foundLanguages
                                                    foundLanguages[langID] = langInfo(name: extraLanguageName)
                                                    foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                                    foundLanguages[langID]!.size.bytes += size
                                                } else {
                                                    if undeterminedLanguages[lang] == nil {
                                                        undeterminedLanguages[lang] = langInfo(name: lang)
                                                    }
                                                    undeterminedLanguages[lang]!.foundFiles.append(contentItemURL)
                                                    undeterminedLanguages[lang]!.size.bytes += size
                                                }
                                            } else {
                                                foundLanguages[langID]!.foundFiles.append(contentItemURL)
                                                foundLanguages[langID]!.size.bytes += size
                                            }
                                        }
                                    } else {
                                        foundLanguages[lang]!.foundFiles.append(contentItemURL)
                                        foundLanguages[lang]!.size.bytes += size
                                    }
                                    totalErasableFiles += 1
                                    if wasAlreadyCounted {
                                        bytesCountedTwice += size
                                    }
                                    break
                                }
                            }
                            continue
                        }
                    }
                    
                    
                    break // After the .app folder is found, the root enumerator traversal must stop
                }
            }
            
//            if let app = appBundleListCBA[threadN][appName] {
//                for plugin in app.plugins.keys {
//                    if let type = appBundleListCBA[threadN][appName]?.plugins[plugin] {
//                        appBundleListCBA[threadN][appName]!.plugins[plugin]!.formatted = (appBundleListCBA[threadN][appName]!.plugins[plugin]!.bytes.formatBytes())
//                    }
//                }
//            }
            
            // Rethrow errors from errorHandler.
//            if let error = enumeratorError { throw error }
        return totalAppPluginsSize
    }
    
    func allocatedSizeOfSystemGroups() throws -> Int64  {
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
//            logArr.append(url.description)
//            logArr.append(error.localizedDescription)
            return false
        }
        // We have to enumerate all directory contents, including subdirectories.
        let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup"),
                                             //                let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/provacontainersBundleApplication"),
                                             includingPropertiesForKeys: [],
                                             options: [.skipsSubdirectoryDescendants],
                                             //errorHandler: errorHandler)!
                                             errorHandler: nil)!
        // We'll sum up content size here:
        var totalSystemGroupsSize: Int64 = 0
        // Perform the traversal.
        for item in rootEnumerator {
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            
            let appUUID = contentItemURL.lastPathComponent
            do {
                try totalSystemGroupsSize += self.allocatedSizeOfSystemGroup(at: contentItemURL)
            } catch {
                // consoleManager.print("errore 21: \(error)")
            }
        }
        return totalSystemGroupsSize
    }
    
    func allocatedSizeOfSystemGroup(at sysGroupFolderURL: URL) throws -> Int64  {
        let appPlist = sysGroupFolderURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
        var totalSystemGroupErasablesSize: Int64 = 0
        do {
            let infoPlistData = try Data(contentsOf: appPlist)
            
            if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                //                if c < 4 {
                //                    logArr.append(plist.description)
                //                    c+=1
                //                }
                ////                TEMPORANEO
                //                if let name = plist["CFBundleDisplayName"] as? String {
                //                    appName = name
                //                } else {
                //                    logArr.append("Errore 11")
                //                    return 0
                //                }
                //
                if let systemBundleName = plist["MCMMetadataIdentifier"] as? String {
                    if let sysGroup = systemGroups[systemBundleName] {
                        // The error handler simply stores the error and stops traversal
                        var enumeratorError: Error? = nil
                        func errorHandler(url: URL, error: Error) -> Bool {
                            enumeratorError = error
//                            logArr.append(url.description)
//                            logArr.append(error.localizedDescription)
                            return false
                        }
                        var erasableFileSize: Int64 = 0
                        // We have to enumerate all directory contents, including subdirectories.
                        let systemGroupFolderEnumerator = self.enumerator(at: sysGroupFolderURL,
                                                                          includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                                          options: [],
                                                                          //errorHandler: errorHandler)!
                                                                          errorHandler: nil)!
                        // Perform the traversal.
                    filesLoop: for item in systemGroupFolderEnumerator {
                        // Bail out on errors from the errorHandler.
                        //if enumeratorError != nil { break }
                        
                        // Add up individual file sizes.
                        let contentItemURL = item as! URL
                        //           // consoleManager.print(contentItemURL)
                        for nameSubString in sysGroup.fileNameContains {
                            //consoleManager.print("checking \(nameSubString)")
                            if contentItemURL.path.contains(nameSubString) {
                                //                       // consoleManager.print("contains \(nameSubString)")
                                erasableFileSize = try contentItemURL.regularFileAllocatedSize()
//                                totalErasableFiles += 1
                                systemGroups[systemBundleName]!.size.bytes += erasableFileSize
                                systemGroups[systemBundleName]!.foundFiles.append(contentItemURL)
                                //                        logArr1.append(contentItemURL.description)
                                totalSystemGroupErasablesSize += erasableFileSize
                                continue filesLoop // If the current file matches a plugin, there is no need to check if it belongs to another plugin
                            }
                        }
                    }
                    } else {
                        print("\(systemBundleName) NON PRESENTE NELL'ARRAY")
                        return 0
                    }
                } else {
                    print("Errore 2")
                    return 0
                }
            } else {
                print("Errore 3")
                return 0
            }
        } catch {
            print("Errore 4")
            // consoleManager.print(error.localizedDescription)
            return 0
        }
        return totalSystemGroupErasablesSize
    }
    
    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    func allocatedSizeOfFiles(at directoryURL: URL, fileExtensions: [String], fileNameContains: [String], isRecursive: Bool = true) throws -> (size: Int64, filesFound: [URL]) {
        
        var filesFound: [URL] = []
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            logArr.append(url.description)
            logArr.append(error.localizedDescription)
            return false
        }
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [isRecursive ? [] : .skipsSubdirectoryDescendants],
                                         //                                         options: [],
                                         //errorHandler: errorHandler)!
                                         errorHandler: nil)!
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        var correctExt = false
        
        
        // Perform the traversal.
        for item in enumerator {
            correctExt = false
            
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            for fileExtension in fileExtensions {
                if contentItemURL.path.hasSuffix(fileExtension) {
                    correctExt = true
                    break
                }
            }
            
            if (correctExt || fileExtensions.isEmpty) {
                if !fileNameContains.isEmpty {
                    for keyword in fileNameContains {
                        if contentItemURL.path.contains(keyword) {
                            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
                            filesFound.append(contentItemURL)
                            //totalErasableFiles += 1
                            //                            var size = try contentItemURL.regularFileAllocatedSize()
                            //                            accumulatedSize += size
                            //                            let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                            //                            let formattedAccumulatedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                            //                           // consoleManager.print("File: \(contentItemURL)--- Size:\(formattedSize) --- Accumulated Size:\(formattedAccumulatedSize)")
                            break //once added don't add it multiple times by testing it with other names
                        }
                    }
                } else {
                    accumulatedSize += try contentItemURL.regularFileAllocatedSize()
                    filesFound.append(contentItemURL)
                    //totalErasableFiles += 1
                    //                    var size = try contentItemURL.regularFileAllocatedSize()
                    //                    accumulatedSize += size
                    //                    let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                    let formattedAccumulatedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                   // consoleManager.print("File: \(contentItemURL)--- Size:\(formattedSize) --- Accumulated Size:\(formattedAccumulatedSize)")
                }
            }
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return (accumulatedSize, filesFound)
    }
    
    func allocatedSizeOfFiles(at directoryURL: URL, fileExtensions: [String], isRecursive: Bool = true) throws -> (size: Int64, filesFound: [URL]) {
        
        var filesFound: [URL] = []
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            logArr.append(url.description)
            logArr.append(error.localizedDescription)
            return false
        }
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [isRecursive ? [] : .skipsSubdirectoryDescendants],
                                         //                                         options: [],
                                         //errorHandler: errorHandler)!
                                         errorHandler: nil)!
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            
            for fileExtension in fileExtensions {
                if contentItemURL.path.hasSuffix(fileExtension) {
                    accumulatedSize += try contentItemURL.regularFileAllocatedSize()
                    filesFound.append(contentItemURL)
                    //totalErasableFiles += 1
                    //                    var size = try contentItemURL.regularFileAllocatedSize()
                    //                    accumulatedSize += size
                    //                    let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                    let formattedAccumulatedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                   // consoleManager.print("File: \(contentItemURL)--- Size:\(formattedSize) --- Accumulated Size:\(formattedAccumulatedSize)")
                    break
                }
            }
            
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return (accumulatedSize, filesFound)
    }
    
    func allocatedSizeOfFiles(at directoryURL: URL, fileNameContains: [String], isRecursive: Bool = true) throws -> (size: Int64, filesFound: [URL]) {
        
        var filesFound: [URL] = []
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            logArr.append(url.description)
            logArr.append(error.localizedDescription)
            return false
        }
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [isRecursive ? [] : .skipsSubdirectoryDescendants],
                                         //                                         options: [],
                                         //errorHandler: errorHandler)!
                                         errorHandler: nil)!
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            
            for keyword in fileNameContains {
                if contentItemURL.path.contains(keyword) {
                    accumulatedSize += try contentItemURL.regularFileAllocatedSize()
                    filesFound.append(contentItemURL)
                    //totalErasableFiles += 1
                    //                            var size = try contentItemURL.regularFileAllocatedSize()
                    //                            accumulatedSize += size
                    //                            let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                            let formattedAccumulatedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
                    //                           // consoleManager.print("File: \(contentItemURL)--- Size:\(formattedSize) --- Accumulated Size:\(formattedAccumulatedSize)")
                    break //once added don't add it multiple times by testing it with other names
                }
            }
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return (accumulatedSize, filesFound)
    }
    
    func allocatedSizeOfFiles(at directoryURL: URL, isRecursive: Bool = true) throws -> (size: Int64, filesFound: [URL]) {
        
        var filesFound: [URL] = []
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            logArr.append(url.description)
            logArr.append(error.localizedDescription)
            return false
        }
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [isRecursive ? [] : .skipsSubdirectoryDescendants],
                                         //                                         options: [],
                                         //errorHandler: errorHandler)!
                                         errorHandler: nil)!
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            // Bail out on errors from the errorHandler.
            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
            filesFound.append(contentItemURL)
            //totalErasableFiles += 1
            //            var size = try contentItemURL.regularFileAllocatedSize()
            //            accumulatedSize += size
            //            let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
            //            let formattedAccumulatedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
            //           // consoleManager.print("File: \(contentItemURL)--- Size:\(formattedSize) --- Accumulated Size:\(formattedAccumulatedSize)")
            
        }
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return (accumulatedSize, filesFound)
    }
    
    
    
    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    func deleteFiles(at directoryURL: URL, fileExtension: String) throws -> Int64 {
        
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(url: URL, error: Error) -> Bool {
            enumeratorError = error
            logArr.append(url.description)
            logArr.append(error.localizedDescription)
            return false
        }
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         ////errorHandler: errorHandler)!
                                         errorHandler: nil)!
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            
            // Bail out on errors from the errorHandler.
            //            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            guard contentItemURL.path.hasSuffix(fileExtension) else { continue }
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
            //totalErasableFiles += 1
            try self.removeItem(at: contentItemURL)
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return accumulatedSize
    }
    
}

//func deleteSelectedFilesOriginal() {
//    concurrentDeletionQueue.async {
//        var filesToDelete: [URL] = []
////        var categoriesToProcess: [String : [URL]] = [:]
//        for appInfo in appBundleList.values {
//            for plugin in appInfo.plugins.values {
//                if plugin.isChecked {
//                    filesToDelete += plugin.filesFound
//                    if categoriesToProcess["App Plugins"] != nil {
//                        categoriesToProcess["App Plugins"]!.files += plugin.filesFound
//                    } else {
//                        categoriesToProcess["App Plugins"] = (plugin.filesFound, false)
//                    }
//                }
//            }
//            if appInfo.isChecked {
//                for erasable in appInfo.erasables.values {
//                    if erasable.isChecked {
//                        filesToDelete += erasable.filesFound
//                        if categoriesToProcess["Apps Cache"] != nil {
//                            categoriesToProcess["Apps Cache"]!.files += erasable.filesFound
//                        } else {
//                            categoriesToProcess["Apps Cache"] = (erasable.filesFound, false)
//                        }
//                    }
//                }
//                for appSpecificErasable in appInfo.appSpecificErasables {
//                    if appSpecificErasable.isChecked {
//                        filesToDelete += appSpecificErasable.filesFound
//                        if categoriesToProcess["App Specific Files"] != nil {
//                            categoriesToProcess["App Specific Files"]!.files += appSpecificErasable.filesFound
//                        } else {
//                            categoriesToProcess["App Specific Files"] = (appSpecificErasable.filesFound, false)
//                        }
//                    }
//                }
//            }
//        }
//
//        for category in categoryArray {
//            if category.isChecked == true {
//                filesToDelete += category.filesFound
//                    categoriesToProcess[category.name] = (category.filesFound, false)
//                for subcategory in category.subCategories {
//                    filesToDelete += subcategory.filesFound
//                    categoriesToProcess[category.name]!.files += subcategory.filesFound
//                }
//                continue
//            }
//
//            // if subcategories are partially selected
//            for subcategory in category.subCategories {
//                if subcategory.isChecked == true {
//                    if categoriesToProcess[category.name] != nil {
//                        categoriesToProcess[category.name]!.files += subcategory.filesFound
//                    } else {
//                        categoriesToProcess[category.name] = (category.filesFound, false)
//                    }
//                    filesToDelete += subcategory.filesFound
//                }
//            }
//        }
//
//        for lang in languagesList.values {
//            if lang.isChecked {
//                filesToDelete += lang.foundFiles
//                if categoriesToProcess["Additional Languages"] != nil {
//                    categoriesToProcess["Additional Languages"]!.files += lang.foundFiles
//                } else {
//                    categoriesToProcess["Additional Languages"] = (lang.foundFiles, false)
//                }
//            }
//        }
//
//        //        print(filesToDelete.count)
//        //        print(filesToDelete)
//
//        filesToDelete.sort { $0.path < $1.path }
//
//        //        print(filesToDelete.count)
//        //        print(filesToDelete)
//        print(categoriesToProcess.keys)
//        for category in categoriesToProcess.keys {
//            if categoriesToProcess[category]!.files.count > 0 {
//                print("\(category) count \(categoriesToProcess[category]!.files.count)")
//                //                categoriesToProcess[category]!.sort { $0.path < $1.path } //test concorrenza
//                let numberOfElementsPerThread = categoriesToProcess[category]!.files.count / numberOfDeletionThreads
//                //        let extraLastElement = categoriesToProcess[category].count % numberOfDeletionThreads  // i.e. remainder
//                if numberOfElementsPerThread > 0 {
//                    for op in 0..<numberOfDeletionThreads {
//                        //                concurrentAppsQueue.async {
////                        if !categoriesToProcess[category]!.isEmpty {
//                            concurrentDeletionQueue.async {
//                                let start = op * numberOfElementsPerThread
//                                var end = start + numberOfElementsPerThread - 1
//                                if (op == numberOfDeletionThreads - 1) {
//                                    end = categoriesToProcess[category]!.files.count - 1
//                                }
//                                for item in categoriesToProcess[category]!.files[start..<end] {
//                                    // Bail out on errors from the errorHandler.
//                                    //if enumeratorError != nil { break }
//                                    do {
////                                        print(item)
//                                        //                    try FileManager.default.removeItem(at: item)
//                                        // dimensione file cancellati?
//                                    } catch {
//                                        print(error)
//                                        // consoleManager.print("errore 21: \(error)")
//                                    }
//                                }
//                                //                if (op == numberOfDeletionThreads - 1) {
//                                //                }
//                            }
////                        }
//                    }
//                }
//            } else {
//                concurrentDeletionQueue.async {
//                    for item in categoriesToProcess[category]!.files {
//                        // Bail out on errors from the errorHandler.
//                        //if enumeratorError != nil { break }
//                        do {
////                            print(item)
//                            //                    try FileManager.default.removeItem(at: item)
//                            // dimensione file cancellati?
//                        } catch {
//                            print(error)
//                            // consoleManager.print("errore 21: \(error)")
//                        }
//                    }
//                }
//            }
//                concurrentDeletionQueue.async(flags: .barrier) {
//                    print("✅✅✅\(category) DELETION COMPLETED")
//                    categoriesToProcess[category]!.hasFinishedDeletion = true
//                    print( categoriesToProcess[category]!.hasFinishedDeletion)
//                }
//        }
//    }
//}

//func deleteSelectedFilesOLD() {
//    concurrentDeletionQueue.async {
//        var filesToDelete: [URL] = []
//        var pluginsFilesToDelete: (String,[URL]) = ("Apps Plugins",[])
//        var appCacheFilesToDelete: (String,[URL]) = ("Apps Cache",[])
//        var appSpecificFilesToDelete: (String,[URL]) = ("App specific files",[])
//        var categoriesFilesToDelete: [(String,[URL])] = []
//        var languagesFilesToDelete: (String,[URL]) = ("Additional Languages",[])
//        for appInfo in appBundleList.values {
//            for plugin in appInfo.plugins.values {
//                if plugin.isChecked {
//                    filesToDelete += plugin.filesFound
//                }
//            }
//            if appInfo.isChecked {
//                for erasable in appInfo.erasables.values {
//                    if erasable.isChecked {
//                        filesToDelete += erasable.filesFound
//                    }
//                }
//                for appSpecificErasable in appInfo.appSpecificErasables {
//                    if appSpecificErasable.isChecked {
//                        filesToDelete += appSpecificErasable.filesFound
//                    }
//                }
//            }
//        }
//        
//        for category in categoryArray {
//            if category.isChecked == true {
//                filesToDelete += category.filesFound
//                for subcategory in category.subCategories {
//                    filesToDelete += subcategory.filesFound
//                }
//                continue
//            }
//            
//            for subcategory in category.subCategories {
//                if subcategory.isChecked == true {
//                    filesToDelete += subcategory.filesFound
//                }
//            }
//        }
//        
//        for lang in languagesList.values {
//            if lang.isChecked {
//                filesToDelete += lang.foundFiles
//            }
//        }
//        
////        print(filesToDelete.count)
////        print(filesToDelete)
//        
//        filesToDelete.sort { $0.path < $1.path }
//        
////        print(filesToDelete.count)
////        print(filesToDelete)
//        
//        if filesToDelete.count > 0 {
//            let numberOfElementsPerThread = filesToDelete.count / numberOfDeletionThreads
//            //        let extraLastElement = filesToDelete.count % numberOfDeletionThreads  // i.e. remainder
//            
//            for op in 0..<numberOfDeletionThreads {
//                //                concurrentAppsQueue.async {
//                concurrentDeletionQueue.async {
//                    let start = op * numberOfElementsPerThread
//                    var end = start + numberOfElementsPerThread - 1
//                    if (op == numberOfDeletionThreads - 1) {
//                        end = filesToDelete.count - 1
//                    }
//                    for item in filesToDelete[start..<end] {
//                        // Bail out on errors from the errorHandler.
//                        //if enumeratorError != nil { break }
//                        do {
//                            //                    try FileManager.default.removeItem(at: item)
//                            // dimensione file cancellati?
//                        } catch {
//                            print(error)
//                            // consoleManager.print("errore 21: \(error)")
//                        }
//                    }
//                    //                if (op == numberOfDeletionThreads - 1) {
//                    //                }
//                }
//            }
//            
//            concurrentDeletionQueue.async(flags: .barrier) {
//                print("DELETION COMPLETED")
//            }
//        }
//    }
//}

func scanLocalizationFiles() {
    let pathsToScan = [URL(fileURLWithPath:"/System/Library/PrivateFrameworks/CoreEmoji.framework/"),
                       URL(fileURLWithPath:"/Library/Application Support/"),
                       URL(fileURLWithPath:"/Library/Frameworks/"),
                       URL(fileURLWithPath:"/Library/PreferenceBundles/"),
//                       URL(fileURLWithPath:"/Developer/Library/Frameworks/"), //read-only
                       URL(fileURLWithPath:"/Applications/")]
    languagesFilesSYS[0] = languagesList
    for path in pathsToScan {
        let folderEnumerator = FileManager.default.enumerator(at: path,
                                                          includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                          options: [],
                                                          //errorHandler: errorHandler)!
                                                          errorHandler: nil)!
        // Perform the traversal.
        for item in folderEnumerator {
        // Bail out on errors from the errorHandler.
        //if enumeratorError != nil { break }
        
        // Add up individual file sizes.
        let contentItemURL = item as! URL
        if contentItemURL.path.contains(".lproj") {
            for comp in (contentItemURL.path.components(separatedBy: "/")) {
                if comp.contains(".lproj") {
                    let lang = comp.dropLast(6).lowercased().replacingOccurrences(of: "-", with: "_")
                    let size = contentItemURL.regularFileAllocatedSize()
                    contDataLang += size
                    if languagesFilesSYS[0][lang] == nil {
                        let langID = lang.before(first: "_")
                        if let altLang = alternativeLanguageNames[langID] {
                            languagesFilesSYS[0][altLang] = langInfo(name: altLang)
                            languagesFilesSYS[0][altLang]!.foundFiles.append(contentItemURL) //Thread 14: Fatal error: Unexpectedly found nil while unwrapping an Optional value altLang = en, langID = english, lang = english, comp = English.lproj FORSE RISOLTA CON LA RIGA SOPRA
                            languagesFilesSYS[0][altLang]!.size.bytes += size
                        } else {
                            if languagesFilesSYS[0][langID] == nil {
                            // If it matches an extra language code
                            if let extraLanguageName = getExtraLanguageName(for: langID) {
                                // Add it to foundLanguages
                                languagesFilesSYS[0][langID] = langInfo(name: extraLanguageName)
                                languagesFilesSYS[0][langID]!.foundFiles.append(contentItemURL)
                                languagesFilesSYS[0][langID]!.size.bytes += size
                            } else {
                                if undeterminedLanguagesFilesSYS[0][lang] == nil {
                                    undeterminedLanguagesFilesSYS[0][lang] = langInfo(name: lang)
                                }
                                undeterminedLanguagesFilesSYS[0][lang]!.foundFiles.append(contentItemURL)
                                undeterminedLanguagesFilesSYS[0][lang]!.size.bytes += size
                            }
                            } else {
                                languagesFilesSYS[0][langID]!.foundFiles.append(contentItemURL)
                                languagesFilesSYS[0][langID]!.size.bytes += size
                            }
                        }
                    } else {
                        languagesFilesSYS[0][lang]!.foundFiles.append(contentItemURL)
                        languagesFilesSYS[0][lang]!.size.bytes += size
                    }
                    totalErasableFiles += 1
                    break
                }
            }
        }
    }
    }
}

func writeDeletableFilesToFile() {
    
//    let fileURL = URL(fileURLWithPath: "/private/var/mobile/Documents/tavrasa/afoundFiles.txt")
    let fileURL = tempDBFolder.appendingPathComponent("afoundFiles.txt")
    
    createTempDir()
    
    // Create the file if it does not yet exist
    FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    
    if let fileUpdater = try? FileHandle(forUpdating: fileURL) {
        var entryStr = ""
        
        for category in categoryArray {
            entryStr = "\(category.name) : \(category.size.bytes.formatBytes())\n\n"
            for erasableFileURL in category.filesFound {
                entryStr += "\t\(erasableFileURL)\n"
            }
            
            if !(category.subCategories.isEmpty) {
                entryStr += "\n\tSubcategories\n\n"
            }
            
            for subcat in category.subCategories {
                entryStr += "\n\t\(subcat.name)\n\n"
                for erasableFileURL in subcat.filesFound {
                    entryStr += "\t\t\(erasableFileURL)\n"
                }
            }
            
            // Function which when called will cause all updates to start from end of the file
            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(entryStr.data(using: .utf8)!)
        }
        
        for language in languagesList.keys {
            entryStr = "\(languagesList[language]!.name) : \(languagesList[language]!.size.bytes.formatBytes())\n\n"
            languagesList[language]!.foundFiles.sort(by: {$0.path < $1.path})
            for erasableFileURL in languagesList[language]!.foundFiles {
                entryStr += "\t\(erasableFileURL)\n"
            }
            
            // Function which when called will cause all updates to start from end of the file
            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(entryStr.data(using: .utf8)!)
        }
        
        appBundleList.sort()
        for bundle in appBundleList.keys {
            let app = appBundleList[bundle]!.appName
            entryStr = "\(app) : \(appBundleList[bundle]!.size.formatBytes())\n\n"
            
            for erasable in appBundleList[bundle]!.erasables.keys {
                entryStr += "\n\t\(erasable) : \(appBundleList[bundle]!.erasables[erasable]!.bytes.formatBytes())\n\n"
                appBundleList[bundle]!.erasables[erasable]!.filesFound.sort(by: {$0.path < $1.path})
                for erasableFileURL in appBundleList[bundle]!.erasables[erasable]!.filesFound {
                    entryStr += "\t\t\(erasableFileURL)\n"
                }
            }
            
            if !(appBundleList[bundle]!.plugins.isEmpty) {
                entryStr += "\n\tPlugins\n\n"
            }
            
            for plugin in appBundleList[bundle]!.plugins.keys {
                entryStr += "\n\t\t\(plugin) : \(appBundleList[bundle]!.plugins[plugin]!.formatted)\n\n"
                appBundleList[bundle]!.plugins[plugin]!.filesFound.sort(by: {$0.path < $1.path})
                for erasableFileURL in appBundleList[bundle]!.plugins[plugin]!.filesFound {
                    entryStr += "\t\t\t\(erasableFileURL)\n"
                }
            }
            
            entryStr += "\n"
            
            if (appBundleList[bundle]!.appSpecificErasablesSize > 0) {
                entryStr += "\n\tApp Specific Files : \(appBundleList[bundle]!.appSpecificErasablesSize.formatBytes())\n\n"
            }
            
            for index in appBundleList[bundle]!.appSpecificErasables.indices {
                if (appBundleList[bundle]!.appSpecificErasables[index].erasableType == nil) {
                    entryStr += "\n\t\t\(appBundleList[bundle]!.appSpecificErasables[index].erasableName) : \(appBundleList[bundle]!.appSpecificErasables[index].formatted)\n\n"
                    appBundleList[bundle]!.appSpecificErasables[index].filesFound.sort(by: {$0.path < $1.path})
                    for erasableFileURL in (appBundleList[bundle]!.appSpecificErasables[index].filesFound) {
                        entryStr += "\t\t\t\(erasableFileURL)\n"
                    }
                }
            }
            // Function which when called will cause all updates to start from end of the file
            //            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(entryStr.data(using: .utf8)!)
            //                do {
            //                    try dbStr.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            //                } catch {
            //                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            //                }
        }
        
        appUnshrinkableDatabases.sort()
        for app in appUnshrinkableDatabases.keys {
            entryStr = "\(app)\n\n"
            
            for index in appUnshrinkableDatabases[app]!.dbs.indices {
                
                entryStr += "\tSize Increased by:\(abs(appUnshrinkableDatabases[app]!.dbs[index].spaceFreed.bytes).formatBytes()) - \(appUnshrinkableDatabases[app]!.dbs[index].name)\n"
                appUnshrinkableDatabases[app]!.dbs[index].paths.sort()
                for dbFileURL in appUnshrinkableDatabases[app]!.dbs[index].paths {
                    entryStr += "\t\t\(dbFileURL)\n"
                }
                
            }
            // Function which when called will cause all updates to start from end of the file
            //            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(entryStr.data(using: .utf8)!)
            //                do {
            //                    try dbStr.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            //                } catch {
            //                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            //                }
        }
        
        appDatabases.sort()
        for app in appDatabases.keys {
            entryStr = "\(app)\n\n"
            
            appDatabases[app]!.dbs.sort(by: { (db1: Database, db2: Database) -> Bool in
                return db1.name < db2.name
            })
            
            for index in appDatabases[app]!.dbs.indices {
                
                entryStr += "\tFreed:\(appDatabases[app]!.dbs[index].spaceFreed.formatted) - \(appDatabases[app]!.dbs[index].name)\n"
                appDatabases[app]!.dbs[index].paths.sort()
                for dbFileURL in appDatabases[app]!.dbs[index].paths {
                    entryStr += "\t\t\(dbFileURL)\n"
                }
                
            }
            // Function which when called will cause all updates to start from end of the file
//            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(entryStr.data(using: .utf8)!)
            //                do {
            //                    try dbStr.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            //                } catch {
            //                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            //                }
        }
        // Once we convert our new content to data and write it, we close the file and that’s it!
        fileUpdater.closeFile()
    } else {
        print("ERRORE FILES FOUND")
    }
    print("printed all files found, result written to: \(fileURL)")
    if let oracoloURL = Bundle.main.url(forResource: "afoundFiles", withExtension: "txt") {
        if FileManager.default.contentsEqual(atPath: fileURL.path, andPath: oracoloURL.path) {
            print("ORACOLO SI TROVA")
        } else {
            print("ORACOLO DIVERSO")
        }
    } else {
        print("FILE ORACOLO NON TROVATO")
    }
}

func scanAllSystemDbs() {
    // The error handler simply stores the error and stops traversal
    var enumeratorError: Error? = nil
    func errorHandler(url: URL, error: Error) -> Bool {
        enumeratorError = error
        logArr.append(url.description)
        logArr.append(error.localizedDescription)
        consoleManager.print(url)
        consoleManager.print(error)
        return false
    }
    let searchPaths = [
//                "/Developer/",
                               "/Library/",
                               "/private/var/",
//        "/System/",
//                               "/usr/"
    ]
//        let searchPaths = ["/"]
    
    for folderPath in searchPaths {
        // We have to enumerate all directory contents, including subdirectories.
        let rootEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: folderPath),
                                                            //                let rootEnumerator = self.enumerator(at: URL(fileURLWithPath: "/private/var/mobile/Documents/provacontainersBundleApplication"),
                                                            includingPropertiesForKeys: [],
                                                            options: [.skipsSubdirectoryDescendants],
                                                            //errorHandler: errorHandler)!
                                                            errorHandler: nil)!
        
        // Perform the traversal.
        for item in rootEnumerator {
            // Bail out on errors from the errorHandler.
            //            //if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            scanAllDBs(at: contentItemURL)
        }
    }
//    foundDatabases.sort()
    
    let fileURL = tempDBFolder.appendingPathComponent("foundDatabases.txt")
    
    createTempDir()
    // Create the file if it does not yet exist
    FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    if let fileUpdater = try? FileHandle(forUpdating: fileURL) {
        
        for key in foundDatabases.keys {
            var dbStr = "\"\(key)\" : \t["
            let lastDBIndex = foundDatabases[key]!.count - 1
            for index in foundDatabases[key]!.indices {
                var dbNameStr = ""
                if lastDBIndex > 0 {
                    dbNameStr = "\n\t\t\t\t\t\t\t\t\tDatabase(name: \"\(foundDatabases[key]![index].name)\""
                } else {
                    dbNameStr = "Database(name: \"\(foundDatabases[key]![index].name)\""
                }
                var pathsStr = ", paths: ["
                let lastPathIndex = foundDatabases[key]![index].paths.count - 1
                for pathIndex in foundDatabases[key]![index].paths.indices {
                    if pathIndex == lastPathIndex {
                        pathsStr.append("\"\(foundDatabases[key]![index].paths[pathIndex])\"")
                    } else {
                        pathsStr.append("\"\(foundDatabases[key]![index].paths[pathIndex])\", \n")
                    }
                }
                if index == lastDBIndex {
                    pathsStr.append("])")
                } else {
                    pathsStr.append("]),")
                }
                dbStr.append(dbNameStr)
                dbStr.append(pathsStr)
            }
            if lastDBIndex > 0 {
                dbStr.append("\n\t],\n")
            } else {
                dbStr.append("],\n")
            }
            // Function which when called will cause all updates to start from end of the file
            fileUpdater.seekToEndOfFile()
            
            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(dbStr.data(using: .utf8)!)
            //                do {
            //                    try dbStr.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            //                } catch {
            //                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            //                }
        }
        // Once we convert our new content to data and write it, we close the file and that’s it!
        fileUpdater.closeFile()
    }
    logArr.append("scanned all Databases, result written to: \(fileURL)")
    consoleManager.print("scanned all Databases, result written to: \(fileURL)")
}


func scanAllDBs(at folderURL: URL) {
    
    // The error handler simply stores the error and stops traversal
    var enumeratorError: Error? = nil
    func errorHandler(url: URL, error: Error) -> Bool {
        enumeratorError = error
        print(url)
        print(error)
        logArr.append(url.description)
        logArr.append(error.localizedDescription)
        consoleManager.print(url)
        consoleManager.print(error)
        return false
    }
    
    // We have to enumerate all directory contents, including subdirectories.
    let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: folderURL.path),
                                                    includingPropertiesForKeys: [],
                                                    options: [],
                                                    errorHandler: nil)!
    
    // We'll sum up content size here:
    var accumulatedSize: Int64 = 0
    
    // Perform the traversal.
    for item in enumerator {
        
        // Bail out on errors from the errorHandler.
        //if enumeratorError != nil { break }
        
        // Add up individual file sizes.
        let contentItemURL = item as! URL
        
        if !(contentItemURL.path.contains("/Containers/") ||
             contentItemURL.path.contains("/containers/") ||
             contentItemURL.path.contains("/private/var/mobile/Library/Cache") ||
             contentItemURL.path.contains(tempDBFolder.lastPathComponent)) {
            
            for sqlExt in sqlDBExtension {
                //                    if let index = contentItemURL.path.lastIndex(of: ".") {
                //                        if contentItemURL.path.suffix(from: index) == sqlExt {
                //                            var db = Database(name: contentItemURL.lastPathComponent, paths: [contentItemURL.path])
                //                            let dbFolder = contentItemURL.deletingLastPathComponent().path
                //                            if foundDatabases[dbFolder] == nil {
                //                                consoleManager.print("dbFound: \(contentItemURL.path)")
                //                                foundDatabases[dbFolder] = [db]
                //                            } else {
                //                                foundDatabases[dbFolder]!.append(db)
                //                            }
                //                        }
                //                        }
                //                    }
                if contentItemURL.path.hasSuffix(sqlExt) {
                    let db = Database(name: contentItemURL.lastPathComponent, paths: [contentItemURL.path])
                    let dbFolder = contentItemURL.deletingLastPathComponent().path
                    if foundDatabases[dbFolder] == nil {
                        consoleManager.print("dbFound: \(contentItemURL.path)")
                        foundDatabases[dbFolder] = [db]
                    } else {
                        foundDatabases[dbFolder]!.append(db)
                    }
                }
            }
        }
    }
    
}


fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    //    .fileSizeKey,
    .fileAllocatedSizeKey,
    //    .totalFileAllocatedSizeKey,
]

import ApplicationsWrapper
import OrderedCollections

var logArr: [String] = []
var logArr1: [String] = []
var logArr2: [String] = []

//#if targetEnvironment(simulator)
//fileprivate let applicationPaths: [String] = [URL.home.deletingLastPathComponent().path]
//#else
fileprivate let applicationPaths: [String] = [
    "/private/var/containers/Bundle/Application",
    "/private/var/mobile/Containers/Data",
    "/private/var/mobile/Containers/Data/Application",
    "/private/var/mobile/Containers/Shared/AppGroup"
]
//#endif

extension URL {
    
    func regularFileAllocatedSize() -> Int64 {
        var resourceValues: URLResourceValues = URLResourceValues()
        do {
            resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
        } catch {
            consoleManager.print("errore nell'ottenere dimensione allocata del file \(self)")
        }
        
        //        // We only look at regular files.
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }
        
        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return Int64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
    var isDirectory: Bool? {
        
        do {
            return (try resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory)
        }
        catch let error {
            // consoleManager.print(error.localizedDescription)
            return nil
        }
        
    }
    
    var containsAppUUIDSubpaths: Bool {
        for appPath in applicationPaths {
            if self.path.contains(appPath) {
                return true
            }
        }
        return false
    }
    
    var applicationItem: LSApplicationProxy? {
        if self.pathExtension == "app" {
            return ApplicationsManager.shared.application(forBundleURL: self)
        }
        
        return ApplicationsManager.shared.application(forContainerURL: self) ?? ApplicationsManager.shared.application(forDataContainerURL: self)
    }
    
    func deleteAllContents() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: self,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsSubdirectoryDescendants)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  { print(error) }
    }
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
//import SwiftUI
//extension Binding {
//    func unwrapped<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
//        let binding = Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
//        return binding
//    }
//}

extension Int64 {
    func formatBytes() -> String {
        if ((1...1023).contains(self)) { // If the bytes value is between 1 and 1023 bytes, return the bytes size instead of "Nothing to delete"
            return ("\(self) Byte")
        } else if self == 0 {
            return ("Nothing to delete")
        } else {
//            if ByteCountFormatter.string(fromByteCount: self, countStyle: .memory) == "Nothing to delete" {
//                print(self)
//            }
            return ByteCountFormatter.string(fromByteCount: self, countStyle: .memory)
        }
    }
}

extension FileManager {
    
    // -1: Error 0: Source file doesn't exist 1: Copied successfully
    public func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Int {
        if self.fileExists(atPath: srcURL.path) {
            if self.fileExists(atPath: dstURL.path) {
                consoleManager.print("Il file \(dstURL) già esiste, lo sovrascrivo")
                do {
                    try self.removeItem(at: dstURL)
                } catch {
                    consoleManager.print("Non sono riuscito ad eliminare il file \(dstURL) per la sovrascrittura: \(error)")
                    return (-1)
                }
            }
            do {
                try self.copyItem(at: srcURL, to: dstURL)
                return 1
            } catch {
                consoleManager.print("Non sono riuscito a copiare il file \(srcURL): \(error)")
                return (-1)
            }
        } else {
            consoleManager.print("il file \(srcURL) non esiste")
            return 0
        }
    }
}

extension String {
    
    func unaccent() -> String {
        
        return self.folding(options: .diacriticInsensitive, locale: .current)
        
    }
    
}
extension Collection where Element: StringProtocol {
    public func localizedSorted(_ result: ComparisonResult) -> [Element] {
        sorted { $0.localizedCompare($1) == result }
    }
    public func caseInsensitiveSorted(_ result: ComparisonResult) -> [Element] {
        sorted { $0.caseInsensitiveCompare($1) == result }
    }
    public func localizedCaseInsensitiveSorted(_ result: ComparisonResult) -> [Element] {
        sorted { $0.localizedCaseInsensitiveCompare($1) == result }
    }
    /// This method should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate. The exact sorting behavior of this method is different under different locales and may be changed in future releases. This method uses the current locale.
    public func localizedStandardSorted(_ result: ComparisonResult) -> [Element] {
        sorted { $0.localizedStandardCompare($1) == result }
    }
}
extension MutableCollection where Element: StringProtocol, Self: RandomAccessCollection {
    public mutating func localizedSort(_ result: ComparisonResult) {
        sort { $0.localizedCompare($1) == result }
    }
    public mutating func caseInsensitiveSort(_ result: ComparisonResult) {
        sort { $0.caseInsensitiveCompare($1) == result }
    }
    public mutating func localizedCaseInsensitiveSort(_ result: ComparisonResult) {
        sort { $0.localizedCaseInsensitiveCompare($1) == result }
    }
    /// This method should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate. The exact sorting behavior of this method is different under different locales and may be changed in future releases. This method uses the current locale.
    public mutating func localizedStandardSort(_ result: ComparisonResult) {
        sort { $0.localizedStandardCompare($1) == result }
    }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Collection {
    /// This method should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate. The exact sorting behavior of this method is different under different locales and may be changed in future releases. This method uses the current locale.
    public func localizedStandardSorted<T: StringProtocol>(by predicate: (Element) -> T, ascending: Bool = true) -> [Element] {
        sorted { predicate($0).localizedStandardCompare(predicate($1)) == (ascending ? .orderedAscending : .orderedDescending) }
    }
}

extension MutableCollection where Self: RandomAccessCollection {
    /// This method should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate. The exact sorting behavior of this method is different under different locales and may be changed in future releases. This method uses the current locale.
    public mutating func localizedStandardSort<T: StringProtocol>(by predicate: (Element) -> T, ascending: Bool = true) {
        sort { predicate($0).localizedStandardCompare(predicate($1)) == (ascending ? .orderedAscending : .orderedDescending) }
    }
}

//USAGE
//var files: [File] = [.init(id: 2, fileName: "Steve"),
//                     .init(id: 5, fileName: "Bruce"),
//                     .init(id: 3, fileName: "alan")]
//
//let sorted = files.localizedStandardSorted(by: \.fileName)
//consoleManager.print(sorted)  // [File(id: 3, fileName: "alan"), File(id: 5, fileName: "Bruce"), File(id: 2, fileName: "Steve")]
//
//files.localizedStandardSort(by: \.fileName)
//consoleManager.print(files)  // [File(id: 3, fileName: "alan"), File(id: 5, fileName: "Bruce"), File(id: 2, fileName: "Steve")]


