//
//  SubListRowView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 21/02/23.
//

import SwiftUI
import OrderedCollections

struct SubListRowView: View {
    
    @State var app: String
    @Binding var apps: OrderedDictionary<String, AppInfo>
    @Binding var appsToShow: [String]
    @Binding var isChecked: Tribool
    @Binding var selectionSize: Int64
    
    @State private var selectedAppSpecificFilesCount = 0
    /// Difference between the sum of the currently selected app specific files and the category size
    @State private var selectionSizeDifference: Int64 = 0
    
    var body: some View {
        
        VStack(alignment: .leading){
            ForEach(apps[app]!.appSpecificErasables.indices, id: \.self) { index in
                if (apps[app]!.appSpecificErasables[index].erasableType == nil) {
                    Button( action: {
                        togglePressed(of: app, for: index)
                    }, label: {
                        VStack(alignment: .leading) {
                            HStack{
                                // Info button
                                Button {
                                    apps[app]!.appSpecificErasables[index].shouldShowDescription.toggle()
                                } label: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }
                                // Erasable name and size
                                VStack(alignment: .leading){
                                    Text("\(apps[app]!.appSpecificErasables[index].erasableName)")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                        .minimumScaleFactor(0.1)
//                                    if ((1...1023).contains(apps[app]!.appSpecificErasables[index].bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                        Text("\(apps[app]!.appSpecificErasables[index].bytes) Byte")
//                                            .font(.system(size: 18, weight: .regular))
//                                            .foregroundColor(.gray)
//                                            .lineLimit(1)
//                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                    } else
                                    if (apps[app]!.appSpecificErasables[index].bytes != 0) { // If the found files
                                        Text(apps[app]!.appSpecificErasables[index].formatted)
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    } else if (apps[app]!.appSpecificErasables[index].bytes == 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                                        Text("No files found")
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    }
                                    
                                }
                                .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                // Toggle
                                Spacer()
                                if (apps[app]!.appSpecificErasables[index].bytes > 0) {
                                    Toggle(isOn: binding(for: app).appSpecificErasables[index].isChecked) {
                                    }
                                    .toggleStyle(CheckboxStyle())
                                    .disabled(true) // The whole row button acts as a toggle
                                }
                            }
                            // Erasable description
                            if (apps[app]!.appSpecificErasables[index].shouldShowDescription) {
                                Text(apps[app]!.appSpecificErasables[index].description)
                                    .font(.system(size: 16, weight: .medium))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.gray)
                                    .padding(EdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    })
                }
            }
            .animation(nil) // Prevents the list items from sliding in from the top
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 13, leading: 26, bottom: 13, trailing: 26))
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color.black))
//        .cornerRadius(26)
        .onChange(of: isChecked, perform: { _ in
            concurrentUIBackgroundQueue.async(flags: .barrier) {
                if isChecked == true {
                    selectionSizeDifference = 0
                    selectedAppSpecificFilesCount = apps.count
                    for app in appsToShow {
                        if apps[app]!.isChecked == false {
                            apps[app]!.isChecked = true
                            selectionSizeDifference += apps[app]!.size
                        }
                    }
                    selectionSize += selectionSizeDifference
                } else if isChecked == false {
                    selectionSizeDifference = 0
                    selectedAppSpecificFilesCount = 0
                    for app in appsToShow {
                        if apps[app]!.isChecked == true {
                            apps[app]!.isChecked = false
                            selectionSizeDifference -= apps[app]!.size
                        }
                    }
                    selectionSize += selectionSizeDifference
                }
            }
        })
        // DA AGGIUNGERE
        .onChange(of: apps.isEmpty, perform: { _ in
            concurrentUIBackgroundQueue.async(flags: .barrier) {
                if isChecked == true {
                    selectionSizeDifference = 0
                    selectedAppSpecificFilesCount = apps.count
                    for app in appsToShow {
                        if apps[app]!.isChecked == false {
                            apps[app]!.isChecked = true
                            selectionSizeDifference += apps[app]!.size
                        } else {
                            selectionSizeDifference += apps[app]!.size
                        }
                    }
                    selectionSize += selectionSizeDifference
                } else if isChecked == false {
                    selectedAppSpecificFilesCount = 0
                    for app in appsToShow {
                        if apps[app]!.isChecked == true {
                            apps[app]!.isChecked = false
                        }
                    }
                }
            }
        })
    }
    
    private func togglePressed(of app: String, for index: Int) {
        Haptics.shared.select()
        concurrentUIBackgroundQueue.async(flags: .barrier) {
            apps[app]!.appSpecificErasables[index].isChecked.toggle()
            if (apps[app]!.appSpecificErasables[index].isChecked) {
                // Toggle switched to ON
                selectionSize += apps[app]!.appSpecificErasables[index].bytes
                selectedAppSpecificFilesCount += 1
                if selectedAppSpecificFilesCount == apps.count {
                    isChecked = true
                } else {
                    isChecked = .indeterminate
                }
            } else {
                // Toggle switched to OFF
                selectionSize -= apps[app]!.appSpecificErasables[index].bytes
                selectedAppSpecificFilesCount -= 1
                if selectedAppSpecificFilesCount == 0 {
                    isChecked = false
                } else {
                    isChecked = .indeterminate
                }
            }
        }
    }
    
    private func binding(for key: String) -> Binding<AppInfo> {
        return .init(
            get: { self.apps[key] ?? AppInfo() },
            set: { self.apps[key] = $0
                appBundleList[key] = $0 })
    }
}

struct SubListRowView_InteractivePreview: View {
    @State private var value = true
    @State private var value2 = false
    
    @State var mockedApps: OrderedDictionary<String, AppInfo> = [
        "Tabula Rasa" : AppInfo(icon: nil, plugins: [:], erasables: [:], appSpecificErasables: [
            appSpecificErasable(appPath: appPath.custom, subPaths: ["Message/Media"],
                                fileNameContains: [], fileExtensions: [".opus"], erasableName: "Audio messages" , description: "???", bytes: 10000, formatted: "10 MB", isChecked: false),
            appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Message/Media"],
                                fileNameContains: [], fileExtensions: [".webp"], erasableName: "Stickers" , description: "???", bytes: 10000, formatted: "10 MB", isChecked: false),
            appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Media/Profile"],
                                fileNameContains: [], fileExtensions: [], erasableName: "Profile Pictures?", description: "Profile Pictures?", bytes: 0, formatted: "", isChecked: false)
        ], appSpecificErasablesSize: 30000, shouldShowAppSpecificErasables: true, size: 10000),
        "Prova" : AppInfo(icon: nil, plugins: [:], erasables: [:], appSpecificErasables: [
            appSpecificErasable(appPath: appPath.custom, subPaths: ["Message/Media"],
                                fileNameContains: [], fileExtensions: [".opus"], erasableName: "Audio messages" , description: "???", bytes: 10000, formatted: "10 MB", isChecked: false),
            appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Message/Media"],
                                fileNameContains: [], fileExtensions: [".webp"], erasableName: "Stickers" , description: "???", bytes: 10000, formatted: "10 MB", isChecked: false),
            appSpecificErasable(appPath: appPath.ContSharedApp, subPaths: ["Media/Profile"],
                                fileNameContains: [], fileExtensions: [], erasableName: "Profile Pictures?", description: "Profile Pictures?", bytes: 0, formatted: "", isChecked: false)
        ], appSpecificErasablesSize: 30000 , shouldShowAppSpecificErasables: true, size: 10000)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            SubListRowView(app: "Tabula Rasa", apps: $mockedApps, appsToShow: .constant([]), isChecked: .constant(false), selectionSize: .constant(0))
            AppSpecificListView(apps: $mockedApps, didFinishAnalyzing: .constant(true), isChecked: .constant(false), shouldShowList: $value, selectionSize: .constant(0), appsToShow: .constant(["Tabula Rasa", "Prova"]))
        }
    }
}

struct SubListRowView_Previews: PreviewProvider {
    static var previews: some View {
        SubListRowView_InteractivePreview()
    }
}
