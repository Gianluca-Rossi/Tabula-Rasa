//
//  Category.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 31/12/22.
//

import Foundation
import SwiftUI
import OrderedCollections
import SQLite3

struct Category {
//    let id = UUID()
    var name: String = ""
    var description: String = ""
    var size: (bytes: Int64, formatted: String) = (0, "")
    var isChecked: Tribool = false
    var paths: [URL] = []
    var fileExtensions: [String] = [] // Without the initial dot can be used as the folder suffix
    var fileNameContains: [String] = []
    var subCategories: [Category] = []
    var filesFound: [URL] = []
    var hasFineSelection: Bool = false
    var requiresManualSelection: Bool = false
    var shouldShowList: Bool = false
    var shouldAnalyzeSubfolders: Bool = true
    let alert: String
}

struct PathWithInstructions {
    var path: URL
    var fileExtensions: [String] = [] // Without the initial dot can be used as the folder suffix
    var fileNameContains: [String] = []
    var exclude: [String] = []
    var shouldAnalyzeSubfolders: Bool = true
}

struct Database {
    var name: String = ""
    var size: (bytes: Int64, formatted: String) = (0, "Analyzing")
    var shrinkedSize: (bytes: Int64, formatted: String) = (0, "Analyzing")
    var spaceFreed: (bytes: Int64, formatted: String) = (0, "Analyzing")
    var canBeShrinked = false
    var isChecked: Bool = false
    var paths: [String] = []
    var alert: String = ""
}

var appBundleList: OrderedDictionary<String, AppInfo> = [
//var appList = ThreadSafeDictionary<String,AppInfo>(dict: [
    "com.alibaba.iAliexpress": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["AVFSStorage"],
                            fileNameContains: [], fileExtensions: [], erasableName: "aliexprova", description: "provadescr", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/tlog/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "aliexprova", description: "provadescr", bytes: 0, formatted: "", isChecked: false),
//        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/ShortVideoCache"],
//                            fileNameContains: [], fileExtensions: [], erasableName: "aliexprova", description: "provadescr", bytes: 0, formatted: "", isChecked: false)
    ]),
    "com.amazon.AmazonUK": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["METRICS_NORMAL"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Metrics", description: "provadescr", bytes: 0, formatted: "", isChecked: false),
        //        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/ShortVideoCache"],
        //                            fileNameContains: [], fileExtensions: [], erasableName: "aliexprova", description: "provadescr", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.google.chrome.ios": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["BrowserMetrics"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Metrics", description: "provadescr", bytes: 0, formatted: "", isChecked: false),
        //        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/ShortVideoCache"],
        //                            fileNameContains: [], fileExtensions: [], erasableName: "aliexprova", description: "provadescr", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.apple.DocumentsApp": AppInfo(appSpecificErasables: [
        // non lo trova
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Files app Trash", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Mobile Documents/com~apple~CloudDocs/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "iCloud Drive Trash", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.tigisoftware.Filza": AppInfo(appName: "Filza", appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Caches/ImageTables/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Filza/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Trash", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.ivanobilenchi.icleaner": AppInfo(appName: "iCleaner", appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/iCleaner"],
                            fileNameContains: [], fileExtensions: [".txt"], erasableName: "Analysis and Removed files Log", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
//    "com.exile90.icleanerpro": AppInfo(appName: "iCleaner Pro", appSpecificErasables: [
//        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/iCleaner"],
//                            fileNameContains: [], fileExtensions: [".txt"], erasableName: "Analysis and Removed files Log", description: "", bytes: 0, formatted: "", isChecked: false)
//    ], shouldShowAppSpecificErasables: true),
    "com.burbn.instagram": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["ar_assets_manager_"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Stories Filters", description: "bo", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["Application Support/Instagram/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "boh", description: "bo", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["/messagingMailbox/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Chat Cache", description: "bo", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["/Breakpad/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "crash Cache", description: "bo", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["/Documents/mobileconfig"],
                            fileNameContains: [], fileExtensions: [], erasableName: "boh2", description: "bo", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["Documents"],
                            fileNameContains: ["time_in_app"], fileExtensions: [], erasableName: "boh", description: "bo", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.apple.Keynote": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Mobile Documents/com~apple~Keynote/Documents/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Apple Keynote cloud documents trash", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    "com.apple.MobileSMS": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Avatar/Stickers/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Animoji stickers cache", description: "t", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    "com.apple.mobilemail": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, erasableType: .Cache, subPaths: ["/private/var/mobile/Library/Mail/MessageData"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Cached e-mails", description: "Cached e-mail data and attachments from the iOS mail client.", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, erasableType: .Cache, subPaths: ["/private/var/mobile/Library/Mail/AttachmentData"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Cached attachments", description: "Cached e-mail attachments from the iOS mail client.", bytes: 0, formatted: "", isChecked: false),
    ]),// shouldShowAppSpecificErasables: true),
    // Non vengono riscaricate
//    "com.apple.mobilenotes": AppInfo(appSpecificErasables: [
//        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["/Previews/"],
//                            fileNameContains: [], fileExtensions: [], erasableName: "Previews", description: "thumbnails of links, files, and photos, the original images are still there", bytes: 0, formatted: "", isChecked: false),
//    ], shouldShowAppSpecificErasables: true),
    "com.apple.Numbers": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Mobile Documents/com~apple~Numbers/Documents/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Apple Numbers cloud documents trash", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    "com.apple.Pages": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Mobile Documents/com~apple~Pages/Documents/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Apple Pages cloud documents trash", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    //rompe le modifiche fatte e non carica le anteprime
//    "com.adobe.lrmobilephone": AppInfo(appSpecificErasables: [
//        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/blobs/"],
//                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", bytes: 0, formatted: "", isChecked: false)
//    ]),
    "com.lexwarelabs.goodmorning": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["Documents/unknownSounds/"],
                            fileNameContains: [], fileExtensions: ["m4a","raw"], erasableName: "Recorded sounds", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    "com.google.Maps": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["OfflineData"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Offline Maps", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["GMSCacheStorage"],
                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["CachedRoutes"],
                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    "com.apple.mobileslideshow": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["File Provider Storage"],
                            fileNameContains: [], fileExtensions: [""], erasableName: "Cache del photo picker?", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Media/PhotoData/"],
                            fileNameContains: ["PhotoCloudSharingData"], fileExtensions: [""], erasableName: "iCloud shared albums cache", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Media/PhotoData/Thumbnails/"],
                            fileNameContains: [], fileExtensions: [".ithmb"], erasableName: "Thumbnails cache", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    "com.apple.Playground": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Mobile Documents/iCloud~com~apple~Playgrounds/Documents/.Trash/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Playground iCloud documents trash", description: "", bytes: 0, formatted: "", isChecked: false),
    ], shouldShowAppSpecificErasables: true),
    // Safari
    "com.apple.mobilesafari": AppInfo(appSpecificErasables: [
        //disabilito perche senno oracolo diverso
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Safari/"],
                            fileNameContains: ["BrowserState", "History"], fileExtensions: [], erasableName: "Safari History?", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Library/Cookies"],
                            fileNameContains: ["Cookies.binarycookies"], fileExtensions: [], erasableName: "Cookies", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/Library/Safari/Thumbnails/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Websites Thumbnails??", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    // Snapchat
    "com.toyopagroup.picaboo": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["com.snap.file_manager_4_SCContent_"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Filters", description: "desc", bytes: 0, formatted: "", isChecked: false)
    ]),
    // Telegram
    "ph.telegra.Telegraph": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["/postbox/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Media & messages cache", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["/spotlight/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Contacts page profile pic cache", description: "desc", bytes: 0, formatted: "", isChecked: false),
//        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["/broadcast-coordination/"],
//                            fileNameContains: [], fileExtensions: [], erasableName: "Broadcast", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["/accounts-metadata/media/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Wallpapers cache?", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/Documents/legacy/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "?", description: "desc", bytes: 0, formatted: "", isChecked: false),
        
    ]),
    // Telephone
    "com.apple.mobilephone": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/mobile/Library/Voicemail/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Voice mail recordings", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.custom, subPaths: ["/private/var/wireless/Library/CallHistory"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Call History", description: "desc", bytes: 0, formatted: "", isChecked: false),
        
    ], shouldShowAppSpecificErasables: true),
    "com.subito.subito": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/"],
                            fileNameContains: ["PulseEvent.sqlite", "MessagingCoreData.sqlite"], fileExtensions: [], erasableName: "?", description: "desc", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/AttachmentsSaved/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Immagini scambiate nei messaggi", description: "desc", bytes: 0, formatted: "", isChecked: false),
        
    ], shouldShowAppSpecificErasables: true),
    // TikTok
    "com.zhiliaoapp.musically": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/alog/", "applog.tttracker", "applog.bdtracker"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Logs & Tracking", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["aweIMStickerPackage", "AWEIMRoot"],
                            fileNameContains: [], fileExtensions: [], erasableName: "iMessage Stickers cache?", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["com.bytedance.ies"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Filters", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["WatchHistory"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Watch History", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["CampaignRootFolder"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Ads", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/Heimdallr/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Telemetry", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["AWEResource"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Sounds cache", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["/Pitaya/", "Application Support", "/tracker"],
                            fileNameContains: [], fileExtensions: [], erasableName: "boh", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["Documents/com.autocut.effect/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "video models", description: "", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["Documents/kAWEPublishLocalVideoStorageFolder/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "published videos", description: "", bytes: 0, formatted: "", isChecked: false)
    ], shouldShowAppSpecificErasables: true),
    // FaceApp
    "io.faceapp.ios": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContSharedApp, erasableType: .Cache, subPaths: ["/LastEdited/"],
                            fileNameContains: [], fileExtensions: [], erasableName: "cached images opened for editing", description: "desc", bytes: 0, formatted: "", isChecked: false)
    ]),//, shouldShowAppSpecificErasables: true),
    // Whatsapp display name has a special W character, whatsapp bundle ID has a special character before net.
    "net.whatsapp.WhatsApp": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Message/Media"],
                            fileNameContains: [], fileExtensions: [".opus"], erasableName: "Audio messages" , description: "???", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Message/Media"],
                            fileNameContains: [], fileExtensions: [".webp"], erasableName: "Stickers" , description: "???", bytes: 0, formatted: "", isChecked: false),
        appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Media/Profile"],
                            fileNameContains: [], fileExtensions: [], erasableName: "Profile Pictures?", description: "Profile Pictures?", bytes: 0, formatted: "", isChecked: false),
//                    (appPath.ContSharedApp, subPaths: ["/Library/Caches/png-images-v2/"],
//                                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", 0, "", false),
//                    (appPath.ContSharedApp, subPaths: ["/Library/Caches/mmapped-images/"],
//                                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", 0, "", false)
    ], shouldShowAppSpecificErasables: true),
    // Youtube
    "com.google.ios.youtube": AppInfo(appSpecificErasables: [
        appSpecificErasable(appPath: appPath.ContDataApp, erasableType: .Cache, subPaths: ["Carida_Files"],
                            fileNameContains: [], fileExtensions: [], erasableName: "", description: "", bytes: 0, formatted: "", isChecked: false)
    ]),
]


//var appGroupList: [String: AppGroupInfo] = [:]
//var appGroupList: [String:String] = [:]
// These needs to be hardcoded because the groups in the entitlement voice of the default apps in /Applications/ folder contain each other groups
var appGroupList: [String:String] = [
//                                     "group.com.apple":"Messages",
                                     "group.com.apple.iBooks":"com.apple.iBooks",
                                     "group.com.apple.icloud.fm":"com.apple.findmy", //solo per testare con cartelle di prova in mobile documents
                                     "group.com.apple.calendar":"com.apple.mobilecal",
                                     "group.com.apple.DocumentManager":"com.apple.DocumentsApp",
                                     "group.com.apple.mail":"com.apple.mobilemail",
                                     "group.com.apple.Maps":"com.apple.Maps",
                                     "group.com.apple.Music":"com.apple.Music",
                                     "group.com.apple.news":"com.apple.news",
                                     "group.com.apple.FileProvider.LocalStorage":"com.apple.DocumentsApp",
                                     "group.com.apple.Photos.PhotosFileProvider":"com.apple.mobileslideshow",
                                     "group.com.apple.notes":"com.apple.mobilenotes",
                                     "group.com.apple.reminders":"com.apple.reminders",
                                     "group.com.apple.tips":"com.apple.tips",
                                     "group.com.apple.safari":"com.apple.mobilesafari",
                                     "group.com.apple.stocks":"com.apple.stocks",
                                     "group.com.apple.stocks-news":"com.apple.news",
//                                     "group.com.apple":"Watch",
                                     "group.com.apple.weather":"com.apple.weather"
                                    ]
//var appBundleList: [String:String] = [:]

public struct AppInfo {
    var appName: String = ""
    //var containersBundleApplicationUUID: String
    var icon: UIImage? = nil
    var plugins: OrderedDictionary<pluginType, erasableData> = [:]
    var erasables: OrderedDictionary<erasableType, erasableData> = [:]
    var appSpecificErasables: [appSpecificErasable] = []
    var appSpecificErasablesSize: Int64 = 0
    var shouldShowAppSpecificErasables: Bool = false
    var size: Int64 = 0
    var formattedSize: String = "Analyzing"
    var isChecked: Bool = false
    var isSubMenuOpen: Bool = false
    var isInstalled = false
//    var databases: [appDatabase] = []
//    var selectableErasables: [AppErasables]
}

struct erasableData {
    var bytes: Int64
    var formatted: String = ""
    var filesFound: [URL] = []
    var isChecked: Bool = false
    var shouldShowDescription: Bool = false
}

struct appSpecificErasable: Identifiable {
    let id = UUID()
    var appPath: appPath = .custom
    var erasableType: erasableType? = nil
    var subPaths: [String] = []
    var fileNameContains: [String] = []
    var fileExtensions: [String] = []
    var filesFound: [URL] = []
    var erasableName: String = ""
    var description: String = ""
    var bytes: Int64 = 0
    var formatted: String = ""
    var isChecked: Bool = false
    var shouldShowDescription: Bool = false
}

public struct DatabasesInfo {
    var dbs: [Database]
    var isChecked: Bool = false
    var totalShrinkableSize: (bytes: Int64, formatted: String) = (0, "Uncompressable")
}

public struct appDatabase {
    var dbPathType: appPath = .custom
    var db: Database
    var fileNameContains: [String] = []
}

struct AppGroupInfo {
    var uuid: String
    //var containersBundleApplicationUUID: String
    var erasableCategories: [erasableType : (bytes: Int64, formatted: String)] = [:]
//    var selectableErasables: [AppErasables]
}

enum appPath: Int {
    case ContDataApp = 0
    case ContSharedApp = 1
//    case contBundleApp
    case custom = 2
}

struct PluginInfo {
    var fileNameContains: [String] = []
    var size: (Int64, String) = (0, "Analyzing")
}

let AppPlugins: [(name: pluginType, fileNameContains: String)] = [
    (.Siri, fileNameContains: "Siri"),
    (.AppleWatch, fileNameContains: "Watch"),
    (.Widgets, fileNameContains: "WidgetKitExtension"),
    (.iMessage, fileNameContains: "MessagesExtension"),
    (.Share, fileNameContains: "ShareExtension"),
    (.Notifications, fileNameContains: "NotificationExtension"),
    (.Today, fileNameContains: "TodayExtension"),
    (.Wallet, fileNameContains: "WalletExtension")
    //(.Wallet, fileNameContains: ["WalletExtension", "WalletAuthExtension"])
]

let AppGroupsErasables: [(name: erasableType, fileNameContains: [String], fileExtensions: [String])] = [
    (.Cache,
        fileNameContains: ["cache/", "Cache/", "caches/", "Caches/", "tmp/", "Tmp/", "Temp/", "/temp/", "/WebKit/", "/com.apple.SafariViewService/", "/Snapshots/", "/Saved Application State/", "/CloudKit/", "analytics", "/Log/", "/log/", "/Logs/", "/logs/","-Log", "-log", "-Logs", "-logs"],
        fileExtensions: [".tmp", ".log"]),
    (.Drafts, fileNameContains: ["Draft", "draft"], fileExtensions: [])
]

enum erasableType: String, Comparable {
    case Cache
    case Drafts
    static func < (lhs: erasableType, rhs: erasableType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

let erasableTypeDescription: [erasableType:String] = [
    .Cache  : "Non influirà sulla tua esperienza, il contenuto verrà riscaricato se necessario",
    .Drafts : "Drafts found description"
]

//String value is the description
enum pluginType: String, Comparable {
    case iMessage
    case Notifications
    case Share
    case Siri
    case Today
    case Wallet
    case AppleWatch
    case Widgets
    static func < (lhs: pluginType, rhs: pluginType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

let pluginTypeDescription: [pluginType:String] = [
    .AppleWatch  : "",
    .Siri : "",
    .Widgets  : "",
    .iMessage  : "",
    .Share  : "",
    .Notifications  : "",
    .Wallet  : "",
    .Today  : "These allow you to present information in the Notification Center and Lock Screen, and are a great way to provide immediate and up-to-date information that the user is interested in. Today Extensions can also appear on the Search screen, and on the quick action menu on the Home screen when using 3D Touch."
]

struct sysGroup {
    var name: String
    var fileNameContains: [String] = []
    var size: (bytes: Int64, formatted: String) = (0, "Analyzing")
    var alert: String
    var foundFiles: [URL] = []
}

var systemGroups: [String:sysGroup] = [
    "systemgroup.com.apple.powerlog" : sysGroup(name: "Battery Health Data", fileNameContains: ["/BatteryLife/"], alert: "Your battery health will be recalibrated and may appear empty for a while. After 5-10 minutes, the battery health will appear Battery usage and health might not display, wait for it to collect new data")
]

let appPluginSubfolder = "PlugIns/"
let appPluginExtension = ".appex"
let appLanguagesExtension = ".stringdict"

let sqlDBExtension: [String] = [".sqlite", ".sqlite3", ".sql", ".db"]
let mongoDBExtension: [String] = [".realm"]
let mongoDBAuxiliaryFilesExtension: [String] = [".realm.lock",".realm.note",".realm.management"]
let sqlDBSupportingFilesExtension: [String] = ["", "-wal", "-shm", ".aside-shm", ".aside-wal"] // First one is used when scorro l'array cosi copio il db originale
import SQLite

func appDB(application_identifier: String) {
    
    let appDBURL: URL = URL(fileURLWithPath: "/private/var/mobile/Documents/prova/applicationState.db")
    
    var db: Connection!
    var vacuumStatementResult: Statement? = nil
    var walStatementResult: Statement? = nil
    vacuumStatementResult = nil
    walStatementResult = nil
    
    do {
        db = try Connection(appDBURL.path)
    } catch {
        print("Errore nella connessione all'app DB \(error)")
    }
    //if isAnSQLDatabase {
    //The file should start with "SQLite format 3"
    //}
    do {
        let kvs = Table("kvs")
        for value in try db.prepare(kvs) {
            print("\(value)")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
        vacuumStatementResult = try db.run("select application_identifier_tab.[application_identifier], kvs.[value] from kvs, key_tab,application_identifier_tab where key_tab.[key]='compatibilityInfo' and kvs.[key] = key_tab.[id] and application_identifier_tab.[id] = kvs.[application_identifier] order by application_identifier_tab.[id]")
        print(vacuumStatementResult)
        //walStatementResult = try db.run("PRAGMA wal_checkpoint(truncate)")
    } catch {
        print("ABORTING DB Shrinking for: appDB Error on query vacuumStatementResult: \(String(describing: vacuumStatementResult)) walStatementResult: \(String(describing: walStatementResult)) \(error)")
    }
    

}

let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let tempDBFolder = documentsDirectory.appendingPathComponent("tempDatabasesCompressingFolder/")

func createTempDir() -> Bool {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: tempDBFolder.absoluteString, isDirectory: &isDirectory)
    // DA CONTROLLARE
    if !(exists && isDirectory.boolValue) {
        do {
            try FileManager.default.createDirectory(atPath: tempDBFolder.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("ABORTING DB Shrinking NON HO POTUTO CREARE LA CARTELLA \(error)")
            logArr.append("ABORTING DB Shrinking NON HO POTUTO CREARE LA CARTELLA \(error)")
            //        logArr.append("ABORTING DB Shrinking NON HO POTUTO CREARE LA CARTELLA \(error)")
            return false
        }
    } else {
        print("The temporary folder already exists")
        logArr.append("The temporary folder already exists")
        return true
    }
    print("Temporary folder created")
    logArr.append("Temporary folder created")
    return true
}

// Returns 1 if copied successfully, 0 if not copied, -1 if error occurred
func copyDatabaseToTemporaryFolder(dbURL: URL) -> (Int, URL?) {
    let fileName = dbURL.lastPathComponent
    let tempDBFolderWithFileName = tempDBFolder.appendingPathComponent(fileName)
    var result: Int = 0
    var destPathWithFile: URL?
    for dbExt in sqlDBSupportingFilesExtension {
        let originPathWithFile = URL(fileURLWithPath: dbURL.path.appending(dbExt))
        let destPathWithFile = URL(fileURLWithPath: tempDBFolderWithFileName.path.appending(dbExt))
            result = try FileManager.default.secureCopyItem(at: originPathWithFile, to: destPathWithFile)
        if result == -1 {
//            logArr.append("Cannot copy item at \(originPathWithFile) to \(destPathWithFile): \(error)")
            print("Cannot copy item at \(originPathWithFile) to \(destPathWithFile)")
            if dbExt == "" {
                return (-1, nil)
            }
        }
    }
    //DA FIXARE RESULT RITORNA IL VALORE solo DELL'ultimo file copiato
    return (result, destPathWithFile)
}

// Returns 1 if copied successfully, 0 if not copied, -1 if error occurred
func copyDatabaseToTemporaryFolderV2(dbURL: URL) -> (Int, URL?) {
    let fileName = dbURL.lastPathComponent
    let tempDBFolderWithFileName = tempDBFolder.appendingPathComponent(fileName)
    var result: Int = 0
    var originPathWithFile: URL
    var destPathWithFile: URL
    for dbExt in sqlDBSupportingFilesExtension {
        originPathWithFile = URL(fileURLWithPath: dbURL.path.appending(dbExt))
        destPathWithFile = URL(fileURLWithPath: tempDBFolderWithFileName.path.appending(dbExt))
        result = FileManager.default.secureCopyItem(at: originPathWithFile, to: destPathWithFile)
        if result == 0 {
            if dbExt == "" {
                return (-1, nil)
            }
        }
        if result == -1 {
//            logArr.append("Cannot copy item at \(originPathWithFile) to \(destPathWithFile): \(error)")
            print("Cannot copy item at \(originPathWithFile) to \(destPathWithFile)")
                return (-1, nil)
        }
    }
    //DA FIXARE RESULT RITORNA IL VALORE solo DELL'ultimo file copiato
    return (result, tempDBFolderWithFileName)
}

////func shrinkDatabase(_ dbData: inout Database, shouldApplyShrinking: Bool = false) -> ([String], Int64) {
func shrinkDatabase( _ dbData: inout Database, shouldApplyShrinking: Bool = false) -> (AtomicArray<String>, Int64) {
    var log = AtomicArray<String>()
    var _: Int64 = 0
    var spaceFreed: Int64 = 0
    var vacuumStatementResult: Statement? = nil
    var walStatementResult: Statement? = nil
    var didCopyDBToTempFolder = 0
    var didOverwriteDB = 0


    //    if !FileManager.default.fileExists(atPath: tempDBFolder.absoluteString) {
//createTempDir()
    //    }

    for path in dbData.paths {
        let pathURL = URL(fileURLWithPath: path)

        let fileName = pathURL.lastPathComponent
        let tempDBFolderWithFileName = tempDBFolder.appendingPathComponent(fileName)

        var initialTotalDBSize: Int64 = 0
        var size: Int64 = 0
        var originPathWithFile: URL
        var destPathWithFile: URL
        var db: Connection?
        var existingDbExtension: [String] = []

            for dbExt in sqlDBSupportingFilesExtension {
                originPathWithFile = URL(fileURLWithPath: pathURL.path.appending(dbExt))
                destPathWithFile = URL(fileURLWithPath: tempDBFolderWithFileName.path.appending(dbExt))
                do {
                    didCopyDBToTempFolder = try FileManager.default.secureCopyItem(at: originPathWithFile, to: destPathWithFile)
//                    didCopyDBToTempFolder = try FileManager.default.secureCopyItem(
//                        at: originPathWithFile,
//                        to: destPathWithFile)
                } catch {
                    logArr.append("ABORTING DB Shrinking for: \(dbData.name) Cannot copy item at \(originPathWithFile) to \(destPathWithFile): \(error)")
                    print("ABORTING DB Shrinking for: \(dbData.name) Cannot copy item at \(originPathWithFile) to \(destPathWithFile): \(error)")
                    return (log, spaceFreed)
                }
                if didCopyDBToTempFolder == 0 {
                    if dbExt == "" {
                        logArr.append("Il database: \(originPathWithFile) non esiste, passo al database successivo")
                            print("Il database: \(originPathWithFile) non esiste, passo al database successivo")
                        return (log, spaceFreed)
                    } else {
                        logArr.append("Il file: \(originPathWithFile) non esiste, passo al successivo")
//                        print("Il file: \(originPathWithFile) non esiste, passo al successivo")
                        continue
                    }
                }
                // DA SCRIVERE
                if didCopyDBToTempFolder == -1 {
                    if dbExt == "" {
                        logArr.append("Il database: \(originPathWithFile) non esiste, passo al database successivo")
                            print("Il database: \(originPathWithFile) non esiste, passo al database successivo")
                        return (log, spaceFreed)
                    } else {
                        logArr.append("Il file: \(originPathWithFile) non esiste, passo al successivo")
                        print("Il file: \(originPathWithFile) non esiste, passo al successivo")
                        continue
                    }
                }

                existingDbExtension.append(dbExt)

                do {
                    try size = originPathWithFile.regularFileAllocatedSize()
                } catch {
                    print("Couldn't determine filesize for: \(originPathWithFile) \(error)")
                }

                initialTotalDBSize += size
//                let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
//                logArr.append("Before: \(formattedSize)")
//                print("Before: \(formattedSize)")
            }

            let formattedSize = ByteCountFormatter.string(fromByteCount: initialTotalDBSize, countStyle: .memory)
        consoleManager.print("\(dbData.name) size: \(formattedSize)")
        //COMMENTO PER PROVAARE LA CONCORRENZA
            dbData.size = (initialTotalDBSize, formattedSize)

            vacuumStatementResult = nil
            walStatementResult = nil

            do {
                db = try Connection(tempDBFolderWithFileName.path)
            } catch {
                print("Errore nella connessione al DB \(error)")
                logArr.append("Errore nella connessione al DB \(error)")
                return (log, spaceFreed)
            }
            //if isAnSQLDatabase {
            //The file should start with "SQLite format 3"
            //}
        
        /// enable statement logging
//        db?.trace { print ($0) }
            do {
                vacuumStatementResult = try db?.vacuum()//try db.run("VACUUM;")
                walStatementResult = try db?.run("PRAGMA wal_checkpoint(truncate)")
            } catch {
                logArr.append("ABORTING DB Shrinking for: \(dbData.name) Error on query vacuumStatementResult: \(String(describing: vacuumStatementResult)) walStatementResult: \(String(describing: walStatementResult)) \(error)")
                print("ABORTING DB Shrinking for: \(dbData.name) Error on query vacuumStatementResult: \(String(describing: vacuumStatementResult)) walStatementResult: \(String(describing: walStatementResult)) \(error)")
                for dbExt in existingDbExtension {
                    originPathWithFile = URL(fileURLWithPath: tempDBFolderWithFileName.path.appending(dbExt))
                    destPathWithFile = URL(fileURLWithPath: pathURL.path.appending(dbExt))
                    if !shouldApplyShrinking{
                        //                    db.interrupt()
                        //                    if sqlite3_close(db.handle) != SQLITE_OK {
                        //                        print("error closing database")
                        //                    }
                        do {
                            try FileManager.default.removeItem(at: originPathWithFile)
                        } catch {
                            print(error)
                        }
                    }
                }
                return (log, spaceFreed)
            }
            var totalDBShrinkedSize: Int64 = 0
            size = 0
        
//            sqlite3_close_v2(db?.handle)------==
            db = nil
            for dbExt in existingDbExtension {
                originPathWithFile = URL(fileURLWithPath: tempDBFolderWithFileName.path.appending(dbExt))
                destPathWithFile = URL(fileURLWithPath: pathURL.path.appending(dbExt))
                if shouldApplyShrinking {
                        didOverwriteDB = try FileManager.default.secureCopyItem(
                            at: originPathWithFile,
                            to: destPathWithFile)
                    if didOverwriteDB == -1 {
                        logArr.append("ABORTING DB Shrinking for: \(dbData.name) Cannot copy item at \(originPathWithFile) to \(destPathWithFile)")
                        print("ABORTING DB Shrinking for: \(dbData.name) Cannot copy item at \(originPathWithFile) to \(destPathWithFile)")
                        // RICOPIA I FILE SOVRASCRITTI
                        return (log, spaceFreed)
                    }
                    logArr.append("Compression and overwriting succedeed, \(destPathWithFile) After: \(formattedSize)")
                    print("Compression and overwriting succedeed, \(destPathWithFile) After: \(formattedSize)")
                    if didOverwriteDB == -1 {
                        if dbExt == "" {
                            logArr.append("Il database: \(originPathWithFile) non è stato sovrascritto, ripristino i restanti file")
                                print("Il database: \(originPathWithFile) non è stato sovrascritto, ripristino i restanti file")
                            // Ripristina i restanti file
                            return (log, spaceFreed)
                        } else {
                            logArr.append("Il file: \(originPathWithFile) non è stato sovrascritto, ripristino i file del database")
                            print("Il file: \(originPathWithFile) non è stato sovrascritto, ripristino i file del database")
                            // Ripristina tutti i file originali del database
                            continue
                        }
                    }
                }


                do {
                    if shouldApplyShrinking{
                        // The database has been copied back to its original path
                        try size = destPathWithFile.regularFileAllocatedSize()
                    } else {
                        // The database is in the temp folder
                        try size = originPathWithFile.regularFileAllocatedSize()
                    }
                } catch {
                    print("2Couldn't determine filesize for: \(destPathWithFile) \(error)")
                }
                totalDBShrinkedSize += size
//                let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .memory)
//                if !shouldApplyShrinking {
//                    logArr.append("Size after compression: \(formattedSize)")
//                    print("Size after compression, \(destPathWithFile) After: \(formattedSize)")
//                }

                // da rimuovere
                //                                if !didOverwriteDB {
                //                                    logArr.append("Cannot copy item at \(pathURL) to \(tempDBFolder)")
                //                                    print("Cannot copy item at \(pathURL) to \(tempDBFolder)")
                //                                    return log
                //                                }
                
                if !shouldApplyShrinking{
                    do {
                        try FileManager.default.removeItem(at: originPathWithFile)
                    } catch {
                        print(error)
                    }
                }
                
            }
            let formattedTotalDBSize = ByteCountFormatter.string(fromByteCount: totalDBShrinkedSize, countStyle: .memory)
        consoleManager.print("\(dbData.name) size: \(formattedTotalDBSize)")
        //COMMENTO PER PROVAARE LA CONCORRENZA
        dbData.shrinkedSize = (totalDBShrinkedSize, formattedTotalDBSize)

        spaceFreed = initialTotalDBSize - totalDBShrinkedSize
        var formattedSpaceFreed = ""
        if spaceFreed > 0 {
            dbData.canBeShrinked = true
            if spaceFreed < 1024 {
                let sizeStr = ByteCountFormatter.string(fromByteCount: spaceFreed, countStyle: .memory)
                let formattedSizeComponents = sizeStr.components(separatedBy: " ")
                if !formattedSizeComponents.isEmpty {
                    formattedSpaceFreed = formattedSizeComponents.first! + "bit"
                }
            } else {
                    formattedSpaceFreed = ByteCountFormatter.string(fromByteCount: spaceFreed, countStyle: .memory)
                }
            }
            dbData.spaceFreed = ((initialTotalDBSize - totalDBShrinkedSize), formattedSpaceFreed)
//            logArr.append("Space freed: \(formattedSpaceFreed)")
        print("\(dbData.name) space freed: \(formattedSpaceFreed)")
//
//            logArr.append("Total changes: \(db.totalChanges)")    // 3
//            logArr.append("changes: \(db.changes)")
    }
    return (log, spaceFreed)
}

var languagesFiles: OrderedDictionary<String, [URL]> = [:]

//var systemDatabases: [Database] = [
    var systemDatabases = AtomicArray<Database>([
    Database(name: "AddressBookImages", paths: ["/private/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb"], alert: ""),
    Database(name: "Calendar", paths: ["/private/var/mobile/Library/Calendar/Calendar.sqlitedb"]),
    Database(name: "Call History", paths: ["/private/var/mobile/Library/Callhistory/call_history.db"]),
    Database(name: "Data under notes application", paths: ["/private/var/mobile/Library/Notes/notes.sqlite"]),
    Database(name: "iTunes Media Library", paths: ["/private/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb"]),
    Database(name: "Mappe", paths: ["/private/var/mobile/Documents/prova/MapTiles.sqlitedb"]),
    Database(name: "MediaAnalysis", paths: ["/private/var/mobile/Media/MediaAnalysis/mediaanalysis.db"], alert: ""),
    Database(name: "SMS", paths: ["/private/var/mobile/Library/SMS/sms.db"]),
    Database(name: "Voice mail", paths: ["/private/var/mobile/Library/Voicemail/voicemail.db"]),
    Database(name: "Wifi Analytics", paths: ["/private/var/root/Library/Application Support/com.apple.wifianalyticsd/DeviceAnalyticsModel.sqlite"], alert: ""),
//    Database(name: "Whatsapp", paths: [
//        "/private/var/mobile/Containers/Shared/AppGroup/FD29840D-25F2-41EB-83A0-E3EF3733565F/ChatStorage.sqlite",
//        "/private/var/mobile/Containers/Shared/AppGroup/FD29840D-25F2-41EB-83A0-E3EF3733565F/LocalKeyValue.sqlite",
//        "/private/var/mobile/Containers/Shared/AppGroup/FD29840D-25F2-41EB-83A0-E3EF3733565F/fts/ChatSearchV5f.sqlite"
//    ], alert: ""),
//    Database(name: "Zebra", paths: ["/private/var/mobile/Library/“ApplicationSupport”/xyz.willy.Zebra/zebra.db"], alert: "")
//    Database(name: "Photos", paths: ["/private/var/mobile/Media/PhotoData/Photos.sqlite"]),
])

var foundDatabases: OrderedDictionary<String, [Database]> = [:]
//var foundDatabases = ThreadSafeDictionary<String, AtomicArray<Database>>(dict: [:])

var appDatabases: OrderedDictionary<String, DatabasesInfo> = [:]

/// Contains unshrinkable Databases & currently analyzing Databases eeferennces
var appUnshrinkableDatabases: OrderedDictionary<String, DatabasesInfo> = [:]

var appSpecificDatabases: OrderedDictionary<String, [appDatabase]> = [
    "com.adobe.lrmobilephone" : Array<appDatabase>([appDatabase(dbPathType: .ContDataApp, db: Database(name: "Managed Catalog", paths: ["/Documents/"]), fileNameContains: ["Managed Catalog.mcat"]),
                                      appDatabase(dbPathType: .ContDataApp, db: Database(name: "Managed Catalog Index", paths: ["/Documents/"]), fileNameContains: ["Managed Catalog.wfindex"]),
                                      appDatabase(dbPathType: .ContDataApp, db: Database(name: "Managed Catalog Notif", paths: ["/Documents/"]), fileNameContains: ["Managed Catalog.notifdb"]),
                                     ]),
    "com.apple.mobilemail" : Array<appDatabase>([appDatabase(dbPathType: .custom, db: Database(name: "Downloaded Mails Database", paths: ["/var/mobile/Library/Mail/Envelope Index",
                                                                                                               "/var/mobile/Library/Mail/Protected Index"]))]),
    "com.apple.mobilenotes" : Array<appDatabase>([appDatabase(dbPathType: .ContSharedApp, db: Database(name: "Notes Database"), fileNameContains: ["NoteStore.sqlite"])]),
    "com.apple.mobileslideshow" : Array<appDatabase>([appDatabase(dbPathType: .custom, db: Database(name: "Photo Database", paths: ["/private/var/mobile/Media/PhotoData/Photos.sqlite"])),
                                   appDatabase(dbPathType: .custom, db: Database(name: "Media Analysis Database", paths: ["/private/var/mobile/Media/MediaAnalysis/mediaanalysis.db"]))]),
    "com.apple.VoiceMemos" : Array<appDatabase>([appDatabase(dbPathType: .custom, db: Database(name: "Recordings Database", paths: ["/private/var/mobile/Media/Recordings/Recordings.db",
                                                                                                                          "/private/var/mobile/Media/Recordings/CloudRecordings.db"]))]),
    "net.whatsapp.Whatsapp" : Array<appDatabase>([appDatabase(dbPathType: .ContSharedApp, db: Database(name: "Chat Messages Database"), fileNameContains: ["ChatStorage.sqlite"])]),
    
    //Special W
//    "‎WhatsApp" : Array<appDatabase>([appDatabase(dbPathType: .ContSharedApp, db: Database(name: "Chat Messages Database"), fileNameContains: ["ChatStorage.sqlite"])]),
]
//var appDatabases = ThreadSafeDictionary<String, AtomicArray<appDatabase>>(dict: [
//    "Notes" : AtomicArray<appDatabase>([appDatabase(dbPath: .ContSharedApp, db: Database(name: "Notes Database"), fileNameContains: ["NoteStore.sqlite"])]),
//    "Whatsapp" : AtomicArray<appDatabase>([appDatabase(dbPath: .ContSharedApp, db: Database(name: "Chat Messages Database"), fileNameContains: ["ChatStorage.sqlite"])]),
//])


var categoryArray: [Category] = [
    Category(name: "Apps Cache", hasFineSelection: true, alert: ""),
    Category(name: "App Specific Files", hasFineSelection: true, requiresManualSelection: true, alert: ""),
    Category(name: "App Plugins", hasFineSelection: true, requiresManualSelection: true, alert: ""),
    Category(name: "Databases", paths: [], fileNameContains: [], hasFineSelection: true, alert: ""),
    Category(name: "Log files",
             subCategories: [
                Category(name: "fseventsd", paths: [URL(fileURLWithPath:"/.fseventsd"),
                                                    URL(fileURLWithPath:"/private/var/.fseventsd")], alert: ""),
                Category(name: "Applications activity", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/AggregateDictionary/")], alert: ""),
                Category(name: "Library Logs", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Logs/"),
                                                       URL(fileURLWithPath:"/private/var/logs/"),
                                                       URL(fileURLWithPath:"/private/var/log/"),
                                                       URL(fileURLWithPath:"/private/var/root/Library/Logs/"),
                                                       URL(fileURLWithPath:"/private/var/wireless/Library/Logs/")], alert: "")]
             , hasFineSelection: true, alert: ""),
    Category(name: "Siri Suggestions (Screen Time data Application and system activities)", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/CoreDuet/Knowledge/")], alert: ""),
    Category(name: "System Groups", hasFineSelection: true, alert: ""),
    Category(name: "Siri", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Caches/VoiceServices/"),
                                   URL(fileURLWithPath:"/private/var/MobileAsset/AssetsV2/com_apple_MobileAsset_VoiceServicesVocalizerVoice/"),
                                   URL(fileURLWithPath:"/private/var/MobileAsset/AssetsV2/com_apple_MobileAsset_EmbeddedSpeech/"),
                                   URL(fileURLWithPath:"/private/var/mobile/Library/Caches/com.apple.siri.ClientFlow.ScriptCache/"),
                                   URL(fileURLWithPath:"/private/var/mobile/Library/VoiceServices/SpeechCache/"),], hasFineSelection: true, alert: ""), //da testare
    Category(name: "System Cache",
             subCategories: [
                Category(name: "OTA updates", paths: [URL(fileURLWithPath:"/private/var/MobileSoftwareUpdate/"),
                                                      URL(fileURLWithPath:"/private/var/mobile/MobileSoftwareUpdate/"),
                                                      URL(fileURLWithPath:"/private/var/MobileAsset/Assets/com_apple_MobileAsset_SoftwareUpdate/"),
                                                      URL(fileURLWithPath:"/private/var/MobileAsset/Assets/com_apple_MobileAsset_SoftwareUpdateDocumentation/")], alert: ""),
                Category(name: "Cache", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Caches/")], fileNameContains: ["com.vungle.ads", "UnityAds", "google-sdks-events", "googleads", "reddit", "com.apple.keyboards", "WebKit", "sharedCaches", "CacheDeleteAppContainerCaches.deathrow"], alert: "System cache"),
                Category(name: "Other", paths: [URL(fileURLWithPath:"/private/var/db/diagnostics/Special/"),
                                                URL(fileURLWithPath:"/private/var/db/diagnostics/Persist/"),
                                                URL(fileURLWithPath:"/private/var/db/diagnostics/Signpost/"),
                                                URL(fileURLWithPath:"/private/var/db/uuidtext/"),
                                                URL(fileURLWithPath:"/private/var/db/analyticsd/"),
                                                URL(fileURLWithPath:"/private/var/db/systemstats/")], alert: ""),
                    Category(name: "Battery log history", paths: [URL(fileURLWithPath:"/private/var/db/Battery/")], fileExtensions: [], shouldAnalyzeSubfolders: false, alert: ""),
                Category(name: "Bash History", paths: [URL(fileURLWithPath:"/private/var/mobile/")], fileExtensions: [".bash_history"], shouldAnalyzeSubfolders: false, alert: ""),
//                Category(name: "Boh", paths: [URL(fileURLWithPath:"/private/var/root/Library/Caches/")], fileNameContains: ["com.apple.coresymbolicationd", "locationd/consolidated.db"], shouldAnalyzeSubfolders: false, alert: ""),
                Category(name: "Cached Wallpapers", paths: [URL(fileURLWithPath:"/private/var/root/Library/Caches/MappedImageCache/Wallpaper")], fileNameContains: [], shouldAnalyzeSubfolders: false, alert: ""),
                Category(name: "Spotlight Cache", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Spotlight")], fileNameContains: [], shouldAnalyzeSubfolders: false, alert: ""),
                Category(name: "QuickLook thumbnails", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Caches/com.apple.QuickLook.thumbnailcache/thumbnails.data")], fileNameContains: [], shouldAnalyzeSubfolders: false, alert: ""),
                //non c'e su ios 15
                Category(name: "iCloud Backup Data / Documents Versions??", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/a"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/b"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/c"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/d"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/e"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/f"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/g"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/h"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/i"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/j"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/k"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/l"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/m"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/n"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/o"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/p"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/q"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/r"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/s"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/t"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/u"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/v"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/w"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/x"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/y"),
                                                                                  URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/z")], fileNameContains: [], shouldAnalyzeSubfolders: true, alert: ""),
                Category(name: "Ads Cache forse apple ads", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/adc3")], alert: ""),
                Category(name: "Temporary Files", paths: [URL(fileURLWithPath:"/private/var/tmp")], alert: ""),
                Category(name: "Lockscreen Notification Icons cache?", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Intents/Images/")], alert: ""),
                Category(name: "Plugin Cache", paths: [URL(fileURLWithPath:"/private/var/mobile/Containers/Data/PluginKitPlugin/")], fileNameContains: ["Caches", "tmp"], alert: ""),
                Category(name: "Snapshots", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/SplashBoard/Snapshots/")], alert: ""),
                Category(name: "Airdrop cache?", paths: [URL(fileURLWithPath:"/private/var/mobile/Downloads/com.apple.AirDrop/")], alert: ""),
                Category(name: "Webkit root cache", paths: [URL(fileURLWithPath:"/private/var/root/Library/WebKit/")], alert: ""),
                Category(name: "Saved Application State", paths: [URL(fileURLWithPath:"private/var/root/Library/Saved Application State/")], alert: ""),
                Category(name: "Cache delle icone dell app che hanno dati su iCloud", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Application Support/CloudDocs/session/containers/")], alert: ""),
                Category(name: "Spotlight results thumbnails cache", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Spotlight/CoreSpotlight/NSFileProtectionCompleteUntilFirstUserAuthentication/index.spotlightV2/Cache/")], alert: "")]
             , hasFineSelection: true, alert: ""),
//    Category(name: "Last searched Google maps", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Caches/MapTiles/")], fileNameContains: ["MapTiles.sqlitedb"], alert: ""),
//    Category(name: "Google Map History Information", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Maps/")], fileNameContains: ["History.plist", "Directions.plist"], alert: ""),
    Category(name: "Additional Languages", hasFineSelection: true, alert: ""),
    Category(name: "Keyboard autocorrect and predict options", paths: [URL(fileURLWithPath:"/System/Library/LinguisticData/"),
                                                                       URL(fileURLWithPath:"/System/Library/TextInput/")], alert: ""),
//    Category(name: "Accessibility for visual impaired", paths: [URL(fileURLWithPath:"/System/Library/ScreenReader/")], alert: "A screen reader is a software program that uses a braille display or reads text aloud, such as Google’s screen reader TalkBack. People with vision impairments, difficulties reading, or temporarily can’t read might use a screen reader. Screen readers will verbalize the visible content and read it aloud. Paragraph and button text, as well as hidden content like alternative text for icons and headings, are identified by the program. Content can be labelled to optimize the experience for those who use screen readers or experience a text-only version of your UI."),
//    Category(name: "Control center toggles from tweaks", paths: [URL(fileURLWithPath:"/Library/ControlCenter/Bundles/")], alert: ""),
    Category(name: "Keychain analytics", paths: [URL(fileURLWithPath:"/private/var/Keychains/Analytics/")], alert: ""),
    Category(name: "iTunes Artwork", paths: [URL(fileURLWithPath:"/private/var/mobile/Media/iTunes_Control/iTunes/Artwork/")], alert: ""),
    Category(name: "Custom files", hasFineSelection: true, alert: ""),
    //    Category(name: "App Plugins for Siri", paths: [URL(fileURLWithPath:"/private/var/containers/Bundle/Application/")], fileNameContains: ["Siri"]),
    //    Category(name: "App Plugins for Apple Watch", paths: [URL(fileURLWithPath:"/private/var/containers/Bundle/Application/")], fileExtensions: ["Watch"]),
    //    Category(name: "App Plugins for Widget", paths: [URL(fileURLWithPath:"/private/var/containers/Bundle/Application/")], fileExtensions: ["Widget"]),
//        Category(name: "iCloud Drive Trash", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Mobile Documents/com~apple~CloudDocs/.Trash/")], alert: ""),
//        Category(name: "Voice mail recordings", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Voicemail/")], alert: ""),
//        Category(name: "Call History", paths: [URL(fileURLWithPath:"/private/var/wireless/Library/CallHistory")], alert: ""),
//        Category(name: "Animoji stickers cache in messages app", paths: [URL(fileURLWithPath:"/private/var/mobile/Library/Avatar/Stickers/")], alert: ""),
//        Category(name: "iCloud shared albums cache", paths: [URL(fileURLWithPath:"/private/var/mobile/Media/PhotoData/")], fileNameContains: ["PhotoCloudSharingData"], alert: ""),
//        Category(name: "Thumbnails", paths: [URL(fileURLWithPath:"/private/var/mobile/Media/PhotoData/Thumbnails/")], fileExtensions: [".ithmb"], alert: ""),
]

struct langInfo {
    var name: String
    var foundFiles: [URL] = []
    var size: (bytes: Int64, formatted: String) = (0, "Analyzing")
    var isChecked: Bool = false
}

var undeterminedLanguages: OrderedDictionary<String, langInfo> = [:]
var languagesList: OrderedDictionary<String, langInfo> = [
    "aa"    : langInfo(name:    "Afar"    ),
    "ab"    : langInfo(name:    "Abkhazian"    ),
    "ae"    : langInfo(name:    "Avestan"    ),
    "af"    : langInfo(name:    "Afrikaans"    ),
    "af_na"    : langInfo(name:    "Afrikaans (Namibia)"    ),
    "af_za"    : langInfo(name:    "Afrikaans (South Africa)"    ),
    "agq"    : langInfo(name:    "Aghem"    ),
    "ak"    : langInfo(name:    "Akan"    ),
    "ak_gh"    : langInfo(name:    "Akan (Ghana)"    ),
    "am"    : langInfo(name:    "Amharic"    ),
    "am_et"    : langInfo(name:    "Amharic (Ethiopia)"    ),
    "an"    : langInfo(name:    "Aragonese"    ),
    "ar"    : langInfo(name:    "Arabic"    ),
    "ar_ae"    : langInfo(name:    "Arabic (United Arab Emirates)"    ),
    "ar_bh"    : langInfo(name:    "Arabic (Bahrain)"    ),
    "ar_dz"    : langInfo(name:    "Arabic (Algeria)"    ),
    "ar_eg"    : langInfo(name:    "Arabic (Egypt)"    ),
    "ar_iq"    : langInfo(name:    "Arabic (Iraq)"    ),
    "ar_jo"    : langInfo(name:    "Arabic (Jordan)"    ),
    "ar_kw"    : langInfo(name:    "Arabic (Kuwait)"    ),
    "ar_lb"    : langInfo(name:    "Arabic (Lebanon)"    ),
    "ar_ly"    : langInfo(name:    "Arabic (Libya)"    ),
    "ar_ma"    : langInfo(name:    "Arabic (Morocco)"    ),
    "ar_om"    : langInfo(name:    "Arabic (Oman)"    ),
    "ar_qa"    : langInfo(name:    "Arabic (Qatar)"    ),
    "ar_sa"    : langInfo(name:    "Arabic (Saudi Arabia)"    ),
    "ar_sd"    : langInfo(name:    "Arabic (Sudan)"    ),
    "ar_sy"    : langInfo(name:    "Arabic (Syria)"    ),
    "ar_tn"    : langInfo(name:    "Arabic (Tunisia)"    ),
    "ar_ye"    : langInfo(name:    "Arabic (Yemen)"    ),
    "arn"    : langInfo(name:    "Mapudungun"    ),
    "as"    : langInfo(name:    "Assamese"    ),
    "as_in"    : langInfo(name:    "Assamese (India)"    ),
    "asa"    : langInfo(name:    "Asu"    ),
    "asa_tz"    : langInfo(name:    "Asu (Tanzania)"    ),
    "ast"    : langInfo(name:    "Asturian"    ),
    "av"    : langInfo(name:    "Avaric"    ),
    "ay"    : langInfo(name:    "Aymara"    ),
    "az"    : langInfo(name:    "Azerbaijani"    ),
    "az_cyrl"    : langInfo(name:    "Azerbaijani (Cyrillic)"    ),
    "az_cyrl_az"    : langInfo(name:    "Azerbaijani (Cyrillic, Azerbaijan)"    ),
    "az_latn"    : langInfo(name:    "Azerbaijani (Latin)"    ),
    "az_latn_az"    : langInfo(name:    "Azerbaijani (Latin, Azerbaijan)"    ),
    "ba"    : langInfo(name:    "Bashkir"    ),
    "bas"    : langInfo(name:    "Basa (Cameroon)"    ),
    "be"    : langInfo(name:    "Belarusian"    ),
    "be_by"    : langInfo(name:    "Belarusian (Belarus)"    ),
    "bem"    : langInfo(name:    "Bemba"    ),
    "bem_zm"    : langInfo(name:    "Bemba (Zambia)"    ),
    "bez"    : langInfo(name:    "Bena"    ),
    "bez_tz"    : langInfo(name:    "Bena (Tanzania)"    ),
    "bg"    : langInfo(name:    "Bulgarian"    ),
    "bg_bg"    : langInfo(name:    "Bulgarian (Bulgaria)"    ),
    "bh"    : langInfo(name:    "Bihari"    ),
    "bi"    : langInfo(name:    "Bislama"    ),
    "bm"    : langInfo(name:    "Bambara"    ),
    "bm_ml"    : langInfo(name:    "Bambara (Mali)"    ),
    "bn"    : langInfo(name:    "Bengali"    ),
    "bn_bd"    : langInfo(name:    "Bengali (Bangladesh)"    ),
    "bn_in"    : langInfo(name:    "Bengali (India)"    ),
    "bo"    : langInfo(name:    "Tibetan"    ),
    "bo_cn"    : langInfo(name:    "Tibetan (China)"    ),
    "bo_in"    : langInfo(name:    "Tibetan (India)"    ),
    "br"    : langInfo(name:    "Breton"    ),
    "brx"    : langInfo(name:    "Bodo (India)"    ),
    "bs"    : langInfo(name:    "Bosnian"    ),
    "bs_ba"    : langInfo(name:    "Bosnian (Bosnia and Herzegovina)"    ),
    "ca"    : langInfo(name:    "Catalan, Valencian"    ),
    "ca_es"    : langInfo(name:    "Catalan (Spain)"    ),
    "ce"    : langInfo(name:    "Chechen"    ),
    "cgg"    : langInfo(name:    "Chiga"    ),
    "cgg_ug"    : langInfo(name:    "Chiga (Uganda)"    ),
    "ch"    : langInfo(name:    "Chamorro"    ),
    "chr"    : langInfo(name:    "Cherokee"    ),
    "chr_us"    : langInfo(name:    "Cherokee (United States)"    ),
    "cmn_CN"    : langInfo(name:    "Chinese (Mandarin)"    ),
    "co"    : langInfo(name:    "Corsican"    ),
    "cr"    : langInfo(name:    "Cree"    ),
    "cs"    : langInfo(name:    "Czech"    ),
    "cs_cz"    : langInfo(name:    "Czech (Czech Republic)"    ),
    "cu"    : langInfo(name:    "Church Slavonic, Old Slavonic, Old Church Slavonic"    ),
    "cv"    : langInfo(name:    "Chuvash"    ),
    "cy"    : langInfo(name:    "Welsh"    ),
    "cy_gb"    : langInfo(name:    "Welsh (United Kingdom)"    ),
    "da"    : langInfo(name:    "Danish"    ),
    "da_dk"    : langInfo(name:    "Danish (Denmark)"    ),
    "dav"    : langInfo(name:    "Taita"    ),
    "dav_ke"    : langInfo(name:    "Taita (Kenya)"    ),
    "de"    : langInfo(name:    "German"    ),
    "de_at"    : langInfo(name:    "German (Austria)"    ),
    "de_be"    : langInfo(name:    "German (Belgium)"    ),
    "de_ch"    : langInfo(name:    "German (Switzerland)"    ),
    "de_de"    : langInfo(name:    "German (Germany)"    ),
    "de_li"    : langInfo(name:    "German (Liechtenstein)"    ),
    "de_lu"    : langInfo(name:    "German (Luxembourg)"    ),
    "dv"    : langInfo(name:    "Divehi, Dhivehi, Maldivian"    ),
    "dz"    : langInfo(name:    "Dzongkha"    ),
    "ebu"    : langInfo(name:    "Embu"    ),
    "ebu_ke"    : langInfo(name:    "Embu (Kenya)"    ),
    "ee"    : langInfo(name:    "Ewe"    ),
    "ee_gh"    : langInfo(name:    "Ewe (Ghana)"    ),
    "ee_tg"    : langInfo(name:    "Ewe (Togo)"    ),
    "el"    : langInfo(name:    "Greek"    ),
    "el_cy"    : langInfo(name:    "Greek (Cyprus)"    ),
    "el_gr"    : langInfo(name:    "Greek (Greece)"    ),
    "en"    : langInfo(name:    "English"    ),
    "en_as"    : langInfo(name:    "English (American Samoa)"    ),
    "en_au"    : langInfo(name:    "English (Australia)"    ),
    "en_be"    : langInfo(name:    "English (Belgium)"    ),
    "en_bw"    : langInfo(name:    "English (Botswana)"    ),
    "en_bz"    : langInfo(name:    "English (Belize)"    ),
    "en_ca"    : langInfo(name:    "English (Canada)"    ),
    "en_gb"    : langInfo(name:    "English (United Kingdom)"    ),
    "en_gu"    : langInfo(name:    "English (Guam)"    ),
    "en_hk"    : langInfo(name:    "English (Hong Kong SAR China)"    ),
    "en_ie"    : langInfo(name:    "English (Ireland)"    ),
    "en_in"    : langInfo(name:    "English (India)"    ),
    "en_jm"    : langInfo(name:    "English (Jamaica)"    ),
    "en_mh"    : langInfo(name:    "English (Marshall Islands)"    ),
    "en_mp"    : langInfo(name:    "English (Northern Mariana Islands)"    ),
    "en_mt"    : langInfo(name:    "English (Malta)"    ),
    "en_mu"    : langInfo(name:    "English (Mauritius)"    ),
    "en_na"    : langInfo(name:    "English (Namibia)"    ),
    "en_nz"    : langInfo(name:    "English (New Zealand)"    ),
    "en_ph"    : langInfo(name:    "English (Philippines)"    ),
    "en_pk"    : langInfo(name:    "English (Pakistan)"    ),
    "en_sg"    : langInfo(name:    "English (Singapore)"    ),
    "en_tt"    : langInfo(name:    "English (Trinidad and Tobago)"    ),
    "en_um"    : langInfo(name:    "English (U.S. Minor Outlying Islands)"    ),
    "en_us"    : langInfo(name:    "English (United States)"    ),
    "en_us_posix"    : langInfo(name:    "English (United States, Computer)"    ),
    "en_vi"    : langInfo(name:    "English (U.S. Virgin Islands)"    ),
    "en_za"    : langInfo(name:    "English (South Africa)"    ),
    "en_zw"    : langInfo(name:    "English (Zimbabwe)"    ),
    "eo"    : langInfo(name:    "Esperanto"    ),
    "es"    : langInfo(name:    "Spanish, Castilian"    ),
    "es_419"    : langInfo(name:    "Spanish (Latin America)"    ),
    "es_ar"    : langInfo(name:    "Spanish (Argentina)"    ),
    "es_bo"    : langInfo(name:    "Spanish (Bolivia)"    ),
    "es_cl"    : langInfo(name:    "Spanish (Chile)"    ),
    "es_co"    : langInfo(name:    "Spanish (Colombia)"    ),
    "es_cr"    : langInfo(name:    "Spanish (Costa Rica)"    ),
    "es_do"    : langInfo(name:    "Spanish (Dominican Republic)"    ),
    "es_ec"    : langInfo(name:    "Spanish (Ecuador)"    ),
    "es_es"    : langInfo(name:    "Spanish (Spain)"    ),
    "es_gq"    : langInfo(name:    "Spanish (Equatorial Guinea)"    ),
    "es_gt"    : langInfo(name:    "Spanish (Guatemala)"    ),
    "es_hn"    : langInfo(name:    "Spanish (Honduras)"    ),
    "es_mx"    : langInfo(name:    "Spanish (Mexico)"    ),
    "es_ni"    : langInfo(name:    "Spanish (Nicaragua)"    ),
    "es_pa"    : langInfo(name:    "Spanish (Panama)"    ),
    "es_pe"    : langInfo(name:    "Spanish (Peru)"    ),
    "es_pr"    : langInfo(name:    "Spanish (Puerto Rico)"    ),
    "es_py"    : langInfo(name:    "Spanish (Paraguay)"    ),
    "es_sv"    : langInfo(name:    "Spanish (El Salvador)"    ),
    "es_us"    : langInfo(name:    "Spanish (United States)"    ),
    "es_uy"    : langInfo(name:    "Spanish (Uruguay)"    ),
    "es_ve"    : langInfo(name:    "Spanish (Venezuela)"    ),
    "et"    : langInfo(name:    "Estonian"    ),
    "et_ee"    : langInfo(name:    "Estonian (Estonia)"    ),
    "eu"    : langInfo(name:    "Basque"    ),
    "eu_es"    : langInfo(name:    "Basque (Spain)"    ),
    "fa"    : langInfo(name:    "Persian"    ),
    "fa_af"    : langInfo(name:    "Persian (Afghanistan)"    ),
    "fa_ir"    : langInfo(name:    "Persian (Iran)"    ),
    "ff"    : langInfo(name:    "Fulah"    ),
    "ff_sn"    : langInfo(name:    "Fulah (Senegal)"    ),
    "fi"    : langInfo(name:    "Finnish"    ),
    "fi_fi"    : langInfo(name:    "Finnish (Finland)"    ),
    "fil"    : langInfo(name:    "Filipino"    ),
    "fil_ph"    : langInfo(name:    "Filipino (Philippines)"    ),
    "fj"    : langInfo(name:    "Fijian"    ),
    "fo"    : langInfo(name:    "Faroese"    ),
    "fo_fo"    : langInfo(name:    "Faroese (Faroe Islands)"    ),
    "fr"    : langInfo(name:    "French"    ),
    "fr_be"    : langInfo(name:    "French (Belgium)"    ),
    "fr_bf"    : langInfo(name:    "French (Burkina Faso)"    ),
    "fr_bi"    : langInfo(name:    "French (Burundi)"    ),
    "fr_bj"    : langInfo(name:    "French (Benin)"    ),
    "fr_bl"    : langInfo(name:    "French (Saint Barthélemy)"    ),
    "fr_ca"    : langInfo(name:    "French (Canada)"    ),
    "fr_cd"    : langInfo(name:    "French (Congo - Kinshasa)"    ),
    "fr_cf"    : langInfo(name:    "French (Central African Republic)"    ),
    "fr_cg"    : langInfo(name:    "French (Congo - Brazzaville)"    ),
    "fr_ch"    : langInfo(name:    "French (Switzerland)"    ),
    "fr_ci"    : langInfo(name:    "French (Côte d’Ivoire)"    ),
    "fr_cm"    : langInfo(name:    "French (Cameroon)"    ),
    "fr_dj"    : langInfo(name:    "French (Djibouti)"    ),
    "fr_fr"    : langInfo(name:    "French (France)"    ),
    "fr_ga"    : langInfo(name:    "French (Gabon)"    ),
    "fr_gn"    : langInfo(name:    "French (Guinea)"    ),
    "fr_gp"    : langInfo(name:    "French (Guadeloupe)"    ),
    "fr_gq"    : langInfo(name:    "French (Equatorial Guinea)"    ),
    "fr_km"    : langInfo(name:    "French (Comoros)"    ),
    "fr_lu"    : langInfo(name:    "French (Luxembourg)"    ),
    "fr_mc"    : langInfo(name:    "French (Monaco)"    ),
    "fr_mf"    : langInfo(name:    "French (Saint Martin)"    ),
    "fr_mg"    : langInfo(name:    "French (Madagascar)"    ),
    "fr_ml"    : langInfo(name:    "French (Mali)"    ),
    "fr_mq"    : langInfo(name:    "French (Martinique)"    ),
    "fr_ne"    : langInfo(name:    "French (Niger)"    ),
    "fr_re"    : langInfo(name:    "French (Réunion)"    ),
    "fr_rw"    : langInfo(name:    "French (Rwanda)"    ),
    "fr_sn"    : langInfo(name:    "French (Senegal)"    ),
    "fr_td"    : langInfo(name:    "French (Chad)"    ),
    "fr_tg"    : langInfo(name:    "French (Togo)"    ),
    "fy"    : langInfo(name:    "Western Frisian"    ),
    "ga"    : langInfo(name:    "Irish"    ),
    "ga_ie"    : langInfo(name:    "Irish (Ireland)"    ),
    "gd"    : langInfo(name:    "Gaelic, Scottish Gaelic"    ),
    "gl"    : langInfo(name:    "Galician"    ),
    "gl_es"    : langInfo(name:    "Galician (Spain)"    ),
    "gn"    : langInfo(name:    "Guarani"    ),
    "gsw"    : langInfo(name:    "Swiss German"    ),
    "gsw_ch"    : langInfo(name:    "Swiss German (Switzerland)"    ),
    "gu"    : langInfo(name:    "Gujarati"    ),
    "gu_in"    : langInfo(name:    "Gujarati (India)"    ),
    "guz"    : langInfo(name:    "Gusii"    ),
    "guz_ke"    : langInfo(name:    "Gusii (Kenya)"    ),
    "gv"    : langInfo(name:    "Manx"    ),
    "gv_gb"    : langInfo(name:    "Manx (United Kingdom)"    ),
    "ha"    : langInfo(name:    "Hausa"    ),
    "ha_latn"    : langInfo(name:    "Hausa (Latin)"    ),
    "ha_latn_gh"    : langInfo(name:    "Hausa (Latin, Ghana)"    ),
    "ha_latn_ne"    : langInfo(name:    "Hausa (Latin, Niger)"    ),
    "ha_latn_ng"    : langInfo(name:    "Hausa (Latin, Nigeria)"    ),
    "haw"    : langInfo(name:    "Hawaiian"    ),
    "haw_us"    : langInfo(name:    "Hawaiian (United States)"    ),
    "he"    : langInfo(name:    "Hebrew"    ),
    "he_il"    : langInfo(name:    "Hebrew (Israel)"    ),
    "hi"    : langInfo(name:    "Hindi"    ),
    "hi_in"    : langInfo(name:    "Hindi (India)"    ),
    "ho"    : langInfo(name:    "Hiri Motu"    ),
    "hr"    : langInfo(name:    "Croatian"    ),
    "hr_hr"    : langInfo(name:    "Croatian (Croatia)"    ),
    "ht"    : langInfo(name:    "Haitian, Haitian Creole"    ),
    "hu"    : langInfo(name:    "Hungarian"    ),
    "hu_hu"    : langInfo(name:    "Hungarian (Hungary)"    ),
    "hy"    : langInfo(name:    "Armenian"    ),
    "hy_am"    : langInfo(name:    "Armenian (Armenia)"    ),
    "hz"    : langInfo(name:    "Herero"    ),
    "ia"    : langInfo(name:    "Interlingua (International Auxiliary Language Association)"    ),
    "id"    : langInfo(name:    "Indonesian"    ),
    "id_id"    : langInfo(name:    "Indonesian (Indonesia)"    ),
    "ie"    : langInfo(name:    "Interlingue, Occidental"    ),
    "ig"    : langInfo(name:    "Igbo"    ),
    "ig_ng"    : langInfo(name:    "Igbo (Nigeria)"    ),
    "ii"    : langInfo(name:    "Sichuan Yi, Nuosu"    ),
    "ii_cn"    : langInfo(name:    "Sichuan Yi (China)"    ),
    "ik"    : langInfo(name:    "Inupiaq"    ),
    "io"    : langInfo(name:    "Ido"    ),
    "is"    : langInfo(name:    "Icelandic"    ),
    "is_is"    : langInfo(name:    "Icelandic (Iceland)"    ),
    "it"    : langInfo(name:    "Italian"    ),
    "it_ch"    : langInfo(name:    "Italian (Switzerland)"    ),
    "it_it"    : langInfo(name:    "Italian (Italy)"    ),
    "iu"    : langInfo(name:    "Inuktitut"    ),
    "ja"    : langInfo(name:    "Japanese"    ),
    "ja_jp"    : langInfo(name:    "Japanese (Japan)"    ),
    "jmc"    : langInfo(name:    "Machame"    ),
    "jmc_tz"    : langInfo(name:    "Machame (Tanzania)"    ),
    "jv"    : langInfo(name:    "Javanese"    ),
    "ka"    : langInfo(name:    "Georgian"    ),
    "ka_ge"    : langInfo(name:    "Georgian (Georgia)"    ),
    "kab"    : langInfo(name:    "Kabyle"    ),
    "kab_dz"    : langInfo(name:    "Kabyle (Algeria)"    ),
    "kam"    : langInfo(name:    "Kamba"    ),
    "kam_ke"    : langInfo(name:    "Kamba (Kenya)"    ),
    "kde"    : langInfo(name:    "Makonde"    ),
    "kde_tz"    : langInfo(name:    "Makonde (Tanzania)"    ),
    "kea"    : langInfo(name:    "Kabuverdianu"    ),
    "kea_cv"    : langInfo(name:    "Kabuverdianu (Cape Verde)"    ),
    "kg"    : langInfo(name:    "Kongo"    ),
    "khq"    : langInfo(name:    "Koyra Chiini"    ),
    "khq_ml"    : langInfo(name:    "Koyra Chiini (Mali)"    ),
    "ki"    : langInfo(name:    "Kikuyu, Gikuyu"    ),
    "ki_ke"    : langInfo(name:    "Kikuyu (Kenya)"    ),
    "kj"    : langInfo(name:    "Kuanyama, Kwanyama"    ),
    "kk"    : langInfo(name:    "Kazakh"    ),
    "kk_cyrl"    : langInfo(name:    "Kazakh (Cyrillic)"    ),
    "kk_cyrl_kz"    : langInfo(name:    "Kazakh (Cyrillic, Kazakhstan)"    ),
    "kl"    : langInfo(name:    "Kalaallisut, Greenlandic"    ),
    "kl_gl"    : langInfo(name:    "Kalaallisut (Greenland)"    ),
    "kln"    : langInfo(name:    "Kalenjin"    ),
    "kln_ke"    : langInfo(name:    "Kalenjin (Kenya)"    ),
    "km"    : langInfo(name:    "Khmer"    ),
    "km_kh"    : langInfo(name:    "Khmer (Cambodia)"    ),
    "kn"    : langInfo(name:    "Kannada"    ),
    "kn_in"    : langInfo(name:    "Kannada (India)"    ),
    "ko"    : langInfo(name:    "Korean"    ),
    "ko_kr"    : langInfo(name:    "Korean (South Korea)"    ),
    "kok"    : langInfo(name:    "Konkani"    ),
    "kok_in"    : langInfo(name:    "Konkani (India)"    ),
    "kr"    : langInfo(name:    "Kanuri"    ),
    "ks"    : langInfo(name:    "Kashmiri"    ),
    "ku"    : langInfo(name:    "Kurdish"    ),
    "kv"    : langInfo(name:    "Komi"    ),
    "kw"    : langInfo(name:    "Cornish"    ),
    "kw_gb"    : langInfo(name:    "Cornish (United Kingdom)"    ),
    "ky"    : langInfo(name:    "Kirghiz, Kyrgyz"    ),
    "la"    : langInfo(name:    "Latin"    ),
    "lag"    : langInfo(name:    "Langi"    ),
    "lag_tz"    : langInfo(name:    "Langi (Tanzania)"    ),
    "lb"    : langInfo(name:    "Luxembourgish, Letzeburgesch"    ),
    "lg"    : langInfo(name:    "Ganda"    ),
    "lg_ug"    : langInfo(name:    "Ganda (Uganda)"    ),
    "li"    : langInfo(name:    "Limburgan, Limburger, Limburgish"    ),
    "ln"    : langInfo(name:    "Lingala"    ),
    "lo"    : langInfo(name:    "Lao"    ),
    "lt"    : langInfo(name:    "Lithuanian"    ),
    "lt_lt"    : langInfo(name:    "Lithuanian (Lithuania)"    ),
    "lu"    : langInfo(name:    "Luba-Katanga"    ),
    "luo"    : langInfo(name:    "Luo"    ),
    "luo_ke"    : langInfo(name:    "Luo (Kenya)"    ),
    "luy"    : langInfo(name:    "Luyia"    ),
    "luy_ke"    : langInfo(name:    "Luyia (Kenya)"    ),
    "lv"    : langInfo(name:    "Latvian"    ),
    "lv_lv"    : langInfo(name:    "Latvian (Latvia)"    ),
    "mas"    : langInfo(name:    "Masai"    ),
    "mas_ke"    : langInfo(name:    "Masai (Kenya)"    ),
    "mas_tz"    : langInfo(name:    "Masai (Tanzania)"    ),
    "mer"    : langInfo(name:    "Meru"    ),
    "mer_ke"    : langInfo(name:    "Meru (Kenya)"    ),
    "mfe"    : langInfo(name:    "Morisyen"    ),
    "mfe_mu"    : langInfo(name:    "Morisyen (Mauritius)"    ),
    "mg"    : langInfo(name:    "Malagasy"    ),
    "mg_mg"    : langInfo(name:    "Malagasy (Madagascar)"    ),
    "mh"    : langInfo(name:    "Marshallese"    ),
    "mi"    : langInfo(name:    "Maori"    ),
    "mk"    : langInfo(name:    "Macedonian"    ),
    "mk_mk"    : langInfo(name:    "Macedonian (Macedonia)"    ),
    "ml"    : langInfo(name:    "Malayalam"    ),
    "ml_in"    : langInfo(name:    "Malayalam (India)"    ),
    "mn"    : langInfo(name:    "Mongolian"    ),
    "mr"    : langInfo(name:    "Marathi"    ),
    "mr_in"    : langInfo(name:    "Marathi (India)"    ),
    "ms"    : langInfo(name:    "Malay"    ),
    "ms_bn"    : langInfo(name:    "Malay (Brunei)"    ),
    "ms_my"    : langInfo(name:    "Malay (Malaysia)"    ),
    "mt"    : langInfo(name:    "Maltese"    ),
    "mt_mt"    : langInfo(name:    "Maltese (Malta)"    ),
    "my"    : langInfo(name:    "Burmese"    ),
    "my_mm"    : langInfo(name:    "Burmese (Myanmar [Burma])"    ),
    "na"    : langInfo(name:    "Nauru"    ),
    "naq"    : langInfo(name:    "Nama"    ),
    "naq_na"    : langInfo(name:    "Nama (Namibia)"    ),
    "nb"    : langInfo(name:    "Norwegian Bokmål"    ),
    "nb_no"    : langInfo(name:    "Norwegian Bokmål (Norway)"    ),
    "nd"    : langInfo(name:    "North Ndebele"    ),
    "nd_zw"    : langInfo(name:    "North Ndebele (Zimbabwe)"    ),
    "ne"    : langInfo(name:    "Nepali"    ),
    "ne_in"    : langInfo(name:    "Nepali (India)"    ),
    "ne_np"    : langInfo(name:    "Nepali (Nepal)"    ),
    "ng"    : langInfo(name:    "Ndonga"    ),
    "nl"    : langInfo(name:    "Dutch, Flemish"    ),
    "nl_be"    : langInfo(name:    "Dutch (Belgium)"    ),
    "nl_nl"    : langInfo(name:    "Dutch (Netherlands)"    ),
    "nn"    : langInfo(name:    "Norwegian Nynorsk"    ),
    "nn_no"    : langInfo(name:    "Norwegian Nynorsk (Norway)"    ),
    "no"    : langInfo(name:    "Norwegian"    ),
    "nr"    : langInfo(name:    "South Ndebele"    ),
    "nv"    : langInfo(name:    "Navajo, Navaho"    ),
    "ny"    : langInfo(name:    "Chichewa, Chewa, Nyanja"    ),
    "nyn"    : langInfo(name:    "Nyankole"    ),
    "nyn_ug"    : langInfo(name:    "Nyankole (Uganda)"    ),
    "oc"    : langInfo(name:    "Occitan"    ),
    "oj"    : langInfo(name:    "Ojibwa"    ),
    "om"    : langInfo(name:    "Oromo"    ),
    "om_et"    : langInfo(name:    "Oromo (Ethiopia)"    ),
    "om_ke"    : langInfo(name:    "Oromo (Kenya)"    ),
    "or"    : langInfo(name:    "Oriya"    ),
    "or_in"    : langInfo(name:    "Oriya (India)"    ),
    "os"    : langInfo(name:    "Ossetian, Ossetic"    ),
    "pa"    : langInfo(name:    "Punjabi, Panjabi"    ),
    "pa_arab"    : langInfo(name:    "Punjabi (Arabic)"    ),
    "pa_arab_pk"    : langInfo(name:    "Punjabi (Arabic, Pakistan)"    ),
    "pa_guru"    : langInfo(name:    "Punjabi (Gurmukhi)"    ),
    "pa_guru_in"    : langInfo(name:    "Punjabi (Gurmukhi, India)"    ),
    "pi"    : langInfo(name:    "Pali"    ),
    "pl"    : langInfo(name:    "Polish"    ),
    "pl_pl"    : langInfo(name:    "Polish (Poland)"    ),
    "ps"    : langInfo(name:    "Pashto, Pushto"    ),
    "ps_af"    : langInfo(name:    "Pashto (Afghanistan)"    ),
    "pt"    : langInfo(name:    "Portuguese"    ),
    "pt_br"    : langInfo(name:    "Portuguese (Brazil)"    ),
    "pt_gw"    : langInfo(name:    "Portuguese (Guinea-Bissau)"    ),
    "pt_mz"    : langInfo(name:    "Portuguese (Mozambique)"    ),
    "pt_pt"    : langInfo(name:    "Portuguese (Portugal)"    ),
    "qu"    : langInfo(name:    "Quechua"    ),
    "rm"    : langInfo(name:    "Romansh"    ),
    "rm_ch"    : langInfo(name:    "Romansh (Switzerland)"    ),
    "rn"    : langInfo(name:    "Rundi"    ),
    "ro"    : langInfo(name:    "Romanian, Moldavian, Moldovan"    ),
    "ro_md"    : langInfo(name:    "Romanian (Moldova)"    ),
    "ro_ro"    : langInfo(name:    "Romanian (Romania)"    ),
    "rof"    : langInfo(name:    "Rombo"    ),
    "rof_tz"    : langInfo(name:    "Rombo (Tanzania)"    ),
    "ru"    : langInfo(name:    "Russian"    ),
    "ru_md"    : langInfo(name:    "Russian (Moldova)"    ),
    "ru_ru"    : langInfo(name:    "Russian (Russia)"    ),
    "ru_ua"    : langInfo(name:    "Russian (Ukraine)"    ),
    "rw"    : langInfo(name:    "Kinyarwanda"    ),
    "rw_rw"    : langInfo(name:    "Kinyarwanda (Rwanda)"    ),
    "rwk"    : langInfo(name:    "Rwa"    ),
    "rwk_tz"    : langInfo(name:    "Rwa (Tanzania)"    ),
    "sa"    : langInfo(name:    "Sanskrit"    ),
    "saq"    : langInfo(name:    "Samburu"    ),
    "saq_ke"    : langInfo(name:    "Samburu (Kenya)"    ),
    "sc"    : langInfo(name:    "Sardinian"    ),
    "sd"    : langInfo(name:    "Sindhi"    ),
    "se"    : langInfo(name:    "Northern Sami"    ),
    "seh"    : langInfo(name:    "Sena"    ),
    "seh_mz"    : langInfo(name:    "Sena (Mozambique)"    ),
    "ses"    : langInfo(name:    "Koyraboro Senni"    ),
    "ses_ml"    : langInfo(name:    "Koyraboro Senni (Mali)"    ),
    "sg"    : langInfo(name:    "Sango"    ),
    "sg_cf"    : langInfo(name:    "Sango (Central African Republic)"    ),
    "sh"   : langInfo(name:    "Serbo-Croatian"    ),
    "shi"    : langInfo(name:    "Tachelhit"    ),
    "shi_latn"    : langInfo(name:    "Tachelhit (Latin)"    ),
    "shi_latn_ma"    : langInfo(name:    "Tachelhit (Latin, Morocco)"    ),
    "shi_tfng"    : langInfo(name:    "Tachelhit (Tifinagh)"    ),
    "shi_tfng_ma"    : langInfo(name:    "Tachelhit (Tifinagh, Morocco)"    ),
    "si"    : langInfo(name:    "Sinhala, Sinhalese"    ),
    "si_lk"    : langInfo(name:    "Sinhala (Sri Lanka)"    ),
    "sk"    : langInfo(name:    "Slovak"    ),
    "sk_sk"    : langInfo(name:    "Slovak (Slovakia)"    ),
    "sl"    : langInfo(name:    "Slovenian"    ),
    "sl_si"    : langInfo(name:    "Slovenian (Slovenia)"    ),
    "sm"    : langInfo(name:    "Samoan"    ),
    "sn"    : langInfo(name:    "Shona"    ),
    "sn_zw"    : langInfo(name:    "Shona (Zimbabwe)"    ),
    "so"    : langInfo(name:    "Somali"    ),
    "so_dj"    : langInfo(name:    "Somali (Djibouti)"    ),
    "so_et"    : langInfo(name:    "Somali (Ethiopia)"    ),
    "so_ke"    : langInfo(name:    "Somali (Kenya)"    ),
    "so_so"    : langInfo(name:    "Somali (Somalia)"    ),
    "sq"    : langInfo(name:    "Albanian"    ),
    "sq_al"    : langInfo(name:    "Albanian (Albania)"    ),
    "sr"    : langInfo(name:    "Serbian"    ),
    "sr_cyrl"    : langInfo(name:    "Serbian (Cyrillic)"    ),
    "sr_cyrl_ba"    : langInfo(name:    "Serbian (Cyrillic, Bosnia and Herzegovina)"    ),
    "sr_cyrl_me"    : langInfo(name:    "Serbian (Cyrillic, Montenegro)"    ),
    "sr_cyrl_rs"    : langInfo(name:    "Serbian (Cyrillic, Serbia)"    ),
    "sr_latn"    : langInfo(name:    "Serbian (Latin)"    ),
    "sr_latn_ba"    : langInfo(name:    "Serbian (Latin, Bosnia and Herzegovina)"    ),
    "sr_latn_me"    : langInfo(name:    "Serbian (Latin, Montenegro)"    ),
    "sr_latn_rs"    : langInfo(name:    "Serbian (Latin, Serbia)"    ),
    "ss"    : langInfo(name:    "Swati"    ),
    "st"    : langInfo(name:    "Southern Sotho"    ),
    "su"    : langInfo(name:    "Sundanese"    ),
    "sv"    : langInfo(name:    "Swedish"    ),
    "sv_fi"    : langInfo(name:    "Swedish (Finland)"    ),
    "sv_se"    : langInfo(name:    "Swedish (Sweden)"    ),
    "sw"    : langInfo(name:    "Swahili"    ),
    "sw_ke"    : langInfo(name:    "Swahili (Kenya)"    ),
    "sw_tz"    : langInfo(name:    "Swahili (Tanzania)"    ),
    "ta"    : langInfo(name:    "Tamil"    ),
    "ta_in"    : langInfo(name:    "Tamil (India)"    ),
    "ta_lk"    : langInfo(name:    "Tamil (Sri Lanka)"    ),
    "te"    : langInfo(name:    "Telugu"    ),
    "te_in"    : langInfo(name:    "Telugu (India)"    ),
    "teo"    : langInfo(name:    "Teso"    ),
    "teo_ke"    : langInfo(name:    "Teso (Kenya)"    ),
    "teo_ug"    : langInfo(name:    "Teso (Uganda)"    ),
    "tg"    : langInfo(name:    "Tajik"    ),
    "th"    : langInfo(name:    "Thai"    ),
    "th_th"    : langInfo(name:    "Thai (Thailand)"    ),
    "ti"    : langInfo(name:    "Tigrinya"    ),
    "ti_er"    : langInfo(name:    "Tigrinya (Eritrea)"    ),
    "ti_et"    : langInfo(name:    "Tigrinya (Ethiopia)"    ),
    "tk"    : langInfo(name:    "Turkmen"    ),
    "tl"    : langInfo(name:    "Tagalog"    ),
    "tn"    : langInfo(name:    "Tswana"    ),
    "to"    : langInfo(name:    "Tonga"    ),
    "to_to"    : langInfo(name:    "Tonga (Tonga)"    ),
    "tr"    : langInfo(name:    "Turkish"    ),
    "tr_tr"    : langInfo(name:    "Turkish (Turkey)"    ),
    "ts"    : langInfo(name:    "Tsonga"    ),
    "tt"    : langInfo(name:    "Tatar"    ),
    "tw"    : langInfo(name:    "Twi"    ),
    "ty"    : langInfo(name:    "Tahitian"    ),
    "tzm"    : langInfo(name:    "Central Morocco Tamazight"    ),
    "tzm_latn"    : langInfo(name:    "Central Morocco Tamazight (Latin)"    ),
    "tzm_latn_ma"    : langInfo(name:    "Central Morocco Tamazight (Latin, Morocco)"    ),
    "ug"    : langInfo(name:    "Uighur, Uyghur"    ),
    "uk"    : langInfo(name:    "Ukrainian"    ),
    "uk_ua"    : langInfo(name:    "Ukrainian (Ukraine)"    ),
    "ur"    : langInfo(name:    "Urdu"    ),
    "ur_in"    : langInfo(name:    "Urdu (India)"    ),
    "ur_pk"    : langInfo(name:    "Urdu (Pakistan)"    ),
    "uz"    : langInfo(name:    "Uzbek"    ),
    "uz_arab"    : langInfo(name:    "Uzbek (Arabic)"    ),
    "uz_arab_af"    : langInfo(name:    "Uzbek (Arabic, Afghanistan)"    ),
    "uz_cyrl"    : langInfo(name:    "Uzbek (Cyrillic)"    ),
    "uz_cyrl_uz"    : langInfo(name:    "Uzbek (Cyrillic, Uzbekistan)"    ),
    "uz_latn"    : langInfo(name:    "Uzbek (Latin)"    ),
    "uz_latn_uz"    : langInfo(name:    "Uzbek (Latin, Uzbekistan)"    ),
    "ve"    : langInfo(name:    "Venda"    ),
    "vi"    : langInfo(name:    "Vietnamese"    ),
    "vi_vn"    : langInfo(name:    "Vietnamese (Vietnam)"    ),
    "vo"    : langInfo(name:    "Volapük"    ),
    "vun"    : langInfo(name:    "Vunjo"    ),
    "vun_tz"    : langInfo(name:    "Vunjo (Tanzania)"    ),
    "wa"    : langInfo(name:    "Walloon"    ),
    "wo"    : langInfo(name:    "Wolof"    ),
    "xh"    : langInfo(name:    "Xhosa"    ),
    "xog"    : langInfo(name:    "Soga"    ),
    "xog_ug"    : langInfo(name:    "Soga (Uganda)"    ),
    "yi"    : langInfo(name:    "Yiddish"    ),
    "yo"    : langInfo(name:    "Yoruba"    ),
    "yo_ng"    : langInfo(name:    "Yoruba (Nigeria)"    ),
    "za"    : langInfo(name:    "Zhuang, Chuang"    ),
    "zh"    : langInfo(name:    "Chinese"    ),
    "zh_cn"    : langInfo(name:    "Chinese (PRC)"    ),
    "zh_hk"    : langInfo(name:    "Chinese (Hong Kong)"    ),
    "zh_sg"    : langInfo(name:    "Chinese (Singapore)"    ),
    "zh_tw"    : langInfo(name:    "Chinese (Taiwan)"    ),
    "zh_hans"    : langInfo(name:    "Chinese (Simplified Han)"    ),
    "zh_hans_cn"    : langInfo(name:    "Chinese (Simplified Han, China)"    ),
    "zh_hans_hk"    : langInfo(name:    "Chinese (Simplified Han, Hong Kong SAR China)"    ),
    "zh_hans_mo"    : langInfo(name:    "Chinese (Simplified Han, Macau SAR China)"    ),
    "zh_hans_sg"    : langInfo(name:    "Chinese (Simplified Han, Singapore)"    ),
    "zh_hant"    : langInfo(name:    "Chinese (Traditional Han)"    ),
    "zh_hant_hk"    : langInfo(name:    "Chinese (Traditional Han, Hong Kong SAR China)"    ),
    "zh_hant_mo"    : langInfo(name:    "Chinese (Traditional Han, Macau SAR China)"    ),
    "zh_hant_tw"    : langInfo(name:    "Chinese (Traditional Han, Taiwan)"    ),
    "zu"    : langInfo(name:    "Zulu"    ),
    "zu_za"    : langInfo(name:    "Zulu (South Africa)"    )
//    "ab"    : langInfo(name:    "Abkhazian"    ),
//    "aa"    : langInfo(name:    "Afar"    ),
//    "af"    : langInfo(name:    "Afrikaans"    ),
//    "ak"    : langInfo(name:    "Akan"    ),
//    "sq"    : langInfo(name:    "Albanian"    ),
//    "am"    : langInfo(name:    "Amharic"    ),
//    "ar"    : langInfo(name:    "Arabic"    ),
//    "ar-ae"    : langInfo(name:    "Arabic (U.A.E.)"    ),
//    "ar-bh"    : langInfo(name:    "Arabic (Bahrain)"    ),
//    "ar-dz"    : langInfo(name:    "Arabic (Algeria)"    ),
//    "ar-eg"    : langInfo(name:    "Arabic (Egypt)"    ),
//    "ar-iq"    : langInfo(name:    "Arabic (Iraq)"    ),
//    "ar-jo"    : langInfo(name:    "Arabic (Jordan)"    ),
//    "ar-kw"    : langInfo(name:    "Arabic (Kuwait)"    ),
//    "ar-lb"    : langInfo(name:    "Arabic (Lebanon)"    ),
//    "ar-ly"    : langInfo(name:    "Arabic (Libya)"    ),
//    "ar-ma"    : langInfo(name:    "Arabic (Morocco)"    ),
//    "ar-om"    : langInfo(name:    "Arabic (Oman)"    ),
//    "ar-qa"    : langInfo(name:    "Arabic (Qatar)"    ),
//    "ar-sa"    : langInfo(name:    "Arabic (Saudi Arabia)"    ),
//    "ar-sy"    : langInfo(name:    "Arabic (Syria)"    ),
//    "ar-tn"    : langInfo(name:    "Arabic (Tunisia)"    ),
//    "ar-ye"    : langInfo(name:    "Arabic (Yemen)"    ),
//    "an"    : langInfo(name:    "Aragonese"    ),
//    "hy"    : langInfo(name:    "Armenian"    ),
//    "as"    : langInfo(name:    "Assamese"    ),
//    "av"    : langInfo(name:    "Avaric"    ),
//    "ae"    : langInfo(name:    "Avestan"    ),
//    "ay"    : langInfo(name:    "Aymara"    ),
//    "az"    : langInfo(name:    "Azerbaijani"    ),
//    "bm"    : langInfo(name:    "Bambara"    ),
//    "ba"    : langInfo(name:    "Bashkir"    ),
//    "eu"    : langInfo(name:    "Basque"    ),
//    "be"    : langInfo(name:    "Belarusian"    ),
//    "bn"    : langInfo(name:    "Bengali"    ),
//    "bi"    : langInfo(name:    "Bislama"    ),
//    "bs"    : langInfo(name:    "Bosnian"    ),
//    "br"    : langInfo(name:    "Breton"    ),
//    "bg"    : langInfo(name:    "Bulgarian"    ),
//    "my"    : langInfo(name:    "Burmese"    ),
//    "ca"    : langInfo(name:    "Catalan, Valencian"    ),
//    "ch"    : langInfo(name:    "Chamorro"    ),
//    "ce"    : langInfo(name:    "Chechen"    ),
//    "ny"    : langInfo(name:    "Chichewa, Chewa, Nyanja"    ),
//    "zh"    : langInfo(name:    "Chinese"    ),
//    "yue-CN"    : langInfo(name:    "Chinese (Cantonese)"    ),
//    "cmn-CN"    : langInfo(name:    "Chinese (Mandarin)"    ),
//    "zh-cn"    : langInfo(name:    "Chinese (PRC)"    ),
//    "zh-hk"    : langInfo(name:    "Chinese (Hong Kong)"    ),
//    "zh-sg"    : langInfo(name:    "Chinese (Singapore)"    ),
//    "zh-tw"    : langInfo(name:    "Chinese (Taiwan)"    ),
//    "cu"    : langInfo(name:    "Church Slavonic, Old Slavonic, Old Church Slavonic"    ),
//    "cv"    : langInfo(name:    "Chuvash"    ),
//    "kw"    : langInfo(name:    "Cornish"    ),
//    "co"    : langInfo(name:    "Corsican"    ),
//    "cr"    : langInfo(name:    "Cree"    ),
//    "hr"    : langInfo(name:    "Croatian"    ),
//    "cs"    : langInfo(name:    "Czech"    ),
//    "da"    : langInfo(name:    "Danish"    ),
//    "dv"    : langInfo(name:    "Divehi, Dhivehi, Maldivian"    ),
//    "nl"    : langInfo(name:    "Dutch, Flemish"    ),
//    "nl-be"    : langInfo(name:    "Dutch (Belgium)"    ),
//    "dz"    : langInfo(name:    "Dzongkha"    ),
//    "en"    : langInfo(name:    "English"    ),
//    "en-au"    : langInfo(name:    "English (Australia)"    ),
//    "en-bz"    : langInfo(name:    "English (Belize)"    ),
//    "en-ca"    : langInfo(name:    "English (Canada)"    ),
//    "en-gb"    : langInfo(name:    "English (United Kingdom)"    ),
//    "en-ie"    : langInfo(name:    "English (Ireland)"    ),
//    "en-jm"    : langInfo(name:    "English (Jamaica)"    ),
//    "en-nz"    : langInfo(name:    "English (New Zealand)"    ),
//    "en-tt"    : langInfo(name:    "English (Trinidad)"    ),
//    "en-us"    : langInfo(name:    "English (United States)"    ),
//    "en-za"    : langInfo(name:    "English (South Africa)"    ),
//    "eo"    : langInfo(name:    "Esperanto"    ),
//    "et"    : langInfo(name:    "Estonian"    ),
//    "ee"    : langInfo(name:    "Ewe"    ),
//    "fo"    : langInfo(name:    "Faroese"    ),
//    "fj"    : langInfo(name:    "Fijian"    ),
//    "fi"    : langInfo(name:    "Finnish"    ),
//    "fr"    : langInfo(name:    "French"    ),
//    "fr-be"    : langInfo(name:    "French (Belgium)"    ),
//    "fr-ca"    : langInfo(name:    "French (Canada)"    ),
//    "fr-ch"    : langInfo(name:    "French (Switzerland)"    ),
//    "fr-lu"    : langInfo(name:    "French (Luxembourg)"    ),
//    "fy"    : langInfo(name:    "Western Frisian"    ),
//    "ff"    : langInfo(name:    "Fulah"    ),
//    "gd"    : langInfo(name:    "Gaelic, Scottish Gaelic"    ),
//    "gl"    : langInfo(name:    "Galician"    ),
//    "lg"    : langInfo(name:    "Ganda"    ),
//    "ka"    : langInfo(name:    "Georgian"    ),
//    "de"    : langInfo(name:    "German"    ),
//    "de-at"    : langInfo(name:    "German (Austria)"    ),
//    "de-ch"    : langInfo(name:    "German (Switzerland)"    ),
//    "de-li"    : langInfo(name:    "German (Liechtenstein)"    ),
//    "de-lu"    : langInfo(name:    "German (Luxembourg)"    ),
//    "el"    : langInfo(name:    "Greek, Modern (1453–)"    ),
//    "kl"    : langInfo(name:    "Kalaallisut, Greenlandic"    ),
//    "gn"    : langInfo(name:    "Guarani"    ),
//    "gu"    : langInfo(name:    "Gujarati"    ),
//    "ht"    : langInfo(name:    "Haitian, Haitian Creole"    ),
//    "ha"    : langInfo(name:    "Hausa"    ),
//    "he"    : langInfo(name:    "Hebrew"    ),
//    "hz"    : langInfo(name:    "Herero"    ),
//    "hi"    : langInfo(name:    "Hindi"    ),
//    "ho"    : langInfo(name:    "Hiri Motu"    ),
//    "hu"    : langInfo(name:    "Hungarian"    ),
//    "is"    : langInfo(name:    "Icelandic"    ),
//    "io"    : langInfo(name:    "Ido"    ),
//    "ig"    : langInfo(name:    "Igbo"    ),
//    "id"    : langInfo(name:    "Indonesian"    ),
//    "ia"    : langInfo(name:    "Interlingua (International Auxiliary Language Association)"    ),
//    "ie"    : langInfo(name:    "Interlingue, Occidental"    ),
//    "iu"    : langInfo(name:    "Inuktitut"    ),
//    "ik"    : langInfo(name:    "Inupiaq"    ),
//    "ga"    : langInfo(name:    "Irish"    ),
//    "it"    : langInfo(name:    "Italian"    ),
//    "it-ch"    : langInfo(name:    "Italian (Switzerland)"    ),
//    "ja"    : langInfo(name:    "Japanese"    ),
//    "jv"    : langInfo(name:    "Javanese"    ),
//    "kn"    : langInfo(name:    "Kannada"    ),
//    "kr"    : langInfo(name:    "Kanuri"    ),
//    "ks"    : langInfo(name:    "Kashmiri"    ),
//    "kk"    : langInfo(name:    "Kazakh"    ),
//    "km"    : langInfo(name:    "Central Khmer"    ),
//    "ki"    : langInfo(name:    "Kikuyu, Gikuyu"    ),
//    "rw"    : langInfo(name:    "Kinyarwanda"    ),
//    "ky"    : langInfo(name:    "Kirghiz, Kyrgyz"    ),
//    "kv"    : langInfo(name:    "Komi"    ),
//    "kg"    : langInfo(name:    "Kongo"    ),
//    "ko"    : langInfo(name:    "Korean"    ),
//    "kj"    : langInfo(name:    "Kuanyama, Kwanyama"    ),
//    "ku"    : langInfo(name:    "Kurdish"    ),
//    "lo"    : langInfo(name:    "Lao"    ),
//    "la"    : langInfo(name:    "Latin"    ),
//    "lv"    : langInfo(name:    "Latvian"    ),
//    "li"    : langInfo(name:    "Limburgan, Limburger, Limburgish"    ),
//    "ln"    : langInfo(name:    "Lingala"    ),
//    "lt"    : langInfo(name:    "Lithuanian"    ),
//    "lu"    : langInfo(name:    "Luba-Katanga"    ),
//    "lb"    : langInfo(name:    "Luxembourgish, Letzeburgesch"    ),
//    "mk"    : langInfo(name:    "Macedonian"    ),
//    "mg"    : langInfo(name:    "Malagasy"    ),
//    "ms"    : langInfo(name:    "Malay"    ),
//    "ml"    : langInfo(name:    "Malayalam"    ),
//    "mt"    : langInfo(name:    "Maltese"    ),
//    "gv"    : langInfo(name:    "Manx"    ),
//    "mi"    : langInfo(name:    "Maori"    ),
//    "mr"    : langInfo(name:    "Marathi"    ),
//    "mh"    : langInfo(name:    "Marshallese"    ),
//    "mn"    : langInfo(name:    "Mongolian"    ),
//    "na"    : langInfo(name:    "Nauru"    ),
//    "nv"    : langInfo(name:    "Navajo, Navaho"    ),
//    "nd"    : langInfo(name:    "North Ndebele"    ),
//    "nr"    : langInfo(name:    "South Ndebele"    ),
//    "ng"    : langInfo(name:    "Ndonga"    ),
//    "ne"    : langInfo(name:    "Nepali"    ),
//    "no"    : langInfo(name:    "Norwegian"    ),
//    "nb"    : langInfo(name:    "Norwegian Bokmål"    ),
//    "nn"    : langInfo(name:    "Norwegian Nynorsk"    ),
//    "ii"    : langInfo(name:    "Sichuan Yi, Nuosu"    ),
//    "oc"    : langInfo(name:    "Occitan"    ),
//    "oj"    : langInfo(name:    "Ojibwa"    ),
//    "or"    : langInfo(name:    "Oriya"    ),
//    "om"    : langInfo(name:    "Oromo"    ),
//    "os"    : langInfo(name:    "Ossetian, Ossetic"    ),
//    "pi"    : langInfo(name:    "Pali"    ),
//    "ps"    : langInfo(name:    "Pashto, Pushto"    ),
//    "fa"    : langInfo(name:    "Persian"    ),
//    "pl"    : langInfo(name:    "Polish"    ),
//    "pt"    : langInfo(name:    "Portuguese"    ),
//    "pt-br"    : langInfo(name:    "Portuguese (Brazil)"    ),
//    "pa"    : langInfo(name:    "Punjabi, Panjabi"    ),
//    "qu"    : langInfo(name:    "Quechua"    ),
//    "ro"    : langInfo(name:    "Romanian, Moldavian, Moldovan"    ),
//    "ro-md"    : langInfo(name:    "Romanian (Republic of Moldova)"    ),
//    "rm"    : langInfo(name:    "Romansh"    ),
//    "rn"    : langInfo(name:    "Rundi"    ),
//    "ru"    : langInfo(name:    "Russian"    ),
//    "ru-md"    : langInfo(name:    "Russian (Republic of Moldova)"    ),
//    "se"    : langInfo(name:    "Northern Sami"    ),
//    "sm"    : langInfo(name:    "Samoan"    ),
//    "sg"    : langInfo(name:    "Sango"    ),
//    "sa"    : langInfo(name:    "Sanskrit"    ),
//    "sc"    : langInfo(name:    "Sardinian"    ),
//    "sr"    : langInfo(name:    "Serbian"    ),
//    "sn"    : langInfo(name:    "Shona"    ),
//    "sd"    : langInfo(name:    "Sindhi"    ),
//    "si"    : langInfo(name:    "Sinhala, Sinhalese"    ),
//    "sk"    : langInfo(name:    "Slovak"    ),
//    "sl"    : langInfo(name:    "Slovenian"    ),
//    "so"    : langInfo(name:    "Somali"    ),
//    "st"    : langInfo(name:    "Southern Sotho"    ),
//    "es"    : langInfo(name:    "Spanish, Castilian"    ),
//    "es-ar"    : langInfo(name:    "Spanish (Argentina)"    ),
//    "es-bo"    : langInfo(name:    "Spanish (Bolivia)"    ),
//    "es-cl"    : langInfo(name:    "Spanish (Chile)"    ),
//    "es-co"    : langInfo(name:    "Spanish (Colombia)"    ),
//    "es-cr"    : langInfo(name:    "Spanish (Costa Rica)"    ),
//    "es-do"    : langInfo(name:    "Spanish (Dominican Republic)"    ),
//    "es-ec"    : langInfo(name:    "Spanish (Ecuador)"    ),
//    "es-gt"    : langInfo(name:    "Spanish (Guatemala)"    ),
//    "es-hn"    : langInfo(name:    "Spanish (Honduras)"    ),
//    "es-mx"    : langInfo(name:    "Spanish (Mexico)"    ),
//    "es-ni"    : langInfo(name:    "Spanish (Nicaragua)"    ),
//    "es-pa"    : langInfo(name:    "Spanish (Panama)"    ),
//    "es-pe"    : langInfo(name:    "Spanish (Peru)"    ),
//    "es-pr"    : langInfo(name:    "Spanish (Puerto Rico)"    ),
//    "es-py"    : langInfo(name:    "Spanish (Paraguay)"    ),
//    "es-sv"    : langInfo(name:    "Spanish (El Salvador)"    ),
//    "es-uy"    : langInfo(name:    "Spanish (Uruguay)"    ),
//    "es-ve"    : langInfo(name:    "Spanish (Venezuela)"    ),
//    "su"    : langInfo(name:    "Sundanese"    ),
//    "sw"    : langInfo(name:    "Swahili"    ),
//    "ss"    : langInfo(name:    "Swati"    ),
//    "sv"    : langInfo(name:    "Swedish"    ),
//    "sv-fi"    : langInfo(name:    "Swedish (Finland)"    ),
//    "tl"    : langInfo(name:    "Tagalog"    ),
//    "ty"    : langInfo(name:    "Tahitian"    ),
//    "tg"    : langInfo(name:    "Tajik"    ),
//    "ta"    : langInfo(name:    "Tamil"    ),
//    "tt"    : langInfo(name:    "Tatar"    ),
//    "te"    : langInfo(name:    "Telugu"    ),
//    "th"    : langInfo(name:    "Thai"    ),
//    "bo"    : langInfo(name:    "Tibetan"    ),
//    "ti"    : langInfo(name:    "Tigrinya"    ),
//    "to"    : langInfo(name:    "Tonga (Tonga Islands)"    ),
//    "ts"    : langInfo(name:    "Tsonga"    ),
//    "tn"    : langInfo(name:    "Tswana"    ),
//    "tr"    : langInfo(name:    "Turkish"    ),
//    "tk"    : langInfo(name:    "Turkmen"    ),
//    "tw"    : langInfo(name:    "Twi"    ),
//    "ug"    : langInfo(name:    "Uighur, Uyghur"    ),
//    "uk"    : langInfo(name:    "Ukrainian"    ),
//    "ur"    : langInfo(name:    "Urdu"    ),
//    "uz"    : langInfo(name:    "Uzbek"    ),
//    "ve"    : langInfo(name:    "Venda"    ),
//    "vi"    : langInfo(name:    "Vietnamese"    ),
//    "vo"    : langInfo(name:    "Volapük"    ),
//    "wa"    : langInfo(name:    "Walloon"    ),
//    "cy"    : langInfo(name:    "Welsh"    ),
//    "wo"    : langInfo(name:    "Wolof"    ),
//    "xh"    : langInfo(name:    "Xhosa"    ),
//    "yi"    : langInfo(name:    "Yiddish"    ),
//    "yo"    : langInfo(name:    "Yoruba"    ),
//    "za"    : langInfo(name:    "Zhuang, Chuang"    ),
//    "zu"    : langInfo(name:    "Zulu"    )
]


let alternativeLanguageNames: [String:String] = [
    "abkhazian" :   "ab"    ,
    "afar"  :   "aa"    ,
    "afrikaans" :   "af"    ,
    "akan"  :   "ak"    ,
    "albanian"  :   "sq"    ,
    "amharic"   :   "am"    ,
    "arabic"    :   "ar"    ,
    "aragonese" :   "an"    ,
    "armenian"  :   "hy"    ,
    "assamese"  :   "as"    ,
    "avaric"    :   "av"    ,
    "avestan"   :   "ae"    ,
    "aymara"    :   "ay"    ,
    "azerbaijani"   :   "az"    ,
    "bambara"   :   "bm"    ,
    "bashkir"   :   "ba"    ,
    "basque"    :   "eu"    ,
    "belarusian"    :   "be"    ,
    "bengali"   :   "bn"    ,
    "bislama"   :   "bi"    ,
    "bosnian"   :   "bs"    ,
    "breton"    :   "br"    ,
    "bulgarian" :   "bg"    ,
    "burmese"   :   "my"    ,
    "catalan"    :   "ca"    ,
    "valencian"    :   "ca"    ,
    "chamorro"  :   "ch"    ,
    "chechen"   :   "ce"    ,
    "chichewa"   :   "ny"    ,
    "chewa"   :   "ny"    ,
    "nyanja"   :   "ny"    ,
    "chinese"   :   "zh"    ,
    "church slavonic"    :   "cu"    ,
    "old slavonic"    :   "cu"    ,
    "old church slavonic"    :   "cu"    ,
    "chuvash"   :   "cv"    ,
    "cornish"   :   "kw"    ,
    "corsican"  :   "co"    ,
    "cree"  :   "cr"    ,
    "croatian"  :   "hr"    ,
    "czech" :   "cs"    ,
    "danish"    :   "da"    ,
    "divehi"    :   "dv"    ,
    "dhivehi"    :   "dv"    ,
    "maldivian"    :   "dv"    ,
    "dutch"    :   "nl"    ,
    "flemish"    :   "nl"    ,
    "dzongkha"  :   "dz"    ,
    "english"   :   "en"    ,
    "esperanto" :   "eo"    ,
    "estonian"  :   "et"    ,
    "faroese"   :   "fo"    ,
    "fijian"    :   "fj"    ,
    "finnish"   :   "fi"    ,
    "french"    :   "fr"    ,
    "western frisian"   :   "fy"    ,
    "fulah" :   "ff"    ,
    "gaelic"   :   "gd"    ,
    "scottish gaelic"   :   "gd"    ,
    "galician"  :   "gl"    ,
    "ganda" :   "lg"    ,
    "georgian"  :   "ka"    ,
    "german"    :   "de"    ,
    "greek" :   "el"    ,
    "modern (1453–)" :   "el"    ,
    "kalaallisut"  :   "kl"    ,
    "greenlandic"  :   "kl"    ,
    "guarani"   :   "gn"    ,
    "gujarati"  :   "gu"    ,
    "haitian"   :   "ht"    ,
    "haitian creole"   :   "ht"    ,
    "hausa" :   "ha"    ,
    "hebrew"    :   "he"    ,
    "herero"    :   "hz"    ,
    "hindi" :   "hi"    ,
    "hiri motu" :   "ho"    ,
    "hungarian" :   "hu"    ,
    "icelandic" :   "is"    ,
    "igbo"  :   "ig"    ,
    "indonesian"    :   "id"    ,
    "interlingua"    :   "ia"    ,
    "interlingue"   :   "ie"    ,
    "inuktitut" :   "iu"    ,
    "inupiaq"   :   "ik"    ,
    "irish" :   "ga"    ,
    "italian"   :   "it"    ,
    "japanese"  :   "ja"    ,
    "javanese"  :   "jv"    ,
    "kannada"   :   "kn"    ,
    "kanuri"    :   "kr"    ,
    "kashmiri"  :   "ks"    ,
    "kazakh"    :   "kk"    ,
    "central khmer" :   "km"    ,
    "kikuyu"    :   "ki"    ,
    "gikuyu"    :   "ki"    ,
    "kinyarwanda"   :   "rw"    ,
    "kirghiz, kyrgyz"   :   "ky"    ,
    "komi"  :   "kv"    ,
    "kongo" :   "kg"    ,
    "korean"    :   "ko"    ,
    "kuanyama"    :   "kj"    ,
    "kwanyama"    :   "kj"    ,
    "kurdish"   :   "ku"    ,
    "latin" :   "la"    ,
    "latvian"   :   "lv"    ,
    "limburgan"  :   "li"    ,
    "limburger"  :   "li"    ,
    "limburgish"  :   "li"    ,
    "lingala"   :   "ln"    ,
    "lithuanian"    :   "lt"    ,
    "luba-katanga"  :   "lu"    ,
    "luxembourgish"  :   "lb"    ,
    "letzeburgesch"  :   "lb"    ,
    "macedonian"    :   "mk"    ,
    "malagasy"  :   "mg"    ,
    "malay" :   "ms"    ,
    "malayalam" :   "ml"    ,
    "maltese"   :   "mt"    ,
    "manx"  :   "gv"    ,
    "maori" :   "mi"    ,
    "marathi"   :   "mr"    ,
    "marshallese"   :   "mh"    ,
    "mongolian" :   "mn"    ,
    "nauru" :   "na"    ,
    "navajo, navaho"    :   "nv"    ,
    "north ndebele" :   "nd"    ,
    "south ndebele" :   "nr"    ,
    "ndonga"    :   "ng"    ,
    "nepali"    :   "ne"    ,
    "norwegian" :   "no"    ,
    "norwegian bokmål"  :   "nb"    ,
    "norwegian nynorsk" :   "nn"    ,
    "sichuan yi" :   "ii"    ,
    "nuosu" :   "ii"    ,
    "occitan"   :   "oc"    ,
    "ojibwa"    :   "oj"    ,
    "oriya" :   "or"    ,
    "oromo" :   "om"    ,
    "ossetian" :   "os"    ,
    "ossetic" :   "os"    ,
    "pali"  :   "pi"    ,
    "pashto, pushto"    :   "ps"    ,
    "persian"   :   "fa"    ,
    "polish"    :   "pl"    ,
    "portuguese"    :   "pt"    ,
    "punjabi"  :   "pa"    ,
    "panjabi"  :   "pa"    ,
    "quechua"   :   "qu"    ,
    "romanian" :   "ro"    ,
    "moldavian" :   "ro"    ,
    "moldovan" :   "ro"    ,
    "romansh"   :   "rm"    ,
    "rundi" :   "rn"    ,
    "russian"   :   "ru"    ,
    "northern sami" :   "se"    ,
    "samoan"    :   "sm"    ,
    "sango" :   "sg"    ,
    "sanskrit"  :   "sa"    ,
    "sardinian" :   "sc"    ,
    "serbian"   :   "sr"    ,
    "shona" :   "sn"    ,
    "sindhi"    :   "sd"    ,
    "sinhala"    :   "si"    ,
    "sinhalese"    :   "si"    ,
    "slovak"    :   "sk"    ,
    "slovenian" :   "sl"    ,
    "somali"    :   "so"    ,
    "southern sotho"    :   "st"    ,
    "spanish"    :   "es"    ,
    "castilian"    :   "es"    ,
    "sundanese" :   "su"    ,
    "swahili"   :   "sw"    ,
    "swati" :   "ss"    ,
    "swedish"   :   "sv"    ,
    "tagalog"   :   "tl"    ,
    "tahitian"  :   "ty"    ,
    "tajik" :   "tg"    ,
    "tamil" :   "ta"    ,
    "tatar" :   "tt"    ,
    "telugu"    :   "te"    ,
    "thai"  :   "th"    ,
    "tibetan"   :   "bo"    ,
    "tigrinya"  :   "ti"    ,
    "tonga" :   "to"    ,
    "tsonga"    :   "ts"    ,
    "tswana"    :   "tn"    ,
    "turkish"   :   "tr"    ,
    "turkmen"   :   "tk"    ,
    "uighur"    :   "ug"    ,
    "uyghur"    :   "ug"    ,
    "ukrainian" :   "uk"    ,
    "urdu"  :   "ur"    ,
    "uzbek" :   "uz"    ,
    "venda" :   "ve"    ,
    "vietnamese"    :   "vi"    ,
    "volapük"   :   "vo"    ,
    "walloon"   :   "wa"    ,
    "welsh" :   "cy"    ,
    "wolof" :   "wo"    ,
    "xhosa" :   "xh"    ,
    "yiddish"   :   "yi"    ,
    "yoruba"    :   "yo"    ,
    "zhuang"    :   "za"    ,
    "chuang"    :   "za"    ,
    "zulu"  :   "zu",
    "iw" : "he",
    "ji" : "yi",
    "jw"    : "jv",
    "in" : "id",
    "mo" : "ro",
    "aar"    :    "aa"    ,
    "abk"    :    "ab"    ,
    "afr"    :    "af"    ,
    "aka"    :    "ak"    ,
    "amh"    :    "am"    ,
    "ara"    :    "ar"    ,
    "arg"    :    "an"    ,
    "asm"    :    "as"    ,
    "ava"    :    "av"    ,
    "ave"    :    "ae"    ,
    "aym"    :    "ay"    ,
    "aze"    :    "az"    ,
    "bak"    :    "ba"    ,
    "bam"    :    "bm"    ,
    "bel"    :    "be"    ,
    "ben"    :    "bn"    ,
    "bis"    :    "bi"    ,
    "bod"    :    "bo"    ,
    "bos"    :    "bs"    ,
    "bre"    :    "br"    ,
    "bul"    :    "bg"    ,
    "cat"    :    "ca"    ,
    "ces"    :    "cs"    ,
    "cha"    :    "ch"    ,
    "che"    :    "ce"    ,
    "chu"    :    "cu"    ,
    "chv"    :    "cv"    ,
    "cor"    :    "kw"    ,
    "cos"    :    "co"    ,
    "cre"    :    "cr"    ,
    "cym"    :    "cy"    ,
    "dan"    :    "da"    ,
    "deu"    :    "de"    ,
    "div"    :    "dv"    ,
    "dzo"    :    "dz"    ,
    "ell"    :    "el"    ,
    "eng"    :    "en"    ,
    "epo"    :    "eo"    ,
    "est"    :    "et"    ,
    "eus"    :    "eu"    ,
    "ewe"    :    "ee"    ,
    "fao"    :    "fo"    ,
    "fas"    :    "fa"    ,
    "fij"    :    "fj"    ,
    "fin"    :    "fi"    ,
    "fra"    :    "fr"    ,
    "fry"    :    "fy"    ,
    "ful"    :    "ff"    ,
    "gla"    :    "gd"    ,
    "gle"    :    "ga"    ,
    "glg"    :    "gl"    ,
    "glv"    :    "gv"    ,
    "grn"    :    "gn"    ,
    "guj"    :    "gu"    ,
    "hat"    :    "ht"    ,
    "hau"    :    "ha"    ,
    "hbs"    :    "sh"    ,
    "heb"    :    "he"    ,
    "her"    :    "hz"    ,
    "hin"    :    "hi"    ,
    "hmo"    :    "ho"    ,
    "hrv"    :    "hr"    ,
    "hun"    :    "hu"    ,
    "hye"    :    "hy"    ,
    "ibo"    :    "ig"    ,
    "ido"    :    "io"    ,
    "iii"    :    "ii"    ,
    "iku"    :    "iu"    ,
    "ile"    :    "ie"    ,
    "ina"    :    "ia"    ,
    "ind"    :    "id"    ,
    "ipk"    :    "ik"    ,
    "isl"    :    "is"    ,
    "ita"    :    "it"    ,
    "jav"    :    "jv"    ,
    "jpn"    :    "ja"    ,
    "kal"    :    "kl"    ,
    "kan"    :    "kn"    ,
    "kas"    :    "ks"    ,
    "kat"    :    "ka"    ,
    "kau"    :    "kr"    ,
    "kaz"    :    "kk"    ,
    "khm"    :    "km"    ,
    "kik"    :    "ki"    ,
    "kin"    :    "rw"    ,
    "kir"    :    "ky"    ,
    "kom"    :    "kv"    ,
    "kon"    :    "kg"    ,
    "kor"    :    "ko"    ,
    "kua"    :    "kj"    ,
    "kur"    :    "ku"    ,
    "lao"    :    "lo"    ,
    "lat"    :    "la"    ,
    "lav"    :    "lv"    ,
    "lim"    :    "li"    ,
    "lin"    :    "ln"    ,
    "lit"    :    "lt"    ,
    "ltz"    :    "lb"    ,
    "lub"    :    "lu"    ,
    "lug"    :    "lg"    ,
    "mah"    :    "mh"    ,
    "mal"    :    "ml"    ,
    "mar"    :    "mr"    ,
    "mkd"    :    "mk"    ,
    "mlg"    :    "mg"    ,
    "mlt"    :    "mt"    ,
    "mon"    :    "mn"    ,
    "mri"    :    "mi"    ,
    "msa"    :    "ms"    ,
    "mya"    :    "my"    ,
    "nau"    :    "na"    ,
    "nav"    :    "nv"    ,
    "nbl"    :    "nr"    ,
    "nde"    :    "nd"    ,
    "ndo"    :    "ng"    ,
    "nep"    :    "ne"    ,
    "nld"    :    "nl"    ,
    "nno"    :    "nn"    ,
    "nob"    :    "nb"    ,
    "nor"    :    "no"    ,
    "nya"    :    "ny"    ,
    "oci"    :    "oc"    ,
    "oji"    :    "oj"    ,
    "ori"    :    "or"    ,
    "orm"    :    "om"    ,
    "oss"    :    "os"    ,
    "pan"    :    "pa"    ,
    "pli"    :    "pi"    ,
    "pol"    :    "pl"    ,
    "por"    :    "pt"    ,
    "pus"    :    "ps"    ,
    "que"    :    "qu"    ,
    "roh"    :    "rm"    ,
    "ron"    :    "ro"    ,
    "run"    :    "rn"    ,
    "rus"    :    "ru"    ,
    "sag"    :    "sg"    ,
    "san"    :    "sa"    ,
    "sin"    :    "si"    ,
    "slk"    :    "sk"    ,
    "slv"    :    "sl"    ,
    "sme"    :    "se"    ,
    "smo"    :    "sm"    ,
    "sna"    :    "sn"    ,
    "snd"    :    "sd"    ,
    "som"    :    "so"    ,
    "sot"    :    "st"    ,
    "spa"    :    "es"    ,
    "sqi"    :    "sq"    ,
    "srd"    :    "sc"    ,
    "srp"    :    "sr"    ,
    "ssw"    :    "ss"    ,
    "sun"    :    "su"    ,
    "swa"    :    "sw"    ,
    "swe"    :    "sv"    ,
    "tah"    :    "ty"    ,
    "tam"    :    "ta"    ,
    "tat"    :    "tt"    ,
    "tel"    :    "te"    ,
    "tgk"    :    "tg"    ,
    "tgl"    :    "tl"    ,
    "tha"    :    "th"    ,
    "tir"    :    "ti"    ,
    "ton"    :    "to"    ,
    "tsn"    :    "tn"    ,
    "tso"    :    "ts"    ,
    "tuk"    :    "tk"    ,
    "tur"    :    "tr"    ,
    "twi"    :    "tw"    ,
    "uig"    :    "ug"    ,
    "ukr"    :    "uk"    ,
    "urd"    :    "ur"    ,
    "uzb"    :    "uz"    ,
    "ven"    :    "ve"    ,
    "vie"    :    "vi"    ,
    "vol"    :    "vo"    ,
    "wln"    :    "wa"    ,
    "wol"    :    "wo"    ,
    "xho"    :    "xh"    ,
    "yid"    :    "yi"    ,
    "yor"    :    "yo"    ,
    "zha"    :    "za"    ,
    "zho"    :    "zh"    ,
    "zul"    :    "zu",
    "alb":"sq",
    "arm":"hy",
    "baq":"eu",
    "bur":"my",
    "chi":"zh",
    "cze":"cs",
    "dut":"nl",
    "fre":"fr",
    "geo":"ger",
    "gre":"el",
    "ice":"is",
    "mac":"mk",
    "may":"ms",
    "mao":"mi",
    "per":"fa",
    "rum":"ro",
    "slo":"sk",
    "tib":"bo",
    "wel":"cy"
//    "Abkhazian" :   "ab"    ,
//    "Afar"  :   "aa"    ,
//    "Afrikaans" :   "af"    ,
//    "Akan"  :   "ak"    ,
//    "Albanian"  :   "sq"    ,
//    "Amharic"   :   "am"    ,
//    "Arabic"    :   "ar"    ,
//    "Aragonese" :   "an"    ,
//    "Armenian"  :   "hy"    ,
//    "Assamese"  :   "as"    ,
//    "Avaric"    :   "av"    ,
//    "Avestan"   :   "ae"    ,
//    "Aymara"    :   "ay"    ,
//    "Azerbaijani"   :   "az"    ,
//    "Bambara"   :   "bm"    ,
//    "Bashkir"   :   "ba"    ,
//    "Basque"    :   "eu"    ,
//    "Belarusian"    :   "be"    ,
//    "Bengali"   :   "bn"    ,
//    "Bislama"   :   "bi"    ,
//    "Bosnian"   :   "bs"    ,
//    "Breton"    :   "br"    ,
//    "Bulgarian" :   "bg"    ,
//    "Burmese"   :   "my"    ,
//    "Catalan"    :   "ca"    ,
//    "Valencian"    :   "ca"    ,
//    "Chamorro"  :   "ch"    ,
//    "Chechen"   :   "ce"    ,
//    "Chichewa"   :   "ny"    ,
//    "Chewa"   :   "ny"    ,
//    "Nyanja"   :   "ny"    ,
//    "Chinese"   :   "zh"    ,
//    "Church Slavonic"    :   "cu"    ,
//    "Old Slavonic"    :   "cu"    ,
//    "Old Church Slavonic"    :   "cu"    ,
//    "Chuvash"   :   "cv"    ,
//    "Cornish"   :   "kw"    ,
//    "Corsican"  :   "co"    ,
//    "Cree"  :   "cr"    ,
//    "Croatian"  :   "hr"    ,
//    "Czech" :   "cs"    ,
//    "Danish"    :   "da"    ,
//    "Divehi"    :   "dv"    ,
//    "Dhivehi"    :   "dv"    ,
//    "Maldivian"    :   "dv"    ,
//    "Dutch"    :   "nl"    ,
//    "Flemish"    :   "nl"    ,
//    "Dzongkha"  :   "dz"    ,
//    "English"   :   "en"    ,
//    "Esperanto" :   "eo"    ,
//    "Estonian"  :   "et"    ,
//    "Ewe"   :   "ee"    ,
//    "Faroese"   :   "fo"    ,
//    "Fijian"    :   "fj"    ,
//    "Finnish"   :   "fi"    ,
//    "French"    :   "fr"    ,
//    "Western Frisian"   :   "fy"    ,
//    "Fulah" :   "ff"    ,
//    "Gaelic"   :   "gd"    ,
//    "Scottish Gaelic"   :   "gd"    ,
//    "Galician"  :   "gl"    ,
//    "Ganda" :   "lg"    ,
//    "Georgian"  :   "ka"    ,
//    "German"    :   "de"    ,
//    "Greek" :   "el"    ,
//    "Modern (1453–)" :   "el"    ,
//    "Kalaallisut"  :   "kl"    ,
//    "Greenlandic"  :   "kl"    ,
//    "Guarani"   :   "gn"    ,
//    "Gujarati"  :   "gu"    ,
//    "Haitian"   :   "ht"    ,
//    "Haitian Creole"   :   "ht"    ,
//    "Hausa" :   "ha"    ,
//    "Hebrew"    :   "he"    ,
//    "Herero"    :   "hz"    ,
//    "Hindi" :   "hi"    ,
//    "Hiri Motu" :   "ho"    ,
//    "Hungarian" :   "hu"    ,
//    "Icelandic" :   "is"    ,
//    "Ido"   :   "io"    ,
//    "Igbo"  :   "ig"    ,
//    "Indonesian"    :   "id"    ,
//    "Interlingua"    :   "ia"    ,
//    "Interlingue"   :   "ie"    ,
//    "Inuktitut" :   "iu"    ,
//    "Inupiaq"   :   "ik"    ,
//    "Irish" :   "ga"    ,
//    "Italian"   :   "it"    ,
//    "Japanese"  :   "ja"    ,
//    "Javanese"  :   "jv"    ,
//    "Kannada"   :   "kn"    ,
//    "Kanuri"    :   "kr"    ,
//    "Kashmiri"  :   "ks"    ,
//    "Kazakh"    :   "kk"    ,
//    "Central Khmer" :   "km"    ,
//    "Kikuyu"    :   "ki"    ,
//    "Gikuyu"    :   "ki"    ,
//    "Kinyarwanda"   :   "rw"    ,
//    "Kirghiz, Kyrgyz"   :   "ky"    ,
//    "Komi"  :   "kv"    ,
//    "Kongo" :   "kg"    ,
//    "Korean"    :   "ko"    ,
//    "Kuanyama"    :   "kj"    ,
//    "Kwanyama"    :   "kj"    ,
//    "Kurdish"   :   "ku"    ,
//    "Lao"   :   "lo"    ,
//    "Latin" :   "la"    ,
//    "Latvian"   :   "lv"    ,
//    "Limburgan"  :   "li"    ,
//    "Limburger"  :   "li"    ,
//    "Limburgish"  :   "li"    ,
//    "Lingala"   :   "ln"    ,
//    "Lithuanian"    :   "lt"    ,
//    "Luba-Katanga"  :   "lu"    ,
//    "Luxembourgish"  :   "lb"    ,
//    "Letzeburgesch"  :   "lb"    ,
//    "Macedonian"    :   "mk"    ,
//    "Malagasy"  :   "mg"    ,
//    "Malay" :   "ms"    ,
//    "Malayalam" :   "ml"    ,
//    "Maltese"   :   "mt"    ,
//    "Manx"  :   "gv"    ,
//    "Maori" :   "mi"    ,
//    "Marathi"   :   "mr"    ,
//    "Marshallese"   :   "mh"    ,
//    "Mongolian" :   "mn"    ,
//    "Nauru" :   "na"    ,
//    "Navajo, Navaho"    :   "nv"    ,
//    "North Ndebele" :   "nd"    ,
//    "South Ndebele" :   "nr"    ,
//    "Ndonga"    :   "ng"    ,
//    "Nepali"    :   "ne"    ,
//    "Norwegian" :   "no"    ,
//    "Norwegian Bokmål"  :   "nb"    ,
//    "Norwegian Nynorsk" :   "nn"    ,
//    "Sichuan Yi" :   "ii"    ,
//    "Nuosu" :   "ii"    ,
//    "Occitan"   :   "oc"    ,
//    "Ojibwa"    :   "oj"    ,
//    "Oriya" :   "or"    ,
//    "Oromo" :   "om"    ,
//    "Ossetian" :   "os"    ,
//    "Ossetic" :   "os"    ,
//    "Pali"  :   "pi"    ,
//    "Pashto, Pushto"    :   "ps"    ,
//    "Persian"   :   "fa"    ,
//    "Polish"    :   "pl"    ,
//    "Portuguese"    :   "pt"    ,
//    "Punjabi"  :   "pa"    ,
//    "Panjabi"  :   "pa"    ,
//    "Quechua"   :   "qu"    ,
//    "Romanian" :   "ro"    ,
//    "Moldavian" :   "ro"    ,
//    "Moldovan" :   "ro"    ,
//    "Romansh"   :   "rm"    ,
//    "Rundi" :   "rn"    ,
//    "Russian"   :   "ru"    ,
//    "Northern Sami" :   "se"    ,
//    "Samoan"    :   "sm"    ,
//    "Sango" :   "sg"    ,
//    "Sanskrit"  :   "sa"    ,
//    "Sardinian" :   "sc"    ,
//    "Serbian"   :   "sr"    ,
//    "Shona" :   "sn"    ,
//    "Sindhi"    :   "sd"    ,
//    "Sinhala"    :   "si"    ,
//    "Sinhalese"    :   "si"    ,
//    "Slovak"    :   "sk"    ,
//    "Slovenian" :   "sl"    ,
//    "Somali"    :   "so"    ,
//    "Southern Sotho"    :   "st"    ,
//    "Spanish"    :   "es"    ,
//    "Castilian"    :   "es"    ,
//    "Sundanese" :   "su"    ,
//    "Swahili"   :   "sw"    ,
//    "Swati" :   "ss"    ,
//    "Swedish"   :   "sv"    ,
//    "Tagalog"   :   "tl"    ,
//    "Tahitian"  :   "ty"    ,
//    "Tajik" :   "tg"    ,
//    "Tamil" :   "ta"    ,
//    "Tatar" :   "tt"    ,
//    "Telugu"    :   "te"    ,
//    "Thai"  :   "th"    ,
//    "Tibetan"   :   "bo"    ,
//    "Tigrinya"  :   "ti"    ,
//    "Tonga" :   "to"    ,
//    "Tsonga"    :   "ts"    ,
//    "Tswana"    :   "tn"    ,
//    "Turkish"   :   "tr"    ,
//    "Turkmen"   :   "tk"    ,
//    "Twi"   :   "tw"    ,
//    "Uighur"    :   "ug"    ,
//    "Uyghur"    :   "ug"    ,
//    "Ukrainian" :   "uk"    ,
//    "Urdu"  :   "ur"    ,
//    "Uzbek" :   "uz"    ,
//    "Venda" :   "ve"    ,
//    "Vietnamese"    :   "vi"    ,
//    "Volapük"   :   "vo"    ,
//    "Walloon"   :   "wa"    ,
//    "Welsh" :   "cy"    ,
//    "Wolof" :   "wo"    ,
//    "Xhosa" :   "xh"    ,
//    "Yiddish"   :   "yi"    ,
//    "Yoruba"    :   "yo"    ,
//    "Zhuang"    :   "za"    ,
//    "Chuang"    :   "za"    ,
//    "Zulu"  :   "zu"
]
