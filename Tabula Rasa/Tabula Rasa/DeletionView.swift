//
//  DeletionView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 21/03/23.
//

import SwiftUI
import LocalAuthentication
import UniformTypeIdentifiers

struct DeletionView: View {
    let totalSizeToDelete: String
    let totalApps: Int
    private let blurHeight: CGFloat = 50
    @State private var showWithDelay = false
    @State private var showSecondDelay = false
    @State private var showThirdDelay = false
    @State private var categoriesToProcess: [String : (files: [URL], hasFinishedDeletion: Bool, isChecked: Tribool)] = [:]
    @State private var deletionDelayTimer: Timer?
    @State private var listDelayTimer: Timer?
    @State private var viewPushAnimationTimer: Timer?
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, Color(UIColor(named: "BackgroundColor")!), Color(UIColor(named: "BackgroundColor")!)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                .opacity(showThirdDelay ? 1 : 0)
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 0) {
                    Text("You will have ")
                    //                    .fixedSize(horizontal: false, vertical: true)
                    //                    .frame(maxWidth: .infinity)
                        .foregroundColor(Color.gray)
                    Text("\(totalSizeToDelete) more")
                        .foregroundColor(Color.white)
                }
                .font(.system(size: 24, weight: .semibold))
                .padding(EdgeInsets(top: 78, leading: 26, bottom: 16, trailing: 26))
                .opacity(showWithDelay ? 1 : 0)
                .offset(y: showWithDelay ? 0 : 20)
                HStack(spacing: 0) {
                    Text("\(totalApps) apps ")
                        .foregroundColor(Color.white)
                    Text("will be ")
                        .foregroundColor(Color.gray)
                    Text("faster")
                        .foregroundColor(Color.white)
                }
                .font(.system(size: 24, weight: .semibold))
                .padding(EdgeInsets(top: 0, leading: 26, bottom: 16, trailing: 26))
                .opacity(showWithDelay ? 1 : 0)
                .offset(y: showWithDelay ? 0 : 20)
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0){
                        Spacer()
                            .frame(height: blurHeight)
                            .frame(maxWidth: .infinity)
                        ForEach(Array(categoriesToProcess.keys).sorted(by: <), id: \.self) { name in
                            VStack(alignment: .leading, spacing: 0){
                                Text(name)
                                    .font(.system(size: 21, weight: .semibold))
//                                    .lineLimit(3)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 26))
                                HStack {
                                    if (categoriesToProcess[name]!.hasFinishedDeletion) {
                                        Text("Cleaned")
                                            .font(.system(size: 16, weight: .semibold))
//                                        Image(systemName: "checkmark.circle")
                                        Image(systemName: "checkmark.circle.fill")
//                                            .resizable()
//                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color(UIColor.systemGreen))
                                            .font(.system(size: 12, weight: .semibold))
                                    } else {
                                        Text("Deleting ")
                                            .font(.system(size: 16, weight: .semibold))
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white)).scaleEffect(0.6)
                                    }
                                }
                                .foregroundColor(Color.gray)
                                .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                            }
                            .blur(radius: showSecondDelay ? 0 : 3)
                            .opacity(showSecondDelay ? 1 : 0)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 39, trailing: 0))
                        }
                        Spacer()
                            .frame(height: blurHeight - 39)
                    }
                }
                .mask(
                    VStack(spacing: 0) {
                        
                        // Bottom gradient
                        LinearGradient(gradient:
                                        Gradient(
                                            colors: [Color.black, Color.black.opacity(0)]),
                                       startPoint: .bottom, endPoint: .top
                        )
                        .frame(height: blurHeight)
                        
                        
//                        // Middle
                        Rectangle().fill(Color.black)
//
                        // Top gradient
                        LinearGradient(gradient:
                                        Gradient(
                                            colors: [Color.black, Color.black.opacity(0)]),
                                       startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: blurHeight)
                    }
                )
                .padding(EdgeInsets(top: 52, leading: 26, bottom: 52, trailing: 26))
            }.onAppear(perform: {
                
                self.viewPushAnimationTimer?.invalidate()
                viewPushAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { _ in
                    print("APPEAR")
                    calculateFilesToDelete()
                    withAnimation(.easeOut(duration: 0.5)) {
                        showWithDelay = true
                    }
                    
                    self.listDelayTimer?.invalidate()
                    listDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                        withAnimation(.easeIn(duration: 0.17)) {
                            showSecondDelay = true
                        }
                    }
                        
                        
                    withAnimation(.easeIn(duration: 2.0)) {
                        showThirdDelay = true
                    }
                    
                    self.deletionDelayTimer?.invalidate()
//                    delay di 0.8 se deleteSelectedFiles() non bloccasse la UI
                    deletionDelayTimer = Timer.scheduledTimer(withTimeInterval: 2.05, repeats: false) { _ in
                        deleteSelectedFiles()
                    }
                }
            })
            .offset(y: showWithDelay ? 0 : 20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "BackgroundColor") ?? .black)
            .edgesIgnoringSafeArea(.all))
    }
    
    func calculateFilesToDelete() {
        
        var filesToDelete: [URL] = []
        //        var categoriesToProcess: [String : [URL]] = [:]
        print(appBundleList.values.count)
        
        var appsCacheChecked = false
        
        // Adds an empty apps cache to the categories to process, only if it was checked already
        for category in categoryArray {
            if category.name == "Apps Cache" {
                if category.isChecked.boolValue || category.isChecked == Tribool.indeterminate{
                    categoriesToProcess["Apps Cache"] = ([], false, category.isChecked)
                    appsCacheChecked = true
                }
                break
            }
        }
        
        for bundleID in appBundleList.keys {
            //                if appBundleList[bundleID]!.isInstalled {
            for plugin in appBundleList[bundleID]!.plugins.values {
                if plugin.isChecked {
                    filesToDelete += plugin.filesFound
                    if categoriesToProcess["App Plugins"] != nil {
                        categoriesToProcess["App Plugins"]!.files += plugin.filesFound
                    } else {
                        categoriesToProcess["App Plugins"] = (plugin.filesFound, false, .indeterminate)
                    }
                }
            }
            if (appBundleList[bundleID]!.isChecked || appsCacheChecked) && appBundleList[bundleID]!.isInstalled {
                print("App checked: \(appBundleList[bundleID]?.appName) - \(bundleID)")
                for erasable in appBundleList[bundleID]!.erasables.values {
                    //                        if erasable.isChecked {
                    filesToDelete += erasable.filesFound
                    if categoriesToProcess["Apps Cache"] != nil {
                        categoriesToProcess["Apps Cache"]!.files += erasable.filesFound
                    } else {
                        categoriesToProcess["Apps Cache"] = (erasable.filesFound, false, .indeterminate)
                    }
                    //                        }
                }
                for appSpecificErasable in appBundleList[bundleID]!.appSpecificErasables {
                    if appSpecificErasable.erasableType == .Cache {
                        filesToDelete += appSpecificErasable.filesFound
                        categoriesToProcess["Apps Cache"]!.files += appSpecificErasable.filesFound
                    } else {
                        filesToDelete += appSpecificErasable.filesFound
                        if categoriesToProcess["App Specific Files"] != nil {
                            categoriesToProcess["App Specific Files"]!.files += appSpecificErasable.filesFound
                        } else {
                            categoriesToProcess["App Specific Files"] = (appSpecificErasable.filesFound, false, .indeterminate)
                        }
                    }
                }
            } else {
                for appSpecificErasable in appBundleList[bundleID]!.appSpecificErasables {
                    if appSpecificErasable.isChecked {
                        filesToDelete += appSpecificErasable.filesFound
                        if categoriesToProcess["App Specific Files"] != nil {
                            categoriesToProcess["App Specific Files"]!.files += appSpecificErasable.filesFound
                        } else {
                            categoriesToProcess["App Specific Files"] = (appSpecificErasable.filesFound, false, .indeterminate)
                        }
                    }
                }
            }
            //                }
        }
        
        for category in categoryArray {
            if category.isChecked == true {
                filesToDelete += category.filesFound
                categoriesToProcess[category.name] = (category.filesFound, false, category.isChecked)
                for subcategory in category.subCategories {
                    filesToDelete += subcategory.filesFound
                    categoriesToProcess[category.name]!.files += subcategory.filesFound
                }
                continue
            }
            
            // if subcategories are partially selected
            for subcategory in category.subCategories {
                if subcategory.isChecked == true {
                    if categoriesToProcess[category.name] != nil {
                        categoriesToProcess[category.name]!.files += subcategory.filesFound
                    } else {
                        categoriesToProcess[category.name] = (category.filesFound, false, .indeterminate)
                    }
                    filesToDelete += subcategory.filesFound
                }
            }
        }
        
        for lang in languagesList.values {
            if lang.isChecked {
                filesToDelete += lang.foundFiles
                if categoriesToProcess["Additional Languages"] != nil {
                    categoriesToProcess["Additional Languages"]!.files += lang.foundFiles
                } else {
                    categoriesToProcess["Additional Languages"] = (lang.foundFiles, false, .indeterminate)
                }
            }
        }
        
        
        let fileURL = tempDBFolder.appendingPathComponent("deletedFiles.txt")
        
        createTempDir()
        // Create the file if it does not yet exist
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        if let fileUpdater = try? FileHandle(forUpdating: fileURL) {
            var deleteFilesStringList = ""
            for url in filesToDelete {
                //                    deleteFilesStringList.append(url.path)
                //                }
                // Function which when called will cause all updates to start from end of the file
                fileUpdater.seekToEndOfFile()
                
                // Which lets the caller move editing to any position within the file by supplying an offset
                fileUpdater.write(url.path.data(using: .utf8)!)
                //                do {
                //                    try dbStr.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
                //                } catch {
                //                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                //                }
            }
            // Once we convert our new content to data and write it, we close the file and that’s it!
            fileUpdater.closeFile()
        }
        
        //        print(filesToDelete.count)
        //        print(filesToDelete)
        
        //            filesToDelete.sort { $0.path < $1.path }
        
        //        print(filesToDelete.count)
        //        print(filesToDelete)
        print(categoriesToProcess.keys)
        print("\(filesToDelete.count) files to delete")
        consoleManager.print(categoriesToProcess.keys)
        consoleManager.print("\(filesToDelete.count) files to delete")
    }
    
    func deleteSelectedFiles() {
        print("Inizio eliminazione")
        consoleManager.isVisible = true
        concurrentDeletionQueue.async {
            
            
//            do {
//                try FSOperation.perform(.removeItems(items: filesToDelete), rootHelperConf: RootConf.shared)
//            } catch {
//                print(error)
//                consoleManager.print("errore eliminazione: \(error)")
//            }
            
                
            for category in categoriesToProcess.keys {
                if categoriesToProcess[category]!.files.count > 0 {
                    consoleManager.print("\(category) files count: \(categoriesToProcess[category]!.files.count)")
                    //                categoriesToProcess[category]!.sort { $0.path < $1.path } //test concorrenza
                    let numberOfElementsPerThread = categoriesToProcess[category]!.files.count / numberOfDeletionThreads
//                            let extraLastElement = categoriesToProcess[category].count % numberOfDeletionThreads  // i.e. remainder
                    if numberOfElementsPerThread > 0 {
                        for op in 0..<numberOfDeletionThreads {
                            concurrentAppsQueue.async {
                                if !categoriesToProcess[category]!.files.isEmpty {
                                    concurrentDeletionQueue.async {
                                        let start = op * numberOfElementsPerThread
                                        var end = start + numberOfElementsPerThread - 1
                                        if (op == numberOfDeletionThreads - 1) {
                                            end = categoriesToProcess[category]!.files.count - 1
                                        }
                                        if op == 0 {
                                            consoleManager.print("\(category) \(op) start: \(start) end: \(end) blocksize: \(numberOfElementsPerThread)")
                                        } else if op == (numberOfElementsPerThread - 1) {
                                            consoleManager.print("\(category) \(op) start: \(start) end: \(end) blocksize: \(numberOfElementsPerThread) end matches: \(categoriesToProcess[category]!.files.count == end)")
                                        } else {
                                            if end - start != numberOfElementsPerThread {
                                                consoleManager.print("BLOCK SIZE DIFFERENT \(category) \(op) start: \(start) end: \(end) end-start: \(end - start) blocksize: \(numberOfElementsPerThread)")
                                            }
                                        }
                                        for item in categoriesToProcess[category]!.files[start..<end] {
                                            // Bail out on errors from the errorHandler.
                                            //if enumeratorError != nil { break }
                                            do {
                                                //                                                                                print(item)
                                                try FileManager.default.removeItem(at: item)
                                                // dimensione file cancellati?
                                                
                                                
                                        } catch CocoaError.fileNoSuchFile {
                                                print("errore eliminazione: file non trovato")
                                        } catch CocoaError.fileWriteNoPermission {
                                            consoleManager.print("errore eliminazione: fileWriteNoPermission")
                                        } catch  {
                                                print(error)
                                                consoleManager.print("errore eliminazione: \(error)")
                                            }
                                            //                                    do {
                                            //                                        try FSOperation.perform(.removeItems(items: [item]), rootHelperConf: RootConf.shared)
                                            //                                        //                                            try FSOperation.perform(.removeItems(items: categoriesToProcess[category]!.files[start..<end]), rootHelperConf: RootConf.shared)
                                            //
                                            //                                    } catch {
                                            //                                        print(error)
                                            //                                        consoleManager.print("errore eliminazione con root helper: \(error)")
                                            //                                    }
                                        }
                                        //                if (op == numberOfDeletionThreads - 1) {
                                        //                }
                                    }
                                }
                            }
                        }
                        //                } else {
                        //                    concurrentDeletionQueue.async {
                        //                        for item in categoriesToProcess[category]!.files {
                        //                            // Bail out on errors from the errorHandler.
                        //                            //if enumeratorError != nil { break }
                        //                            do {
                        //                                                            print(item)
                        //                                                    try FileManager.default.removeItem(at: item)
                        //                                // dimensione file cancellati?
                        //                            } catch {
                        //                                print(error)
                        //                                 consoleManager.print("errore eliminazione: \(error)")
                        //                            }
                        //                        }
                        //                    }
                    }
                }
                concurrentDeletionQueue.async(flags: .barrier) {
                    print("✅✅✅\(category) DELETION COMPLETED")
                    categoriesToProcess[category]!.hasFinishedDeletion = true
                    print( categoriesToProcess[category]!.hasFinishedDeletion)
                }
                    
            }
        }
    }
}


struct DeletionView_InteractivePreview: View {
    @State var shouldShowDeletionScreen = false
    var body: some View {
        
        NavigationView {
            VStack {
                
                Button(action: {
                    shouldShowDeletionScreen = true
                    print(shouldShowDeletionScreen)
                }) {
                    Text("Show deletion view")
                }
                // Hide Navigation Link
                NavigationLink("", destination:
                                DeletionView(totalSizeToDelete: "13,43 GB", totalApps: 13)
                    .navigationBarTitle("")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true),
                               isActive: $shouldShowDeletionScreen)
                
            }.navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct DeletionView_Previews: PreviewProvider {
    static var previews: some View {
        DeletionView_InteractivePreview()
//        DeletionView(totalSizeToDelete: "13,43 GB", totalApps: 13)
    }
}
