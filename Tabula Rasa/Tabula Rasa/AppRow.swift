//
//  AppRow.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 08/01/23.
//

import SwiftUI
import ApplicationsWrapper
import OrderedCollections

struct AppRow: View {
    
    @Binding var apps: OrderedDictionary<String, AppInfo>
    @Binding var didFinishAnalyzing: Bool
    @Binding var installedApps: [String]
    @Binding var isChecked: Tribool
    @Binding var selectionSize: Int64
    @Binding var shouldShowList: Bool
    
    @State private var selectedAppsCount = 0
    /// Difference between the sum of the currently selected apps and the category size
    @State private var selectionSizeDifference: Int64 = 0
    
    @State private var closedInfoBannerHeight : CGFloat = 0
    @State private var closedinfoBannerWidth : CGFloat = 0
    @State private var closedInfoBannerOffset: CGFloat = 0
    @State private var closedListPanelHeight: CGFloat = 0
    @State private var closedListPanelOffset: CGFloat = 0
    @State private var parentWidth: CGFloat = UIScreen.main.bounds.size.width - 52 - 26
    
    @State private var bottomPadding: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0){ // Category info banner
                Text(shouldShowList ? "I Plugin sono funzionalità aggiuntive delle app, rimuoverli potrebbe causare crash, per ripristinarli reinstalla l'app" : "")
                    .opacity(shouldShowList ? 1 : 0)
                    .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                    .font(.system(size: 21, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 18, leading: 26, bottom: 21, trailing: 26))
                    .animation(nil)
                    .background(shouldShowList ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardBackground") ?? .black)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardSubLayerBackground") ?? .black)))
//                    .cornerRadius(26)
                    .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                    .frame(maxWidth: shouldShowList ? .infinity : ((closedinfoBannerWidth == 0) ? nil : closedinfoBannerWidth), alignment: .center)
                    .frame(maxWidth: .infinity) // Centers the view
                    .onChange(of: shouldShowList, perform: {newValue in })
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear(perform: {
                            closedInfoBannerHeight = geometry.size.height
                            //                            parentWidth = UIScreen.main.bounds.size.width - 52 - 26//geometry.size.width
                            closedinfoBannerWidth = parentWidth * closedPanelsWidthRatio
                            bottomPadding = -(homeVerticalComponentsSpacing) - closedInfoBannerHeight - closedListPanelHeight + closedPanelsOffset * 2
                            closedInfoBannerOffset = -homeVerticalComponentsSpacing - closedInfoBannerHeight + closedPanelsOffset
                            closedListPanelOffset = -closedListPanelHeight - homeVerticalComponentsSpacing - closedInfoBannerHeight + closedPanelsOffset * 2
                        }).onChange(of: geometry.size.width, perform: { newParentWidth in
                            closedinfoBannerWidth = newParentWidth * closedPanelsWidthRatio
                        })
                    })
                /*
                 -homeVerticalComponentsSpacing nullifys the spacing added by the parent view between this banner and the category row, so that the top of the banner matches the bottom of the category row
                 Offset for open list:
                 openPanelsOffset is the offset to apply
                 Offset for closed list:
                 subtracting the panel height makes the bottom of the banner and the bottom of the category row overlap, finally we add the offset to make the banner appear behind the view
                 */
                    .animation(nil)
                    .offset(y: shouldShowList ? openInfoBannerOffset : closedInfoBannerOffset)
//                    .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                    .zIndex(-1)
            }
            
            VStack(spacing: 0){
                LazyVStack(spacing: 0) {
                    if shouldShowList {
                        HorizontalDivider()
                            .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                        // List of apps with erasable app specific files
                        ForEach(apps.keys, id: \.self) { app in
                            if apps[app]!.isInstalled {
                                Button(action: {
                                    Haptics.shared.select()
                                    concurrentUIBackgroundQueue.async(flags: .barrier) {
                                        apps[app]!.isChecked.toggle()
                                        if (apps[app]!.isChecked) {
                                            // Toggle switched to ON
                                            selectionSize += apps[app]!.size
                                            selectedAppsCount += 1
                                            if selectedAppsCount == apps.count {
                                                isChecked = true
                                            } else {
                                                isChecked = .indeterminate
                                            }
                                        } else {
                                            // Toggle switched to OFF
                                            selectionSize -= apps[app]!.size
                                            selectedAppsCount -= 1
                                            if selectedAppsCount == 0 {
                                                isChecked = false
                                            } else {
                                                isChecked = .indeterminate
                                            }
                                        }
                                    }
                                }) {
                                    VStack(alignment: .leading){
                                        HStack{ // App icon and name
                                            if (apps[app]?.icon != nil) {
                                                Image(uiImage: (apps[app]!.icon!))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 38.0, height: 38.0)
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            } else {
                                                if #available(iOS 15.0, *) {
                                                    Image(systemName: "questionmark.app.dashed")
                                                        .symbolRenderingMode(.hierarchical)
                                                        .font(.system(size: 42))
                                                        .foregroundColor(.white)
                                                        .scaledToFit()
                                                        .frame(width: 38.0, height: 38.0)
                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                } else {
                                                    Image("questionmark.app.dashed")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 38.0, height: 38.0)
                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(apps[app]!.appName)
                                                    .font(.system(size: 21, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
//                                                    .minimumScaleFactor(0.1)
                                                Text(apps[app]!.formattedSize)
                                                    .font(.system(size: 18, weight: .regular))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                            }
                                            Spacer()
                                            Toggle(isOn: (toggleValue(for: app))) {
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .disabled(true)
                                        }
                                    }
                                }
                                .padding(EdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0))
                                
                            }
                            
                        }
//                        .animation(nil) // Prevents the list items from sliding in from the top
                        // Placeholder to show while apps are still being analyzed
                        if (!didFinishAnalyzing) {
                            HStack(spacing: 0) {
                                Spacer()
                                Text("Analyzing")
                                    .font(.system(size: 21, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(0)
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                Spacer()
                            }
                        } else if (installedApps.isEmpty) {
                            // No apps have been found
                            VStack(alignment: .leading, spacing: 0) {
                                Text(shouldShowList ? "No apps found" : "\n")
                                    .font(.system(size: 21, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(0)
                            }.padding(0)
                        }
                    }
                }
                .padding(EdgeInsets(top: 26, leading: listLateralPadding, bottom: 26, trailing: listLateralPadding))
                //                .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                // Due to fixedSize
                .fixedSize() // Prevents the view from lagging when the list is opened and the second banner renders offscreen
                .frame(maxWidth: .infinity)
                .animation(nil)
//                .animation(shouldShowList ? .interpolatingSpring(mass: 1, stiffness: 100, damping: 100, initialVelocity: 0) : nil)
                .background(shouldShowList ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardBackground") ?? .black)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardSubSubLayerBackground") ?? .black)))
//                .cornerRadius(26)
                .frame(maxWidth: shouldShowList ? .infinity : (closedinfoBannerWidth * closedPanelsWidthRatio))
                .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                .background(GeometryReader { geometry in
                    Color.clear.onAppear(perform: {
                        closedListPanelHeight = geometry.size.height
                    })
                })
                .animation(nil)
                //Non e vero  With an offset of -homeVerticalComponentsSpacing the top of the view matches with the bottom of the category, so we subtract the height of this panel view to make the bottoms match and we add a double offset to this panel to make it appear behind the first one
                .offset(y: shouldShowList ? openListPanelOffset : closedListPanelOffset)
                .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
            }
            .zIndex(-2)
            .onChange(of: isChecked, perform: { _ in
                concurrentUIBackgroundQueue.async(flags: .barrier) {
                    if isChecked == true {
                        selectionSizeDifference = 0
                        selectedAppsCount = apps.count
                        for app in apps.keys {
                            if apps[app]!.isChecked == false {
                                apps[app]!.isChecked = true
                                selectionSizeDifference += apps[app]!.size
                            }
                        }
                        selectionSize += selectionSizeDifference
                    } else if isChecked == false {
                        selectionSizeDifference = 0
                        selectedAppsCount = 0
                        for app in apps.keys {
                            if apps[app]!.isChecked == true {
                                apps[app]!.isChecked = false
                                selectionSizeDifference -= apps[app]!.size
                            }
                        }
                        selectionSize += selectionSizeDifference
                    }
                }
            })
            .onChange(of: apps.isEmpty, perform: { _ in
                concurrentUIBackgroundQueue.async(flags: .barrier) {
                    if isChecked == true {
                        selectionSizeDifference = 0
                        selectedAppsCount = apps.count
                        for app in apps.keys {
                            if apps[app]!.isChecked == false {
                                apps[app]!.isChecked = true
                                selectionSizeDifference += apps[app]!.size
                            } else {
                                selectionSizeDifference += apps[app]!.size
                            }
                        }
                        selectionSize += selectionSizeDifference
                    } else if isChecked == false {
                        selectedAppsCount = 0
                        for app in apps.keys {
                            if apps[app]!.isChecked == true {
                                apps[app]!.isChecked = false
                            }
                        }
                    }
                }
            })
            .animation(nil)
            // Since the list uses zIndex, its frame doesn't have the correct height, this creates space to let the list be shown.
            if shouldShowList {
                // NON E VERO Adding all the offsets (the ones used when the list is showing) of the two banners makes the bottom edge of the second banner match the top edge of the bottom on the container of the root VStack, to this we need to add a bottom padding
                Spacer()
                    .frame(height: (openPanelsOffset * 3 - homeVerticalComponentsSpacing * 2))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: shouldShowList ? 0 : bottomPadding, trailing: 0))
//        .onChange(of: isChecked, perform: { _ in
//            if isChecked == Tribool.indeterminate {
//                return
//            } else if isChecked == true {
//                for app in apps.keys {
//                    apps[app]!.isChecked = true
//                }
//            } else {
//                for app in apps.keys {
//                    apps[app]!.isChecked = false
//                }
//            }
//        })
    }
    
    private func toggleValue(for app: String) -> Binding<Bool> {
        return .init(
            get: { self.apps[app]!.isChecked },
            set: { self.apps[app]?.isChecked = $0
                appBundleList[app]?.isChecked = $0 })
    }
}

struct AppRow_Previews: PreviewProvider {
    static var previews: some View {
        var p: OrderedDictionary<pluginType, erasableData> = [.Today : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false)]
        var e: OrderedDictionary<erasableType, erasableData> = [.Cache : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false)]
        var mockedApps: OrderedDictionary<String, AppInfo> = [
            "Tabula Rasa":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000),
            "Tabula Rasa2":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000)
        ]
        AppRow(apps: .constant(mockedApps), didFinishAnalyzing: .constant(true), installedApps: .constant([]), isChecked: .constant(false), selectionSize: .constant(0), shouldShowList: .constant(true))
    }
}


