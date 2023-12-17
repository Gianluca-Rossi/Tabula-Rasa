//
//  AddCustomFilesView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 18/03/23.
//

import SwiftUI

struct AddCustomFilesView: View {
    
    @State var url: URL = URL(fileURLWithPath: "")
    @State var pathComponents: [String] = []
//    @Binding var selection: Set<FileNavigatorItem>
    
    @State var selectedEntries = Set<FileNavigatorItem>()
    @State var viewsToDismiss = 0
    @State var shouldOpenFileNavigator = false
    
    @State var fileNameContains: [String] = ["",""]
    @State var fileNamePrefix: [String] = ["",""]
    @State var fileNameSuffix: [String] = ["",""]
    
    @State var numberOfContains = 1
    @State var numberOfPrefixes = 1
    @State var numberOfSuffixes = 1
    
    @State var deleteOption = 0
    @State var searchSubfolders = false
    
    @State var currentPath = rootURL
    
    @State var hasSelectedAtLeastAFolder = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !selectedEntries.isEmpty {
                List() {
                    //                ScrollView(.vertical) {
                    //                    VStack(alignment: .leading, spacing: 13) {
                    ForEach(Array(selectedEntries), id: \.self) { element in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 13) {
                                FileThumbnail(url: element.url, size: CGSize(width: 46, height: 46))
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(element.name)
                                        .font(.headline)
                                        .foregroundColor(Color.white)
                                        .truncationMode(.middle)
                                    Text(element.url.deletingLastPathComponent().path)
                                        .font(.system(size: 14, weight: .regular, design: .default))
                                        .foregroundColor(Color.secondary)
                                        .lineLimit(3)
                                        .truncationMode(Text.TruncationMode.head)
                                }
                                Spacer()
                            }
                        }
                        .padding(EdgeInsets(top: 13, leading: 26, bottom: 13, trailing: 26))
                        //                            .overlay(
                        //                                RoundedRectangle(cornerRadius: 26)
                        //                                    .strokeBorder(Color(UIColor(named: "CardBorder") ?? .white), lineWidth: 1)
                        //                            )
                        //                            .background(Blur(style: .systemChromeMaterial))
                        //                            .cornerRadius(26)
                    }
                    .onDelete(perform:{ indexSet in
                        print(indexSet)
                        for index in indexSet {
                            print(index)
                            selectedEntries.remove(
                                selectedEntries[selectedEntries.index(selectedEntries.startIndex, offsetBy: index)])
                        }
                    })
                    .listStyle(GroupedListStyle())
                    //                        .onAppear(perform: {
                    //                            UITableView.appearance().contentInset.top = -35
                    //                        })
                    //                    }
                }
                //                    .padding(0)
                //                    .padding(EdgeInsets(top: 26, leading: 26, bottom: 26, trailing: 26))
                //                    .frame(height: CGFloat(selectedEntries.count) * CGFloat(72))
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.size.height * 0.6)
                //                    .fixedSize(horizontal: false, vertical: true)
                //                .frame(minHeight: 300)
                //                .background(Color.gray)
                //                .cornerRadius(26)
            }
            Button(action: {
                shouldOpenFileNavigator = true
            }) {
                Text("Pick files")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black))
                    .foregroundColor(Color.white)
//                    .cornerRadius(12)
            }.sheet(isPresented: $shouldOpenFileNavigator,
                    onDismiss: nil) {
                ZStack(alignment: .top) {
                    NavigationView {
                        FileNavigatorView(currentPath: $currentPath, url: rootURL, selection: $selectedEntries, shouldShowView: $shouldOpenFileNavigator, viewsToDismiss: $viewsToDismiss)
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
                        //                            .navigationBarTitle(currentPath.lastPathComponent)
                    }
                    .navigationViewStyle(.stack)
                    .accentColor(Color(UIColor.tertiaryLabel))
                    Capsule()
                        .fill(Color(UIColor.tertiaryLabel))
                        .frame(width: 35, height: 5)
                        .padding(6)
                    //                        VStack(alignment: .leading, spacing: 0) {
                    //                            ScrollViewReader { value in
                    //                                ScrollView(.horizontal, showsIndicators: false) {
                    //                                    HStack {
                    //                                        ForEach(pathComponents.indices, id: \.self) { index in
                    //                                            Button(action: {
                    //                                                viewsToDismiss = (pathComponents.count - 1) - index
                    //                                                //                                for _ in 0...viewsToDismiss {
                    ////                                                self.presentationMode.wrappedValue.dismiss()
                    //                                                //                                }
                    //                                                //                                                                        shouldOpenFileNavigator = false
                    //                                            }) {
                    //                                                Text(pathComponents[index])
                    //                                                //                                                                            .font(.headline)
                    //                                                    .foregroundColor(Color.white)
                    //                                                    .padding(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                    //                                                    .overlay(
                    //                                                        RoundedRectangle(cornerRadius: 26)
                    //                                                            .strokeBorder(Color(UIColor(named: "CardBorder") ?? .white), lineWidth: 1)
                    //                                                    )
                    //                                                    .background(Blur(style: .systemChromeMaterial))
                    //                                                    .frame(maxWidth: UIScreen.main.bounds.size.width / 2)
                    //                                                    .truncationMode(.middle)
                    //                                                    .id(index)
                    //                                                if ((pathComponents.count - 1) != index) {
                    //                                                    Image(systemName: "arrowtriangle.right.fill")
                    //                                                        .resizable()
                    //                                                        .frame(width: 10, height: 10)
                    //                                                        .foregroundColor(Color(UIColor(named: "CardBorder") ?? .white))
                    //                                                        .padding(0).id(index)
                    //                                                    //                                                                .font(.system(size: 32, weight: .semibold))
                    //                                                } else {
                    //                                                    Spacer(minLength: 16)
                    //                                                }
                    //                                            }
                    //                                        }
                    //                                        .onAppear(perform: {
                    //                                            value.scrollTo((pathComponents.count - 1), anchor: UnitPoint.bottomTrailing)
                    //                                        })
                    //                                    }.padding(EdgeInsets(top: 26, leading: 16, bottom: 0, trailing: 0))
                    //                                }
                    //                                .onAppear(perform: {
                    //                                    print("pathc")
                    //                                    pathComponents = url.pathComponents
                    //                                    print(pathComponents)
                    //                                    if viewsToDismiss > 0 {
                    ////                                        self.presentationMode.wrappedValue.dismiss()
                    //                                    }
                    //                                })
                    //                                .onChange(of: currentPath, perform: { _ in
                    //                                    pathComponents = currentPath.pathComponents
                    //                                    value.scrollTo((pathComponents.count - 1), anchor: UnitPoint.bottomTrailing)
                    //                                })
                    //                                //                    .background(Color.clear)
                    //                            }
                    //                            Spacer()
                    //                        }
                    VStack {
                        Spacer()
                        Button(action: {
                            shouldOpenFileNavigator = false
                        }) {
                            //                            ZStack(alignment: .center){
                            //                                HStack(alignment: .center){
                            //                                    VStack(alignment: .center){
                            Text(selectedEntries.count == 0 ? "Select some files to delete" : "Select \(selectedEntries.count) elements")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            //                                            .padding(EdgeInsets(top: selectedEntries.count == 0 ? 0 : 16, leading: 0, bottom: 0, trailing: 0))
                            //                                                                .onChange(of: selectionSize, perform: { _ in
                            //                                                                    print("selection size cambiata")
                            //                                                                    selectionSizeFormatted = selectionSize.formatBytes()
                            //                                                                })
                            //                                    }
                            //                                }
                            //                            }
                                .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                .background(selectedEntries.count == 0 ? RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "EraseButtonDisabled") ?? .gray)) : RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(UIColor(named: "EraseButtonActive") ?? .blue)))
//                                .cornerRadius(26)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                                )
                                .shadow(color: selectedEntries.count == 0 ? Color.gray.opacity(0.17) : Color.blue.opacity(0.17), radius: 4, y: 2)
                                .animation(.easeInOut)
                        }
                        .disabled(selectedEntries.count == 0 ? true : false)
                    }
                    .frame(alignment: .bottom)
                    .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
                }
            }
            if hasSelectedAtLeastAFolder {
                Text("For each folder delete:")
                Picker("What is your favorite color?", selection: $deleteOption) {
                    Text("Whole folder").tag(0)
                    Text("Files only, keep the subfolders").tag(1)
                    Text("Files and Subfolders, keeping the containing subfolders").tag(2)
                }
                .pickerStyle(.segmented)
                
                if deleteOption != 0 {
                    Toggle(isOn: $searchSubfolders, label: {
                        Text("Search in subfolders")
                    })
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("File or directory name starts with")
                            .font(.callout)
                            .bold()
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        ForEach(0..<numberOfPrefixes, id:\.self) { id in
                            TextField(
                                "log_",
                                text: $fileNamePrefix[id],
                                onCommit: {
                                    fileNamePrefix[id] = fileNamePrefix[id].removingLeadingSpacesAndNewlines()
                                    if !(fileNamePrefix[id] == "") {
                                        fileNamePrefix.append("")
                                        numberOfPrefixes += 1
                                    } else if numberOfPrefixes > 1 {
                                        numberOfPrefixes -= 1
                                        fileNamePrefix.remove(at: id)
                                    }
                                }
                            )
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        }
                        Text("This can be used to include only the elements that have one of the specified terms among their path, name or extension")
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 26, trailing: 0))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("File path contains")
                            .font(.callout)
                            .bold()
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        ForEach(0..<numberOfContains, id:\.self) { id in
                            TextField(
                                "folder/file.txt",
                                text: $fileNameContains[id],
                                onCommit: {
                                    if !(fileNameContains[id] == "") {
                                        fileNameContains.append("")
                                        numberOfContains += 1
                                    } else if numberOfContains > 1 {
                                        numberOfContains -= 1
                                        fileNameContains.remove(at: id)
                                    }
                                }
                            )
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 26, trailing: 0))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("File or directory name ends with")
                            .font(.callout)
                            .bold()
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        ForEach(0..<numberOfSuffixes, id:\.self) { id in
                            TextField(
                                ".jpg",
                                text: $fileNameSuffix[id],
                                onCommit: {
                                    fileNameSuffix[id] = fileNameSuffix[id].trimmingTrailingSpaces()
                                    if !(fileNameSuffix[id] == "") {
                                        fileNameSuffix.append("")
                                        numberOfSuffixes += 1
                                    } else if numberOfSuffixes > 1 {
                                        numberOfSuffixes -= 1
                                        fileNameSuffix.remove(at: id)
                                    }
                                }
                            )
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 26, trailing: 0))
                }
            }
            Spacer()
                .onChange(of: selectedEntries, perform: { _ in
                if selectedEntries.contains(where: { element in element.isDirectory }) {
                    hasSelectedAtLeastAFolder = true
                } else {
                    hasSelectedAtLeastAFolder = false
                }
            })
            }
    }
}

struct AddCustomFilesView_InteractivePreview: View {
//    @State var selection: Set<FileNavigatorItem> = [FileNavigatorItem(name: "ao", url: URL(fileURLWithPath: "/aoooo/m"), isChecked: true, isDirectory: true)]
    var body: some View {
//        AddCustomFilesView(selection: $selection)
        AddCustomFilesView()
    }
}

struct AddCustomFilesView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomFilesView_InteractivePreview()
    }
}

