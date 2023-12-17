//
//  PluginsListView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 18/02/23.
//

import SwiftUI
import OrderedCollections

struct PluginsListView: View {
    
    @Binding var apps: OrderedDictionary<String, AppInfo>
    @Binding var didFinishAnalyzing: Bool
    @Binding var shouldShowList: Bool
    @Binding var selectionSize: Int64
    
    @State private var appsToShow: [String] = []
    
    @State private var selectedAppsCount = 0
    /// Difference between the sum of the currently selected plugins and the category size
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
                LazyVStack(spacing: 0) { //VStack causa jelly effect alla fine della lista se si seleziona un toggle
                    if shouldShowList {
                        HorizontalDivider()
                            .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                        // List of apps with erasable app specific files
                        if !(appsToShow.isEmpty) {
                        ForEach(appsToShow, id: \.self) { app in
                                VStack(alignment: .leading){
                                    HStack{ // App icon and name
//                                        AppIcon(icon: apps[app]!.icon)
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
                                        Text(apps[app]!.appName)
                                            .font(.system(size: 21, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                    }
                                    VStack(alignment: .leading){
                                        ForEach(apps[app]!.plugins.keys, id: \.self) { plugin in
                                            Button {
                                                apps[app]!.plugins[plugin]!.isChecked.toggle()
                                                Haptics.shared.select()
                                                if apps[app]!.plugins[plugin]!.isChecked {
                                                    selectionSize += apps[app]!.plugins[plugin]!.bytes
                                                } else {
                                                    selectionSize -= apps[app]!.plugins[plugin]!.bytes
                                                }
                                            } label: {
                                                VStack(alignment: .leading) {
                                                    HStack{
                                                        
                                                        Button {
                                                            apps[app]!.plugins[plugin]!.shouldShowDescription.toggle()
                                                            print("info \(app) \(plugin)")
                                                        } label: {
                                                            Image(systemName: "info.circle")
                                                                .font(.system(size: 28))
                                                                .foregroundColor(.white)
                                                        }
                                                        
                                                        
                                                        VStack(alignment: .leading){
                                                            Text("\(plugin.rawValue)")
                                                                .font(.system(size: 18, weight: .medium))
                                                                .foregroundColor(.white)
                                                                .lineLimit(1)
                                                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                                                .minimumScaleFactor(0.1)
//                                                            if ((1...1023).contains(apps[app]!.plugins[plugin]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                                                Text("\(apps[app]!.plugins[plugin]!.bytes) Byte")
//                                                                    .font(.system(size: 18, weight: .regular))
//                                                                    .foregroundColor(.gray)
//                                                                    .lineLimit(1)
//                                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                                            } else
                                                            if (apps[app]!.plugins[plugin]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                                                                Text("\(apps[app]!.plugins[plugin]!.formatted)")
                                                                    .font(.system(size: 18, weight: .regular))
                                                                    .foregroundColor(.gray)
                                                                    .lineLimit(1)
                                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                            }
                                                            
                                                        }
                                                        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                                        
                                                        Spacer()
                                                        Toggle(isOn: bindingPlugin(for: plugin, of: app).isChecked) {
                                                            //                                                    updateSelectionSize(app: app, plugin: plugin)
                                                        }
                                                        .disabled(true)
                                                        .toggleStyle(CheckboxStyle())
                                                        .onChange(of: apps[app]!.plugins[plugin]!.isChecked) { isSelected in
                                                            //                                                                if isSelected {
                                                            //                                                                    updateSelectionSize(apps[app]!.plugins[plugin]!.bytes)
                                                            //                                                                } else {
                                                            //                                                                    updateSelectionSize(-(apps[app]!.plugins[plugin]!.bytes))
                                                            //                                                                }
                                                            //                                                            }
                                                        }
                                                        if (apps[app]!.plugins[plugin]!.shouldShowDescription) {
                                                            Text(pluginTypeDescription[plugin]!)                .font(.system(size: 16, weight: .medium))
                                                                .multilineTextAlignment(.leading)
                                                                .foregroundColor(.gray)
                                                                .padding(EdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0))
                                                                .frame(maxWidth: .infinity)
                                                            //                                                .background(Color(UIColor(named: "CardBackground") ?? .black))
                                                            //                                                .cornerRadius(26)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 26, trailing: 0))
                                    }
                                }
                            }
//                        .animation(nil) // Prevents the list items from sliding in from the top
                        } else if (!didFinishAnalyzing) {
                            // Placeholder to show while apps are still being analyzed
                            HStack(spacing: 0) {
                                Spacer()
                                Text(shouldShowList ? "Analyzing" : "\n")
                                    .opacity(shouldShowList ? 1 : 0)
                                    .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                                    .font(.system(size: 21, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(0)
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                Spacer()
                            }
                        } else {
                            // No apps have at least a plugin
                            VStack(alignment: .leading, spacing: 0) {
                                Text(shouldShowList ? "No plugins were found" : "\n")
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
//            .frame(maxWidth: .infinity)
            .zIndex(-2)
            .onChange(of: didFinishAnalyzing, perform: { _ in
                concurrentUIBackgroundQueue.async {
                    var appsWithPlugins: [String] = []
                    for app in apps.keys {
                        if !apps[app]!.plugins.isEmpty {
                            appsWithPlugins.append(app)
                        }
                    }
                    appsToShow = appsWithPlugins
                }
            })
//            .frame(maxWidth: .infinity)
            .animation(nil)
            // Since the list uses zIndex, its frame doesn't have the correct height, this creates space to let the list be shown.
            if shouldShowList {
                // NON E VERO Adding all the offsets (the ones used when the list is showing) of the two banners makes the bottom edge of the second banner match the top edge of the bottom on the container of the root VStack, to this we need to add a bottom padding
                Spacer()
                    .frame(height: (openPanelsOffset * 3 - homeVerticalComponentsSpacing * 2))
            }
        }
//        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: shouldShowList ? 0 : bottomPadding, trailing: 0))
    }
    
    private func binding(for key: String) -> Binding<AppInfo> {
        return .init(
            get: { self.apps[key] ?? AppInfo() },
            set: { self.apps[key] = $0
                appBundleList[key] = $0 })
    }
    
    private func bindingPlugin(for key: pluginType, of bundleID: String) -> Binding<erasableData> {
        return .init(
            get: { self.apps[bundleID]?.plugins[key] ?? erasableData(bytes: 0) },
            set: { self.apps[bundleID]?.plugins[key] = $0
                appBundleList[bundleID]?.plugins[key] = $0})
    }
}

struct PluginsListView_Previews: PreviewProvider {
    static var previews: some View {
        var p: OrderedDictionary<pluginType, erasableData> = [.Today : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false, shouldShowDescription: true)]
        var p2: OrderedDictionary<pluginType, erasableData> = [.Today : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false, shouldShowDescription: false)]
        var e: OrderedDictionary<erasableType, erasableData> = [.Cache : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false)]
        var mockedApps: OrderedDictionary<String, AppInfo> = [
            "Tabula Rasa":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000),
            "Tabula Rasa2":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa3":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa4":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa5":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa6":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa7":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa8":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa9":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa10":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa11":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa12":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa13":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa14":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa15":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000),
            //            "Tabula Rasa16":AppInfo(icon: nil, plugins: p2, erasables: e, size: 10000)
        ]
        VStack {
            PluginsListView(apps: .constant(mockedApps), didFinishAnalyzing: .constant(true), shouldShowList: .constant(false), selectionSize: .constant(0))
        }
    }
}
