//
//  ContentView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 30/12/22.
//

import SwiftUI
import OrderedCollections

let homeVerticalComponentsSpacing: CGFloat = 8

struct ContentView: View {
    
    @State var categories: [Category] = categoryArray
    //    @State var value: Int64 = -1
    @State var size: String = ""
    @State var selectionSize: Int64 = 0
    @State var totalDbReclaimableSpace: Int64 = 0
    @State var totalFilesReclaimableSize: Int64 = 0
    //    @State var totalReclaimableSize: Int64 = 0
    @State var sizeMeasure: String = ""
    //    @State var checkIfAppsCategoryShouldBeChecked: Bool = false
    //    @State var checkIfAppsSpecificFilesShouldBeChecked: Bool = false
    //    @State var checkIfAppsPluginsShouldBeChecked: Bool = false
    //    @State var log: [String] = []
    //    @Binding var hasRoot: Bool
    @State var apps: OrderedDictionary<String, AppInfo> = [:]// = appList
    @State var appDbs: OrderedDictionary<String, DatabasesInfo> = [:]//appDatabases
    @State var isRespringing: Bool = false
    
    @State var appsWithSpecificFilesToShow: [String] = []
    @State var installedApps: [String] = []
    @State var isOffscreen: [Bool] = Array(repeating: false, count: categoryArray.count)
    //    @State var isPressed: [Bool] = Array(repeating: false, count: categoryArray.count)
    @State var languages: OrderedDictionary<String, langInfo> = [:]
    
    //    let concurrentDbQueue = DispatchQueue(label: "it.concurrentDb", qos: .default, attributes: .concurrent)
    let x = FileManager.default
    //    var i = 0
    //    var dbReclaimableSpace: Int64 = 0
    @State var totalAdditionalLanguagesSize: Int64 = 0
    @State var totalSystemGroupsSize: Int64 = 0
    
    @State var selectedEntries = Set<FileNavigatorItem>()
    //    @State var didFinishAnalyzingDatabases = false
    @State var didFinishAnalyzingCategories = false
    @State var didFinishAnalyzingDatabases = false
    @State var viewsToDismiss = 0
    @State var shouldOpenFileNavigator = false
    @State var shouldShowDeletionScreen = false
    //@State var dbShrinkingResult: ([String], Int64) //= ([],0)
    @State var timeElapsed = TimeInterval()
    
    @State var selectionSizeFormatted = "Nothing to delete"
    @State var totalDbReclaimableSpaceFormatted = "Nothing to delete"
    
    @State var pathComponents: [String] = []
    
    @State var currentPath = rootURL
    
    //    var deleteIcon: UIImage = (UIImage(systemName: "trash.fill", withConfiguration: (UIImage.SymbolConfiguration(pointSize: 32))) ?? UIImage())
    
    @State private var frames: [frameWithID] = []
    @State private var viewThatShouldNotBeAnimated: Int = -1
    
    var body: some View {
        ZStack {
            ScrollViewReader { value in
                ScrollView(.vertical) {
                    VStack(spacing: homeVerticalComponentsSpacing) {
                        RecapHeader(size: $size, sizeMeasure: $sizeMeasure) //causa il resize dei nomi delle categorie quando si apre una lista
                        //                    List {
                        //                        Text(logArr.description)
                        //                            .font(.system(size: 8, weight: .regular, design: .default))
                        //                            .padding(16)
                        ////                            .frame(height: 300)
                        //                            .frame(maxWidth: .infinity)//, maxHeight: .infinity)
                        //                            .background(Color.black)
                        //                            .foregroundColor(Color.white)
                        //                            .cornerRadius(12)
                        //                        //                    .layoutPriority(1)
                        //                    }
                        //                    //.frame(height: 1000)
                        //                    .frame(maxWidth: .infinity)
                        //                    LoadingProgressView()
                        //                        .animation(nil)
                        //                        NavigationLink(destination: FileNavigatorView(url: userDocumentsURL, selection: $selectedEntries)) {
                        //                        AddCustomFilesView()
                        //                        Button(action: {
                        //                            shouldOpenFileNavigator = true
                        //
                        //                        }) {
                        //                                Text("Open File Navigator")
                        //                                    .font(.system(size: 24, weight: .bold, design: .default))
                        //                                    .padding(16)
                        //                                    .frame(maxWidth: .infinity)
                        //                                    .background(Color.black)
                        //                                    .foregroundColor(Color.white)
                        //                                    .cornerRadius(12)
                        //                            }.sheet(isPresented: $shouldOpenFileNavigator,
                        //                                    onDismiss: nil) {
                        //                                ZStack(alignment: .top) {
                        //                                    NavigationView {
                        //
                        //                                        AddCustomFilesView()
                        //                                        FileNavigatorView(currentPath: $currentPath, url: rootURL, selection: $selectedEntries, viewsToDismiss: $viewsToDismiss)
                        //                                            .navigationBarTitle(rootURL.lastPathComponent)
                        //                                            .toolbar {
                        ////                                            ToolbarItem(placement: .bottomBar) {
                        ////                                                Button("Cancel") {
                        ////                                                    shouldOpenFileNavigator = false
                        ////                                                }
                        ////                                            }
                        //
                        //                                                ToolbarItem(placement: .automatic) {
                        //                                                    EmptyView()
                        //                                                }
                        ////                                                ToolbarItem(placement: .bottomBar) {
                        ////                                                    Button("Done") {
                        ////                                                        shouldOpenFileNavigator = false
                        ////                                                    }
                        ////                                                }
                        //                                            }
                        //                                    }
                        //                                    Capsule()
                        //                                        .fill(Color.secondary)
                        //                                        .opacity(0.5)
                        //                                        .frame(width: 35, height: 5)
                        //                                        .padding(6)
                        //                                    ScrollViewReader { value in
                        //                                        ScrollView(.horizontal, showsIndicators: false) {
                        //                                                HStack {
                        //                                                    ForEach(pathComponents.indices, id: \.self) { index in
                        //                                                        Button(action: {
                        //                                                            //                                                                        shouldOpenFileNavigator = false
                        //                                                        }) {
                        //                                                            Text(pathComponents[index])
                        //                                                            //                                                                            .font(.headline)
                        //                                                                .foregroundColor(Color.black)
                        //                                                                .padding(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                        //                                                                .overlay(
                        //                                                                    RoundedRectangle(cornerRadius: 26)
                        //                                                                        .strokeBorder(Color(UIColor(named: "CardBorder") ?? .white), lineWidth: 1)
                        //                                                                )
                        //                                                                .id(index)
                        //                                                            if ((pathComponents.count - 1) != index) {
                        //                                                                Image(systemName: "arrowtriangle.right.fill")
                        //                                                                    .resizable()
                        //                                                                    .frame(width: 10, height: 10)
                        //                                                                    .foregroundColor(Color(UIColor(named: "CardBorder") ?? .white))
                        //                                                                    .padding(0).id(index)
                        //                                                                //                                                                .font(.system(size: 32, weight: .semibold))
                        //                                                            } else {
                        //                                                                Spacer(minLength: 16)
                        //                                                            }
                        //                                                        }
                        //                                                    }
                        //                                                    .onAppear(perform: {
                        //                                                        value.scrollTo((pathComponents.count - 1), anchor: UnitPoint.bottomTrailing)
                        //                                                    })
                        //                                                }.padding(EdgeInsets(top: 26, leading: 16, bottom: 0, trailing: 0))
                        //                                        }
                        //                                        .onAppear(perform: {
                        //                                            print("pathc")
                        //                                            pathComponents = userDocumentsURL.pathComponents
                        //                                            print(pathComponents)
                        //                                        })
                        //                                    }
                        //                                    VStack {
                        //                                        Spacer()
                        //                                        Button(action: {
                        //                                            print("Erase")
                        //
                        //                                            // Update the arrays with the user selection
                        //                                            appList = apps
                        //                                            categoryArray = categories
                        //                                            languagesList = languages
                        //                                            appDatabases = appDbs
                        //                                            deleteSelectedFiles()
                        //                                        }) {
                        //                                            ZStack(alignment: .center){
                        //                                                HStack(alignment: .center){
                        //                                                    VStack(alignment: .center){
                        //                                                        Text(selectedEntries.count == 0 ? "Select some files to delete" : "Select \(selectedEntries.count) elements")
                        //                                                            .font(.system(size: 18, weight: .medium))
                        //                                                            .foregroundColor(.white)
                        //                                                            .padding(EdgeInsets(top: selectionSizeFormatted == "Nothing to delete" ? 0 : 16, leading: 0, bottom: 0, trailing: 0))
                        //                                                        //                                                                .onChange(of: selectionSize, perform: { _ in
                        //                                                        //                                                                    print("selection size cambiata")
                        //                                                        //                                                                    selectionSizeFormatted = selectionSize.formatBytes()
                        //                                                        //                                                                })
                        //                                                    }
                        //                                                }
                        //                                            }
                        //                                            .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        //                                            .background(selectedEntries.count == 0 ? Color(UIColor(named: "EraseButtonDisabled") ?? .gray) : Color(UIColor(named: "EraseButtonActive") ?? .blue))
                        //                                            .cornerRadius(26)
                        //                                            .overlay(
                        //                                                RoundedRectangle(cornerRadius: 26)
                        //                                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        //                                            )
                        //                                            .shadow(color: selectedEntries.count == 0 ? Color.gray.opacity(0.17) : Color.blue.opacity(0.17), radius: 4, y: 2)
                        //                                            .animation(.easeInOut)
                        //                                        }
                        //                                        .disabled(selectedEntries.count == 0 ? true : false)
                        //                                    }
                        //                                    .frame(alignment: .bottom)
                        //                                    .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                        //                                }
                        //                            }
                        //                            }
                        
                        //                        .toolbar {
                        //                            ToolbarItem(placement: .navigation) {
                        //                                VStack(alignment: .leading) {
                        //                                    Text("Select files")
                        //                                        .font(.largeTitle)
                        //                                        .fontWeight(.bold)
                        //                                    Text("/")
                        //                                        .font(.headline)
                        //                                }
                        //                            }
                        //                        }
                        //                        }
                        //                        Button(action: {
                        //                            isRespringing = true
                        //                            // RESPRING WITH killall -9 SpringBoard
                        //                            guard let window = UIApplication.shared.windows.first else { return }
                        //                            while true {
                        //                                window.snapshotView(afterScreenUpdates: false)
                        //                            }
                        //                        }) {
                        //                            HStack {
                        //                                Text("Respring")
                        //                                    .font(.system(size: 24, weight: .bold, design: .default))
                        //                                    .padding(16)
                        //                                    .frame(maxWidth: .infinity)
                        //                                    .background(Color.blue)
                        //                                    .foregroundColor(Color.white)
                        //                                    .cornerRadius(12)
                        //                                if isRespringing {
                        //                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        //                                        .padding(20)
                        //                                        .background(Color.blue)
                        //                                        .cornerRadius(12)
                        //                                }
                        //                            }
                        //                        }
                        //                        Button(action: {
                        //                            findAllDbs()
                        //                        }) {
                        //                            Text("Generate database list file")
                        //                                .font(.system(size: 24, weight: .bold, design: .default))
                        //                                .padding(16)
                        //                                .frame(maxWidth: .infinity)
                        //                                .background(Color.purple)
                        //                                .foregroundColor(Color.white)
                        //                                .cornerRadius(12)
                        //                        }
                        //                        Button(action: {
                        //                            //                            analyzeDatabases()
                        //                        }) {
                        //                            ZStack{
                        //                                Text(totalDbReclaimableSpaceFormatted == "Nothing to delete" ? "Select DB to Shrink" : "Shrink DB")
                        //                                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: totalDbReclaimableSpaceFormatted == "Nothing to delete" ? .center : .top)
                        //                                    .font(.system(size: 18, weight: .medium, design: .default))
                        //                                    .foregroundColor(.white)
                        //                                    .padding(EdgeInsets(top: totalDbReclaimableSpaceFormatted == "Nothing to delete" ? 0 : 16, leading: 0, bottom: 0, trailing: 0))
                        //
                        //                                Text(totalDbReclaimableSpaceFormatted == "Nothing to delete" ? "" : "\(totalDbReclaimableSpaceFormatted)")
                        //                                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .bottom)
                        //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                        //                                    .font(.system(size: 24, weight: .bold, design: .default))
                        //                                    .foregroundColor(.white)
                        //                            }
                        //                            .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .top)
                        //                            .background(totalDbReclaimableSpaceFormatted == "Nothing to delete" ? Color(UIColor(named: "EraseButtonDisabled") ?? UIColor(Color.gray)) : Color(UIColor(named: "ShrinkDBButtonActive") ?? UIColor(Color.green)))
                        //                            .cornerRadius(26)
                        //                            .overlay(
                        //                                RoundedRectangle(cornerRadius: 26)
                        //                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        //                            )
                        //                            .shadow(color: totalDbReclaimableSpaceFormatted == "Nothing to delete" ? Color.gray.opacity(0.17) : Color.blue.opacity(0.17), radius: 4, y: 2)
                        //                            .animation(.easeInOut)
                        //                        }
                        //                        //                        .disabled(selectionSizeFormatted == "Nothing to delete" ? true : false)
                        //                        //.frame(alignment: .bottom)
                        //                        .onAppear {
                        //                            //analyzeDatabases()
                        //                        }
                        
                        //                        Button(action: {
                        //                            analyzeErasables()
                        //                        }) {
                        //                            Text("Analyzed in \(timeElapsed) ms")
                        //                                .font(.system(size: 24, weight: .bold, design: .default))
                        //                                .padding(16)
                        //                                .frame(maxWidth: .infinity)
                        //                                .background(Color.yellow)
                        //                                .foregroundColor(Color.black)
                        //                                .cornerRadius(12)
                        //                        }
                        ForEach(categories.indices, id: \.self) { i in
                            
                            CategoryRow(isChecked: $categories[i].isChecked, name: categories[i].name, size: $categories[i].size.1, hasFineSelection: categories[i].hasFineSelection, isOffScreen: $isOffscreen[i], requiresManualSelection: categories[i].requiresManualSelection, shouldShowList: $categories[i].shouldShowList)
                                .onChange(of: categories[i].shouldShowList, perform: { wasOpened in
                                    // If the category is closed and it is offscreen, put the category on top of the screen when it gets closed
                                    if !wasOpened {
                                        // Resetting the ability to animate to other categories
//                                        isOffscreen = Array(repeating: false, count: categoryArray.count)
//                                        print("Resetting offScreen values")
//                                        for index in 0 ..< frames.count {
//                                            if frames[index].value.id == i {
//                                                if frames[index].value.frame.minY < 0 {
//                                                    isOffscreen[i] = true
                                                    //                                                    print(isOffscreen)
                                        if isOffscreen[i] {
                                            value.scrollTo(i, anchor: .top)
                                        }
//                                                    print("don't animate: " + categories[i].name)
//                                                }
//                                                break
//                                            }
//                                        }
                                    }
                                })
//                                .animation(isOffscreen[i] ? nil : .interpolatingSpring(mass: 1, stiffness: 700, damping: 100, initialVelocity: 0))
//                                .animation(isOffscreen[i] ? nil :
//                                            (categories[i].shouldShowList ?
//                                             nil :
//                                                    .interpolatingSpring(mass: 1, stiffness: 500, damping: 100, initialVelocity: 0)))
                                .id(i)
                                .sticky(id: i, shouldStick: $categories[i].shouldShowList, frames)
                                .zIndex(1)
                                .onChange(of: categories[i].isChecked, perform: { newCheckValue in
                                    if !categories[i].hasFineSelection {
                                        if newCheckValue == true {
                                            selectionSize += categories[i].size.0
                                        } else if newCheckValue == false {
                                            selectionSize -= categories[i].size.0
                                        }
                                    }
                                })
                            
                            if (categories[i].name == "Apps Cache") {
                                AppRow(apps: $apps, didFinishAnalyzing: $didFinishAnalyzingCategories, installedApps: $installedApps, isChecked: $categories[i].isChecked, selectionSize: $selectionSize, shouldShowList: $categories[i].shouldShowList)
                            } else if (categories[i].name == "Databases") {
                                DatabasesListView(apps: $apps, appDbs: $appDbs, didFinishAnalyzing: $didFinishAnalyzingDatabases, isChecked: $categories[i].isChecked, selectionSize: $selectionSize, shouldShowList: $categories[i].shouldShowList)
                            } else if (categories[i].name == "App Plugins") {
                                PluginsListView(apps: $apps, didFinishAnalyzing: $didFinishAnalyzingCategories, shouldShowList: $categories[i].shouldShowList, selectionSize: $selectionSize)
                            } else if (categories[i].name == "App Specific Files") {
                                AppSpecificListView(apps: $apps, didFinishAnalyzing: $didFinishAnalyzingCategories, isChecked: $categories[i].isChecked, shouldShowList: $categories[i].shouldShowList, selectionSize: $selectionSize, appsToShow: $appsWithSpecificFilesToShow)
                            } else if (categories[i].name == "Additional Languages") {
                                LanguagesListView(didFinishAnalyzing: $didFinishAnalyzingCategories, isChecked: $categories[i].isChecked, languages: $languages, shouldShowList: $categories[i].shouldShowList, selectionSize: $selectionSize)
                            } else if (categories[i].name == "Custom files") {
                                CustomFilesListView(shouldShowList: $categories[i].shouldShowList, selectionSize: $selectionSize)
                            } else if (!categories[i].subCategories.isEmpty) {
                                SubCategoryListView(didFinishAnalyzing: $didFinishAnalyzingCategories, isChecked: $categories[i].isChecked, subCategories: $categories[i].subCategories, shouldShowList: $categories[i].shouldShowList, selectionSize: $selectionSize)
                            }
                        }
                        Spacer(minLength: 100)
                    }
                    //                .onChange(of: selectionSize, perform: { _ in
                    //                    print("selection size cambiata")
                    //                    selectionSizeFormatted = selectionSize.formatBytes()
                    //                })
                    .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                    
                }
                .onChange(of: frames, perform: { _ in
                    
                    
                    for index in 0 ..< frames.count {
                        if frames[index].value.frame.minY < 0 {
                            if (isOffscreen[index] == false) {
                                // Resetting the ability to animate to other categories
                                isOffscreen = Array(repeating: false, count: categoryArray.count)
                                
                                isOffscreen[index] = true
                                print(categories[index].name + " is Off Screen")
                            }
//                            break
                        }
                    }
                })
                .padding(0)
                .coordinateSpace(name: "CategoriesScrollView")
                .onPreferenceChange(FramePreference.self, perform: {
//                    for i in categories.indices {
//                        if categories[i].shouldShowList {
//                            for frame in $0 {
//                                if frame.value.id == i {
//                                    if frame.value.frame.minY < 0 {
//                                        isOffscreen[i] = true
//                                    }
//                                    break
//                                }
//                            }
//                        }
//                    }
                    frames = $0.sorted(by: { $0.value.frame.minY < $1.value.frame.minY
                    })
                })
            }
            VStack(){
                Spacer()
                Button(action: {
                    print("Erase")
                    
                    // Update the arrays with the user selection
                    appBundleList = apps
                    categoryArray = categories
                    //                        for catIndex in categories.indices {
                    //                            for subIndex in categories[catIndex].subCategories.indices {
                    //                                if categories[catIndex].isChecked == true {
                    //                                    categories[catIndex].subCategories[subIndex].isChecked = true
                    //                                } else if categories[catIndex].isChecked == false {
                    //                                    categories[catIndex].subCategories[subIndex].isChecked = false
                    //                                }
                    //                            }
                    //                        }
                    languagesList = languages
                    appDatabases = appDbs
                    shouldShowDeletionScreen = true
                    //                        deleteSelectedFiles()
                }) {
                    ZStack(alignment: .center){
                        HStack(alignment: .center){
                            if (selectionSizeFormatted != "Nothing to delete") {
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 30))
                                    .accentColor(.white)
                                    .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: 0))
                            }
                            VStack(alignment: .center){
                                Text(selectionSizeFormatted == "Nothing to delete" ? "Select something to delete" : "Erase")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: selectionSizeFormatted == "Nothing to delete" ? 0 : 16, leading: 0, bottom: 0, trailing: 0))
                                    .onChange(of: selectionSize, perform: { _ in
                                        print("selection size cambiata")
                                        selectionSizeFormatted = selectionSize.formatBytes()
                                    })
                                if (selectionSizeFormatted != "Nothing to delete") {
                                    Text("\(selectionSizeFormatted)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                                        .font(.system(size: 24, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                }
                            }
                            if (selectionSizeFormatted != "Nothing to delete") {
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(selectionSizeFormatted == "Nothing to delete" ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "EraseButtonDisabled") ?? .gray)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "EraseButtonActive") ?? .blue)))
                    //                    .cornerRadius(26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: selectionSizeFormatted == "Nothing to delete" ? Color.gray.opacity(0.17) : Color.blue.opacity(0.17), radius: 4, y: 2)
                    .animation(.easeInOut)
                }
                .disabled(selectionSizeFormatted == "Nothing to delete" ? true : false)
            }
            .frame(alignment: .bottom)
            .onAppear {
                // Activate the console view.
                //                consoleManager.isVisible = true
                createAndStartHapticEngine()
                analyzeErasables()
                //                findAllDbs()
                setup()
            }
            .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
            .transition(.move(edge: .bottom))
            
            // Hide Navigation Link
            NavigationLink("", destination: DeletionView(totalSizeToDelete: selectionSizeFormatted, totalApps: -1)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true),
                           isActive: $shouldShowDeletionScreen)
            
        }.background(Color(UIColor(named: "BackgroundColor") ?? .black)
            .edgesIgnoringSafeArea(.vertical))
    }
    
    func setup() {
        concurrentQueue.async {
            MyRelativeDateFormatter()
        }
    }
    
    func findAllDbs() {
        concurrentQueue.async {
            scanAllSystemDbs()
        }
    }
    
    func analyzeDatabases() {
        //        let methodStart = Date()
        //        didFinishAnalyzingDatabases = false
        //        size = "Analyzing"
        //        totalDbReclaimableSpace = 0
        //        totalDbReclaimableSpaceFormatted = "Analyzing"
        //        var dbShrinkingResult: ([String], Int64) = ([], 0)
        //        for dbIndex in 0..<databases.count {
        //            concurrentDbQueue.async {
        //                dbShrinkingResult = shrinkDatabase(&databases[dbIndex], shouldApplyShrinking: false)
        //                totalDbReclaimableSpace += dbShrinkingResult.1
        //                log.append(contentsOf: dbShrinkingResult.0)
        //            }
        //        }
        //
        //        concurrentDbQueue.async (flags: .barrier) {
        //            let methodFinish = Date()
        //            let timeElapsed = String(format: "%.2f", methodFinish.timeIntervalSince(methodStart))
        //            totalDbReclaimableSpaceFormatted = ("\(ByteCountFormatter.string(fromByteCount: totalDbReclaimableSpace, countStyle: .memory)) in \(timeElapsed) seconds")
        //            log.append("Storage Reclaimable after compression: \(totalDbReclaimableSpaceFormatted)")
        //            print("Storage Reclaimable after compression: \(totalDbReclaimableSpaceFormatted)")
        //            didFinishAnalyzingDatabases = true
        //            if didFinishAnalyzingCategories {
        //                updateHeader()
        //            }
        //        }
    }
    
    
    func analyzeErasables() {
//        try? RootConf.shared.contents(of: Bundle.main.bundleURL)
        
        var possibleDeviceLanguagesReferences: [[String]?] = [Locale.preferredLanguages, [Locale.current.regionCode ?? "", Locale.current.languageCode ?? "", Locale.current.identifier], UserDefaults.standard.stringArray(forKey: "AppleLanguages")] //TEST ,[""], []]
        for langArray in possibleDeviceLanguagesReferences {
            for languageCode in langArray ?? [] {
                let lang = languageCode.lowercased()
                print("found user language: \(lang)")
            }
        }
        // Set uid and gid
        if (!(setuid(0) == 0 && setgid(0) == 0)) {
            print("NIENTE ROOT")
            //            exit(EXIT_FAILURE);
        } else {
            print("ROOT PERMISSIONS")
        }
        
        let possibleDeviceLanguagesReferences2: [[String]?] = [Locale.preferredLanguages, [Locale.current.regionCode ?? "", Locale.current.languageCode ?? "", Locale.current.identifier], UserDefaults.standard.stringArray(forKey: "AppleLanguages")] //TEST ,[""], []]
        for langArray in possibleDeviceLanguagesReferences2 {
            for languageCode in langArray ?? [] {
                let lang = languageCode.lowercased()
                print("found user language: \(lang)")
            }
        }
        let methodStart = Date()
        let methodStartDB = Date()
        didFinishAnalyzingCategories = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            // Delay required to trigger shine effect and correct writing effect
            size = "Analyzing"
        }
        
        //        totalFilesReclaimableSize = 0
        totalDbReclaimableSpace = 0
        concurrentQueue.async {
            do {
                try totalSystemGroupsSize = x.allocatedSizeOfSystemGroups()
                // consoleManager.print(formattedSize)
            } catch {
                // consoleManager.print("RRRORE")
            }
        }
        
        concurrentQueue.async {
            do {
                try x.allocatedSizeOfApps()// { //se lancio la cancellazione di qualcosa prima che questa categoria ha terminato crasha: Thread 4: Fatal error: Index out of range
                //                    group.leave()
                logArr.append("🆘🆘🆘🆘allocatedSizes FINISHED")
                //                }
            } catch {
                print("errorrr")
            }
        }
        
        concurrentQueue.async {
            scanLocalizationFiles()
        }
        
        for index in 0..<categories.count {
            concurrentQueue.asyncAfter(deadline: .now() + 0.0) {
                // Delay required to trigger shine effect and correct writing effect
                categories[index].size.formatted = "Analyzing"
                totalFilesReclaimableSize += analyzeCategoryErasables(categoryIndex: index)
                print("ho finito di analizzare la categoria \(categories[index].name)")
            }
        }
        
        concurrentQueue.async (flags: .barrier) {
            logArr.append("✳️✳️✳️✳️updateSizes STARTED")
            print("✳️✳️✳️✳️concurrentqueue finita")
            
            concurrentAppsQueue.async (flags: .barrier) {
                print("✳️✳️ apps queue finito")
                
                concurrentAppGroupsRetrieverQueue.async (flags: .barrier) {
                    concurrentAppPluginsQueue.async (flags: .barrier) {
                        print("✳️✳️ apps plugin finito")
                        for i in categories.indices {
                            if (categories[i].name == "Apps Cache") {
                                categories[i].size.bytes = totalAppsCache
                                categories[i].size.formatted = totalAppsCache.formatBytes()
                            } else if (categories[i].name == "App Plugins") {
                                categories[i].size.bytes = totalPluginsSize
                                categories[i].size.formatted = totalPluginsSize.formatBytes()
                            } else if (categories[i].name == "App Specific Files") {
                                categories[i].size.bytes = totalCustomPathAppSpecificErasablesSize
                                categories[i].size.formatted = totalCustomPathAppSpecificErasablesSize.formatBytes()
                            } else if (categories[i].name == "Additional Languages") {
                                totalAdditionalLanguagesSize = contSharedLang + contDataLang + contBundleLang - excludedLanguagesSize
                                categories[i].size.bytes = totalAdditionalLanguagesSize
                                categories[i].size.formatted = categories[i].size.bytes.formatBytes()
                            } else if (categories[i].name == "System Groups") {
                                categories[i].size.bytes = totalSystemGroupsSize
                                categories[i].size.formatted = totalSystemGroupsSize.formatBytes()
                            }
                        }
                        
                        // Update selection size so if some category was selected before the size was calculated, now the selection size shows the correct size
                        for category in categories {
                            if !category.hasFineSelection {
                                if (category.isChecked == true) {
                                    selectionSize += category.size.bytes
                                    continue
                                }
                                for subcategory in category.subCategories {
                                    if (subcategory.isChecked == true) {
                                        selectionSize += subcategory.size.bytes
                                    }
                                }
                            }
                        }
                        print("copio appBundleList in apps")
                        apps = OrderedDictionary(uniqueKeys: appBundleList.keys, values: appBundleList.values)
                        //                        print("apps disordinato")
                        apps.sort { $0.value.appName.localizedStandardCompare($1.value.appName) == .orderedAscending }
                        for app in apps.keys {
                            if apps[app]!.isInstalled {
                                installedApps.append(app)
                            }
                            
                            // Include also apps that are no longer installed but have leftovers files
                            if apps[app]!.shouldShowAppSpecificErasables && apps[app]!.appSpecificErasablesSize > 0 {
                                appsWithSpecificFilesToShow.append(app)
                            }
                        }
                        print("installedApps: \(installedApps)")
                        print("appsWithSpecificFilesToShow: \(appsWithSpecificFilesToShow)")
                        //                        print("apps ordinato")
                        //                        print(apps)
                        languages = OrderedDictionary(uniqueKeys: languagesList.keys, values: languagesList.values)
                        languages.sort { $0.value.name.localizedStandardCompare($1.value.name) == .orderedAscending }
                        let methodFinish = Date()
                        timeElapsed = methodFinish.timeIntervalSince(methodStart)
                        //                print("finished")
                        didFinishAnalyzingCategories = true
                        print("HO FINITO DI ANALIZZARE LE CATEGORIE E LE APP")
                        
                        concurrentDbShrinkingQueue.async (flags: .barrier) {
                            let methodFinishDB = Date()
                            let timeElapsed2 = methodFinishDB.timeIntervalSince(methodStartDB)
                            print("DB finito in \(timeElapsed2)")
                            appDbs = OrderedDictionary(uniqueKeys: appDatabases.keys, values: appDatabases.values)
                            appDbs.sort()
                            didFinishAnalyzingDatabases = true
                            // Update selection size so if some category was selected before the size was calculated, now the selection size shows the correct size
                            for index in categories.indices {
                                if (categories[index].name == "Databases" && categories[index].isChecked == true){
                                    selectionSize += categories[index].size.bytes
                                }
                            }
                            selectionSizeFormatted = selectionSize.formatBytes()
                            updateDatabases()
                            let methodFinishDB2 = Date()
                            let timeElapsed3 = methodFinishDB2.timeIntervalSince(methodStartDB)
                            print("🥶🥶🥶UPDATE HEADER 2 - tempo: ", timeElapsed3)
                            updateHeader()
                            
                            categoryArray = categories
                            writeDeletableFilesToFile()
                        }
                        
                        let methodFinishDB3 = Date()
                        let timeElapsed4 = methodFinishDB3.timeIntervalSince(methodStartDB)
                        print("🥶🥶🥶UPDATE HEADER 1 - tempo: ", timeElapsed4)
                        updateHeader()
                    }
                }
            }
        }
    }
    
    func analyzeCategoryErasables(categoryIndex: Int) -> (Int64) {
        var totalSizeValue: Int64 = 0
        var subcategorySizeValue: Int64 = 0
        if (!categories[categoryIndex].paths.isEmpty || !categories[categoryIndex].subCategories.isEmpty) {
            for path in categories[categoryIndex].paths {
                do {
                    if (categories[categoryIndex].fileExtensions.isEmpty) {
                        if (categories[categoryIndex].fileNameContains.isEmpty) {
                            // No extension & no name keyword
                            let res = try x.allocatedSizeOfFiles(at: path, isRecursive: categories[categoryIndex].shouldAnalyzeSubfolders)
                            totalSizeValue += res.size
                            categories[categoryIndex].filesFound += res.filesFound
                        } else {
                            // No extension & has name keyword
                            let res = try x.allocatedSizeOfFiles(at: path, fileNameContains: categories[categoryIndex].fileNameContains, isRecursive: categories[categoryIndex].shouldAnalyzeSubfolders)
                            totalSizeValue += res.size
                            categories[categoryIndex].filesFound += res.filesFound
                        }
                        
                    } else {
                        if (categories[categoryIndex].fileNameContains.isEmpty) {
                            // has extension & no name keyword
                            let res = try x.allocatedSizeOfFiles(at: path, fileExtensions: categories[categoryIndex].fileExtensions, isRecursive: categories[categoryIndex].shouldAnalyzeSubfolders)
                            totalSizeValue += res.size
                            categories[categoryIndex].filesFound += res.filesFound
                        } else {
                            // has extension & has name keyword
                            let res = try x.allocatedSizeOfFiles(at: path, fileExtensions: categories[categoryIndex].fileExtensions, fileNameContains: categories[categoryIndex].fileNameContains, isRecursive: categories[categoryIndex].shouldAnalyzeSubfolders)
                            totalSizeValue += res.size
                            categories[categoryIndex].filesFound += res.filesFound
                        }
                    }
                } catch {
                    print("\(error.localizedDescription.description) Path:\(path)")
                    categories[categoryIndex].size.1 = "Nothing to delete"
                }
            }
            for subCategoryIndex in 0..<categories[categoryIndex].subCategories.count {
                //            concurrentQueue.async {
                subcategorySizeValue = 0
                for path in categories[categoryIndex].subCategories[subCategoryIndex].paths {
                    //                    concurrentQueue.async {
                    do {
                        if (categories[categoryIndex].subCategories[subCategoryIndex].fileExtensions.isEmpty) {
                            if (categories[categoryIndex].subCategories[subCategoryIndex].fileNameContains.isEmpty) {
                                // No extension & no name keyword
                                let res = try x.allocatedSizeOfFiles(at: path, isRecursive: categories[categoryIndex].subCategories[subCategoryIndex].shouldAnalyzeSubfolders)
                                subcategorySizeValue += res.size
                                categories[categoryIndex].subCategories[subCategoryIndex].filesFound += res.filesFound
                            } else {
                                // No extension & has name keyword
                                let res = try x.allocatedSizeOfFiles(at: path, fileNameContains: categories[categoryIndex].subCategories[subCategoryIndex].fileNameContains, isRecursive: categories[categoryIndex].subCategories[subCategoryIndex].shouldAnalyzeSubfolders)
                                subcategorySizeValue += res.size
                                categories[categoryIndex].subCategories[subCategoryIndex].filesFound += res.filesFound
                            }
                            
                        } else {
                            if (categories[categoryIndex].subCategories[subCategoryIndex].fileNameContains.isEmpty) {
                                // has extension & no name keyword
                                let res = try x.allocatedSizeOfFiles(at: path, fileExtensions: categories[categoryIndex].subCategories[subCategoryIndex].fileExtensions, isRecursive: categories[categoryIndex].subCategories[subCategoryIndex].shouldAnalyzeSubfolders)
                                subcategorySizeValue += res.size
                                categories[categoryIndex].subCategories[subCategoryIndex].filesFound += res.filesFound
                            } else {
                                // has extension & has name keyword
                                let res = try x.allocatedSizeOfFiles(
                                    at: path, fileExtensions: categories[categoryIndex].subCategories[subCategoryIndex].fileExtensions,
                                    fileNameContains: categories[categoryIndex].subCategories[subCategoryIndex].fileNameContains,
                                    isRecursive: categories[categoryIndex].subCategories[subCategoryIndex].shouldAnalyzeSubfolders)
                                subcategorySizeValue += res.size
                                categories[categoryIndex].subCategories[subCategoryIndex].filesFound += res.filesFound
                            }
                        }
                    } catch {
                        print("\(error.localizedDescription.description) Path:\(path)")
                        categories[categoryIndex].subCategories[subCategoryIndex].size.1 = "Nothing to delete"
                    }
                }
                totalSizeValue += subcategorySizeValue
                categories[categoryIndex].subCategories[subCategoryIndex].size = (subcategorySizeValue, subcategorySizeValue.formatBytes())
            }
            //            if totalSizeValue > 0 {
            //                let formattedSize = ByteCountFormatter.string(fromByteCount: totalSizeValue, countStyle: .memory)
            categories[categoryIndex].size = (totalSizeValue, totalSizeValue.formatBytes())
            //            }
            //            else {
            //                categories[categoryIndex].size = (totalSizeValue, "Nothing to delete")
            //            }
        } else {
            print("non fare niente per categoria \(categories[categoryIndex].name)")
        }
        return totalSizeValue
    }
    
    func updateDatabases() {
        //        totalDbReclaimableSpace = 0
        for app in appDbs.keys {
            if appDbs[app]!.totalShrinkableSize.bytes > 0 {
                //                    print("\(app) SPACEFREED = \(spaceFreed) \(spaceFreed.formatBytes())")
                totalDbReclaimableSpace += appDbs[app]!.totalShrinkableSize.bytes
            }
        }
        totalDbReclaimableSpaceFormatted = totalDbReclaimableSpace.formatBytes()
        
        for i in categories.indices {
            if (categories[i].name == "Databases") {
                categories[i].size.bytes = totalDbReclaimableSpace
                categories[i].size.formatted = totalDbReclaimableSpaceFormatted
            }
        }
        print("TOTALDBSPACEFREED = \(totalDbReclaimableSpace) \(totalDbReclaimableSpaceFormatted)")
        consoleManager.print("TOTALDBSPACEFREED = \(totalDbReclaimableSpace) \(totalDbReclaimableSpaceFormatted)")
    }
    
    func updateHeader() {
        //        size = ""
        let totalReclaimableSize = totalFilesReclaimableSize + totalCustomPathAppSpecificErasablesSize + totalPluginsSize + totalDbReclaimableSpace + totalAppsCache + totalAdditionalLanguagesSize + totalSystemGroupsSize
        //        value = totalReclaimableSize
        var prova: Int64 = 0
        for category in categories {
            prova += category.size.0
            //            print("adding " + ByteCountFormatter.string(fromByteCount: value, countStyle: .memory))
        }
        prova += totalDbReclaimableSpace
        //        consoleManager.print("TOTALE: \(prova) ---- totalReclaimableSize: \(totalReclaimableSize) ---- totalReclaimableSizeFormatted: \(totalReclaimableSize.formatBytes())")
        //        log.append("prova: \(prova) ---- totalReclaimableSize: \(totalReclaimableSize)")
        print("prova: \(prova) ---- totalReclaimableSize: \(totalReclaimableSize)")
        let formattedSize = ByteCountFormatter.string(fromByteCount: totalReclaimableSize, countStyle: .memory)
        let formattedSizeComponents = formattedSize.components(separatedBy: " ")
        if !formattedSizeComponents.isEmpty {
            print("VECCHIA SIZE: ", size)
            size = formattedSizeComponents.first!
            print("NUOVA SIZE: ", size)
            switch (formattedSizeComponents.last!) {
            case "b":
                sizeMeasure = "bit"
            case "B":
                sizeMeasure = "Byte"
            case "KB":
                sizeMeasure = "KyloByte"
            case "MB":
                sizeMeasure = "MegaByte"
            case "GB":
                sizeMeasure = "GigaByte"
            case "TB":
                sizeMeasure = "TeraByte"
            default:
                sizeMeasure = formattedSizeComponents.last!
            }
        }
    }
}

class frameWithID: Equatable {
    var value: (id: Int, frame: CGRect)
    init(_ value: (Int, CGRect)) {
        self.value = value
        //        self.id = value.0
        //        self.frame = value.1
    }
    
    
    static func == (lhs: frameWithID, rhs: frameWithID) -> Bool {
        return (lhs.value.0 == rhs.value.0) && (lhs.value.1 == rhs.value.1)
    }
}

struct FramePreference: PreferenceKey {
    static var defaultValue: [frameWithID] = []
    
    static func reduce(value: inout [frameWithID], nextValue: () -> [frameWithID]) {
        value.append(contentsOf: nextValue())
    }
}

struct Sticky: ViewModifier {
    @State var id: Int
    @Binding var shouldStick: Bool
    var stickyRects: [frameWithID]
    @State var frame: CGRect = .zero
    
    var isSticking: Bool {
        frame.minY < 0
    }
    
    var offset: CGFloat {
        guard isSticking && shouldStick else { return 0 }
        var o = -frame.minY
        if let idx = stickyRects.firstIndex(where: { $0.value.frame.minY > frame.minY && $0.value.frame.minY < frame.height }) {
            let other = stickyRects[idx]
            o -= frame.height - other.value.frame.minY
        }
        return o
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
        // Disables category animation if view is being dragged down with an offset, in order to prevent stuttering
//            .animation(nil, value: isSticking)
        //            .zIndex(isSticking ? .infinity : 0)
            .overlay(GeometryReader { proxy in
                let f = proxy.frame(in: .named("CategoriesScrollView"))
                Color.clear
                    .onAppear { frame = f }
                    .onChange(of: f) { frame = $0 }
                    .preference(key: FramePreference.self, value: [frameWithID((id, frame))])
            })
    }
}

extension View {
    func sticky(id: Int, shouldStick: Binding<Bool>, _ stickyRects: [frameWithID]) -> some View {
        modifier(Sticky(id: id, shouldStick: shouldStick, stickyRects: stickyRects))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(size: "", sizeMeasure: "")//, apps: .constant([:]))
    }
}
