//
//  FileNavigator.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 13/03/23.
//

import Foundation

struct FileNavigatorItem: Hashable, Comparable {
    static func < (lhs: FileNavigatorItem, rhs: FileNavigatorItem) -> Bool {
        lhs.url.path.lowercased() < rhs.url.path.lowercased()
    }
    let name: String
    let url: URL
//    var isChecked: Bool = false
    let edited: String
    let isDirectory: Bool
    let isAlreadyAdded: Bool = false
    let size: String = ""
    let bytes: Int64 = 0
}

let userDocumentsURL = URL(fileURLWithPath: "/private/var/mobile/Documents/")
let rootURL = URL(fileURLWithPath: "/")
let systemApplicationsURL = URL(fileURLWithPath: "/Applications/")

enum FileNavigatorSortOption {
    case name
    case size
}

class FileNavigator {
    var currentURL = rootURL
    private let fm = FileManager.default
    
    func getFolderContent(url: URL, sortedBy: FileNavigatorSortOption = .name) -> [FileNavigatorItem] {
        currentURL = url
        var folderContent: [FileNavigatorItem] = []
        let folderEnumerator = fm.enumerator(at: url,
                                             includingPropertiesForKeys: [.contentModificationDateKey],
                                             options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants],
                                    //errorHandler: errorHandler)!
                                    errorHandler: nil)!
        for item in folderEnumerator {
            let contentItemURL = item as! URL
            let name = contentItemURL.lastPathComponent
            let isDirectory = contentItemURL.isDirectory == true ? true : false
            var lastEdit: String = ""
            do {
                if let rawDate = try contentItemURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                    switch rawDate.timeIntervalSinceNow {
                    case -86401..<0:
                        // less then 24 hours
                        lastEdit = MyDateFormatter.sharedInstance.getStringFrom(date: rawDate, format: "HH:mm")!
                    case -259201 ..< -86401:
                        // yesterday and before yesterday
                        lastEdit = MyRelativeDateFormatter.sharedInstance.localizedString(for: rawDate, relativeTo: Date())
                    default:
                        lastEdit = MyDateFormatter.sharedInstance.getStringFrom(date: rawDate, format: "dd/MM/yy")!
                    }
                }
            } catch {
                print("errore data file navigator")
            }
            folderContent.append(FileNavigatorItem(name: name, url: contentItemURL, edited: lastEdit, isDirectory: isDirectory))
        }
        
        switch sortedBy {
        case .name:
            folderContent.sort()
        case .size:
            folderContent.sort {
                $0.bytes < $1.bytes
            }
        }
        return folderContent
    }
    
    func getParentFolderContent() -> [FileNavigatorItem] {
        currentURL = currentURL.deletingLastPathComponent()
        return getFolderContent(url: currentURL)
    }
    
    func getRootContent() -> [FileNavigatorItem] {
        return getFolderContent(url: rootURL)
    }
    
    func getSystemApplicationsContent() -> [FileNavigatorItem] {
        return getFolderContent(url: systemApplicationsURL)
    }
}
