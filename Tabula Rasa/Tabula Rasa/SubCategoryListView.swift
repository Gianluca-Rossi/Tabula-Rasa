//
//  SubCategoryListView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 25/02/23.
//

import SwiftUI

struct SubCategoryListView: View {
    @Binding var didFinishAnalyzing: Bool
    @Binding var isChecked: Tribool
    @Binding var subCategories: [Category]
    @Binding var shouldShowList: Bool
    @Binding var selectionSize: Int64
    
    @State private var selectedCategoriesCount = 0
    /// Difference between the sum of the currently selected subcategories and the category size
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
            .zIndex(-1)
            
            VStack(spacing: 0){
                LazyVStack(spacing: 26) { //LazyVStack causa jelly effect alla fine della lista se si seleziona un toggle
                    if shouldShowList {
                        HorizontalDivider()
                            .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                        // List of apps with erasable app specific files
                        ForEach(subCategories.indices, id: \.self) { index in
                            Button(action: {
                                Haptics.shared.select()
                                
                                subCategories[index].isChecked.toggle()
                                if (subCategories[index].isChecked.boolValue) {
                                    // Toggle switched to ON
                                    selectionSize += subCategories[index].size.bytes
                                    selectedCategoriesCount += 1
                                    if selectedCategoriesCount == subCategories.count {
                                        isChecked = true
                                    } else {
                                        isChecked = .indeterminate
                                    }
                                } else {
                                    // Toggle switched to OFF
                                    selectionSize -= subCategories[index].size.bytes
                                    selectedCategoriesCount -= 1
                                    if selectedCategoriesCount == 0 {
                                        isChecked = false
                                    } else {
                                        isChecked = .indeterminate
                                    }
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 0){
                                    HStack{ // App icon and name
                                        
                                        VStack(alignment: .leading, spacing: 13){
                                            Text(subCategories[index].name)
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundColor(.white)
                                                .lineLimit(3)
//                                                .minimumScaleFactor(0.8)
                                            HStack{ // App icon and name
                                                Text(subCategories[index].size.formatted)
                                                    .font(.system(size: 21, weight: .medium))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                                // Placeholder to show while apps are still being analyzed
                                                if (subCategories[index].size.formatted == "Analyzing") {
                                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                                        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                                }
                                            }
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 26))
                                        
                                        Spacer()
                                        Toggle(isOn: toggleValue(for: index)) {
                                        }
                                        .toggleStyle(CheckboxStyle())
                                        .disabled(true)
                                    }
                                    if(subCategories[index].description != "") {
                                        Text(subCategories[index].description)
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(EdgeInsets(top: 26, leading: 26, bottom: 26, trailing: 26))
                                .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color.black))
//                                .cornerRadius(26)
                            }
                        }
//                        .animation(nil) // Prevents the list items from sliding in from the top
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
            .zIndex(-2)
            .onChange(of: isChecked, perform: { _ in
                concurrentUIBackgroundQueue.async(flags: .barrier) {
                    if isChecked == true {
                        selectedCategoriesCount = subCategories.count
                        for subIndex in subCategories.indices {
                            if subCategories[subIndex].isChecked == false {
                                subCategories[subIndex].isChecked = true
                                selectionSize += subCategories[subIndex].size.bytes
                            }
                        }
                    } else if isChecked == false {
                        selectedCategoriesCount = 0
                        for subIndex in subCategories.indices {
                            if subCategories[subIndex].isChecked == true {
                                subCategories[subIndex].isChecked = false
                                selectionSize -= subCategories[subIndex].size.bytes
                            }
                        }
                    }
                }
            })
            .onChange(of: didFinishAnalyzing, perform: { _ in
                concurrentUIBackgroundQueue.async(flags: .barrier) {
                    if isChecked == true {
                        selectionSizeDifference = 0
                        selectedCategoriesCount = subCategories.count
                        for subIndex in subCategories.indices {
                            if subCategories[subIndex].isChecked == false {
                                subCategories[subIndex].isChecked = true
                                selectionSizeDifference += subCategories[subIndex].size.bytes
                            } else {
                                selectionSizeDifference += subCategories[subIndex].size.bytes
                            }
                        }
                        selectionSize += selectionSizeDifference
                    } else if isChecked == false {
                        selectedCategoriesCount = 0
                        for subIndex in subCategories.indices {
                            if subCategories[subIndex].isChecked == true {
                                subCategories[subIndex].isChecked = false
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
    }
    
    private func toggleValue(for index: Int) -> Binding<Bool> {
        return .init(
            get: { (subCategories[index].isChecked == true) },
            set: { if $0 {
                subCategories[index].isChecked = true
            } else {
                subCategories[index].isChecked = false
            }})
    }
}

//
//struct SubCategoryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubCategoryListView()
//    }
//}
