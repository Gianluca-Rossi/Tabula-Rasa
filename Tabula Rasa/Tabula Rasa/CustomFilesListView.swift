//
//  CustomFilesView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 18/03/23.
//

import SwiftUI
import OrderedCollections

struct CustomFilesListView: View {
    @Binding var shouldShowList: Bool
    @Binding var selectionSize: Int64
    
    @State private var closedInfoBannerHeight : CGFloat = 0
    @State private var closedinfoBannerWidth : CGFloat = 0
    @State private var closedInfoBannerOffset: CGFloat = 0
    @State private var closedListPanelHeight: CGFloat = 0
    @State private var closedListPanelOffset: CGFloat = 0
    @State private var parentWidth: CGFloat = UIScreen.main.bounds.size.width - 52 - 26
    
    @State private var bottomPadding: CGFloat = 0
    
    
    @State var selectedEntries = Set<FileNavigatorItem>()
    @State var viewsToDismiss = 0
    @State var shouldOpenFileNavigator = false
    
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
//                        ForEach(appsToShow, id: \.self) { app in
//                            if (apps[app]!.appSpecificErasablesSize > 0) {
//                                VStack(alignment: .leading){
//                                    HStack{ // App icon and name
//                                        //                                        AppIcon(icon: apps[app]!.icon)
//                                        if (apps[app]?.icon != nil) {
//                                            Image(uiImage: (apps[app]!.icon!))
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 38.0, height: 38.0)
//                                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                        } else {
//                                            if #available(iOS 15.0, *) {
//                                                Image(systemName: "questionmark.app.dashed")
//                                                    .symbolRenderingMode(.hierarchical)
//                                                    .font(.system(size: 42))
//                                                    .foregroundColor(.white)
//                                                    .scaledToFit()
//                                                    .frame(width: 38.0, height: 38.0)
//                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                            } else {
//                                                Image("questionmark.app.dashed")
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 38.0, height: 38.0)
//                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                            }
//                                        }
//                                        Text("\(app)")
//                                            .font(.system(size: 21, weight: .bold))
//                                            .foregroundColor(.white)
//                                            .lineLimit(1)
//                                            .minimumScaleFactor(0.5)
//                                            .fixedSize()
//                                            .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
//                                    }
//                                    SubListRowView(app: app, apps: $apps, selectionSize: $selectionSize)
//                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 26, trailing: 0))
//                                }
//                            }
//                        }
                        
                            //                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .move(edge: .bottom)), removal: AnyTransition.opacity.combined(with:.move(edge: .top))))
                            
                        Button(action: {
                            shouldOpenFileNavigator = true
                        }, label: {
                            Text("apri")
                        }).sheet(isPresented: $shouldOpenFileNavigator,
                                 onDismiss: nil) {
                            ZStack(alignment: .top) {
                                NavigationView {
                                    AddCustomFilesView()
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button(action: {
                                                    selectedEntries = Set<FileNavigatorItem>()
                                                    shouldOpenFileNavigator = false
                                                }, label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)
                                                        .font(.system(size: 32, weight: .semibold))
                                                        .background(Blur(style: .systemChromeMaterial))
                                                })
                                            }
                                        }
                                }
                                .navigationViewStyle(StackNavigationViewStyle())
                                .accentColor(Color(UIColor.tertiaryLabel))
                                Capsule()
                                    .fill(Color(UIColor.tertiaryLabel))
                                    .frame(width: 35, height: 5)
                                    .padding(6)
                            }
                        }
                        
                        
                            // List of installed apps with no erasable app specific files
//                            ForEach(appsToShow, id: \.self) { app in
//                                if (apps[app]!.isInstalled && apps[app]!.appSpecificErasablesSize == 0) {
//                                    VStack(alignment: .leading){
//                                        HStack{ // App icon and name
//                                            //                                        AppIcon(icon: apps[app]!.icon)
//                                            if (apps[app]?.icon != nil) {
//                                                Image(uiImage: (apps[app]!.icon!))
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 38.0, height: 38.0)
//                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                            } else {
//                                                if #available(iOS 15.0, *) {
//                                                    Image(systemName: "questionmark.app.dashed")
//                                                        .symbolRenderingMode(.hierarchical)
//                                                        .font(.system(size: 42))
//                                                        .foregroundColor(.white)
//                                                        .scaledToFit()
//                                                        .frame(width: 38.0, height: 38.0)
//                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                                } else {
//                                                    Image("questionmark.app.dashed")
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(width: 38.0, height: 38.0)
//                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                                }
//                                            }
//                                            Text("\(app)")
//                                                .font(.system(size: 21, weight: .bold))
//                                                .foregroundColor(.white)
//                                                .lineLimit(1)
//                                                .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
//                                        }
//                                        SubListRowView(app: app, apps: $apps, selectionSize: $selectionSize)
//                                    }
//                                }
//                            }
                            //                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .move(edge: .bottom)), removal: AnyTransition.opacity.combined(with:.move(edge: .top))))
                            
                            // Placeholder to show while apps are still being analyzed
//                            if (appsToShow.isEmpty) {
//                                HStack(spacing: 0) {
//                                    Spacer()
//                                    Text("Analyzing")
//                                        .font(.system(size: 21, weight: .medium))
//                                        .foregroundColor(.white)
//                                        .padding(0)
//                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
//                                        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
//                                    Spacer()
//                                }
//                                //                            .transition(.opacity)
//                            }
                        }
                    }
                        .padding(EdgeInsets(top: 26, leading: listLateralPadding, bottom: 26, trailing: listLateralPadding))
                    //                .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                    // Due to fixedSize
                        .fixedSize() // Prevents the view from lagging when the list is opened and the second banner renders offscreen
                        .frame(maxWidth: .infinity)
                        .animation(nil)
                        .background(shouldShowList ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardBackground") ?? .black)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardSubSubLayerBackground") ?? .black)))
//                        .cornerRadius(26)
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
                .animation(nil)
                // Since the list uses zIndex, its frame doesn't have the correct height, this creates space to let the list be shown.
                if shouldShowList {
                    // NON E VERO Adding all the offsets (the ones used when the list is showing) of the two banners makes the bottom edge of the second banner match the top edge of the bottom on the container of the root VStack, to this we need to add a bottom padding
                    Spacer()
                    .frame(height: (openPanelsOffset * 3 - homeVerticalComponentsSpacing * 2))
                }
            
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: shouldShowList ? 0 : bottomPadding, trailing: 0))
        }
    }

//struct CustomFilesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomFilesListView()
//    }
//}
