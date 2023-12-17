//
//  LanguagesListView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 05/03/23.
//

import SwiftUI
import OrderedCollections

struct LanguagesListView: View {
    @Binding var didFinishAnalyzing: Bool
    @Binding var isChecked: Tribool
    @Binding var languages: OrderedDictionary<String, langInfo>
    @Binding var shouldShowList: Bool
    @Binding var selectionSize: Int64
    
    @State private var selectedLanguagesCount = 0
    /// Difference between the sum of the currently selected languages and the category size
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
                    .font(.system(size: 21, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 18, leading: 26, bottom: 21, trailing: 26))
                    .background(shouldShowList ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardBackground") ?? .black)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardSubLayerBackground") ?? .black)))
//                    .cornerRadius(26)
                    .frame(maxWidth: shouldShowList ? .infinity : ((closedinfoBannerWidth == 0) ? nil : closedinfoBannerWidth), alignment: .center)
                    .frame(maxWidth: .infinity) // Centers the view
                //                    .onChange(of: shouldShowList, perform: {newValue in })
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
                    .offset(y: shouldShowList ? openInfoBannerOffset : closedInfoBannerOffset)
                    .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                    .zIndex(-1)
            }
            
            VStack(spacing: 0){
                LazyVStack(spacing: 0) {
                    
                        if shouldShowList {
                            HorizontalDivider()
                                .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                            if didFinishAnalyzing {
                                // List of apps with erasable app specific files
//                                                                                        LazyVStack {
//                                List {
                                ForEach(languages.keys, id: \.self) { languageID in
                                    Button(action: {
                                        //                                    Haptics.shared.select()
                                        //                                    concurrentUIBackgroundQueue.async(flags: .barrier) {
                                        //                                        languages[languageID]!.isChecked.toggle()
                                        //                                        if (languages[languageID]!.isChecked) {
                                        //                                            // Toggle switched to ON
                                        //                                            selectionSize += languages[languageID]!.size.bytes
                                        //                                            selectedLanguagesCount += 1
                                        //                                            if selectedLanguagesCount == languages.count {
                                        //                                                isChecked = true
                                        //                                            } else {
                                        //                                                isChecked = .indeterminate
                                        //                                            }
                                        //                                        } else {
                                        //                                            // Toggle switched to OFF
                                        //                                            selectionSize -= languages[languageID]!.size.bytes
                                        //                                            selectedLanguagesCount -= 1
                                        //                                            if selectedLanguagesCount == 0 {
                                        //                                                isChecked = false
                                        //                                            } else {
                                        //                                                isChecked = .indeterminate
                                        //                                            }
                                        //                                        }
                                        //                                    }
                                        buttonPressed(for: languageID)
                                    }, label: {
                                        HStack{
                                            VStack(alignment: .leading){
                                                Text(languages[languageID]!.name)
                                                    .font(.system(size: 21, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                //                                                    .minimumScaleFactor(0.8)
                                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                                Text(languages[languageID]!.size.formatted)
                                                    .font(.system(size: 16, weight: .regular))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                            }
                                            Spacer()
                                            Toggle(isOn: (toggleValue(for: languageID))) {
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .disabled(true)
                                        }
                                        .padding(.bottom, 20)
                                    })
                                }
//                                                            .frame(height: 800)
//                                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
//                                .animation(nil)
//                                .id(UUID()) // Prevents the list items from sliding in from the top
//                                }
//                                .listStyle(.plain)
//                                .scaledToFill()
//                                .frame(maxHeight: .infinity)
//                                .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
//                                .frame(minHeight: 400)
//                                .id(UUID())
                            } else {
                                // Placeholder to show while apps are still being analyzed
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
                            }
//                        }
                    }
                }
                .padding(EdgeInsets(top: 26, leading: listLateralPadding, bottom: 26, trailing: listLateralPadding))
                //                .frame(minWidth: shouldShowList ? (parentWidth - listLateralPadding * 2) : nil)
                // Due to fixedSize
                .fixedSize() // Prevents the view from lagging when the list is opened and the second banner renders offscreen
                .frame(maxWidth: .infinity)
                .animation(nil)
                .background(shouldShowList ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardBackground") ?? .black)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "CardSubSubLayerBackground") ?? .black)))
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
                        selectedLanguagesCount = languages.count
                        for langID in languages.keys {
                            if languages[langID]!.isChecked == false {
                                languages[langID]!.isChecked = true
                                selectionSizeDifference += languages[langID]!.size.bytes
                            }
                        }
                        selectionSize += selectionSizeDifference
                    } else if isChecked == false {
                        selectionSizeDifference = 0
                        selectedLanguagesCount = 0
                        for langID in languages.keys {
                            if languages[langID]!.isChecked == true {
                                languages[langID]!.isChecked = false
                                selectionSizeDifference -= languages[langID]!.size.bytes
                            }
                        }
                        selectionSize += selectionSizeDifference
                    }
                }
            })
            .onChange(of: didFinishAnalyzing, perform: { _ in
                concurrentUIBackgroundQueue.async(flags: .barrier) {
                    if isChecked == true {
                        selectionSizeDifference = 0
                        selectedLanguagesCount = languages.count
                        for langID in languages.keys {
                            if languages[langID]!.isChecked == false {
                                languages[langID]!.isChecked = true
                                selectionSizeDifference += languages[langID]!.size.bytes
                            } else {
                                selectionSizeDifference += languages[langID]!.size.bytes
                            }
                        }
                        selectionSize += selectionSizeDifference
                    } else if isChecked == false {
                        selectedLanguagesCount = 0
                        for langID in languages.keys {
                            if languages[langID]!.isChecked == true {
                                languages[langID]!.isChecked = false
                            }
                        }
                    }
                }
            })
//            .animation(nil)
            // Since the list uses zIndex, its frame doesn't have the correct height, this creates space to let the list be shown.
            if shouldShowList {
                // NON E VERO Adding all the offsets (the ones used when the list is showing) of the two banners makes the bottom edge of the second banner match the top edge of the bottom on the container of the root VStack, to this we need to add a bottom padding
                Spacer()
                    .frame(height: (openPanelsOffset * 3 - homeVerticalComponentsSpacing * 2))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: shouldShowList ? 0 : bottomPadding, trailing: 0))
//        .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 100, initialVelocity: 0))
    }
    
    private func toggleValue(for languageID: String) -> Binding<Bool> {
        return .init(
            get: { languages[languageID]!.isChecked },
            set: { languages[languageID]!.isChecked = $0 })
    }
     
    private func buttonPressed(for languageID: String) {
        Haptics.shared.select()
        concurrentUIBackgroundQueue.async(flags: .barrier) {
            languages[languageID]!.isChecked.toggle()
            if (languages[languageID]!.isChecked) {
                // Toggle switched to ON
                selectionSize += languages[languageID]!.size.bytes
                selectedLanguagesCount += 1
                if selectedLanguagesCount == languages.count {
                    isChecked = true
                } else {
                    isChecked = .indeterminate
                }
            } else {
                // Toggle switched to OFF
                selectionSize -= languages[languageID]!.size.bytes
                selectedLanguagesCount -= 1
                if selectedLanguagesCount == 0 {
                    isChecked = false
                } else {
                    isChecked = .indeterminate
                }
            }
        }
    }
}


struct LanguagesListView_InteractivePreviews: View {
    @State var isChecked: [Tribool] = [true, false, false, false]
    @State var shouldShowList: [Bool] = [false, false, false, false]
    var body: some View {
        ScrollView {
            CategoryRow(isChecked: $isChecked[0], name: "Additional Languages", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: false, shouldShowList: $shouldShowList[0])
                .zIndex(2)
            LanguagesListView(didFinishAnalyzing: .constant(true), isChecked: $isChecked[0], languages: .constant(languagesList), shouldShowList: $shouldShowList[0], selectionSize: .constant(0))
            CategoryRow(isChecked: $isChecked[1], name: "Database", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: false, shouldShowList: $shouldShowList[1])
            CategoryRow(isChecked: $isChecked[2], name: "Database", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: true, shouldShowList: $shouldShowList[2])
//            CategoryRow(isChecked: $isChecked[3], name: "Database", size: .constant("500 MB"), hasFineSelection: true, requiresManualSelection: true, shouldShowList: $shouldShowList[3])
        }
    }
}

struct LanguagesListView_Previews: PreviewProvider {
    static var previews: some View {
        LanguagesListView_InteractivePreviews()
    }
}
