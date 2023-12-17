//
//  FileNavigatorView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 13/03/23.
//

import SwiftUI
import QuickLook

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    
    init(content: Content, preview: Preview, menu: UIMenu, navigate: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.menu = menu
        self.navigate = navigate
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(_ parent: ContextMenuHelper) {
            self.parent = parent
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                let previewController = UIHostingController(rootView: self.parent.preview)
                return previewController
            } actionProvider: { items in
                return self.parent.menu
            }
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            parent.navigate()
        }
    }
}

extension View {
    func contextMenu<Preview: View>(navigate: @escaping () -> Void = {}, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) -> some View {
        return CustomContextMenu(navigate: navigate, content: {self}, preview: preview, menu: menu)
    }
}

struct CustomContextMenu<Content: View, Preview: View>: View {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    init(navigate: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
        self.navigate = navigate
    }
    var body: some View {
        ZStack {
            content
                .overlay(ContextMenuHelper(content: content, preview: preview, menu: menu, navigate: navigate))
        }
    }
}

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}


struct FileNavigatorView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let fn = FileNavigator()
    let thumbnailSize: CGSize = CGSize(width: 54, height: 54)
    @State var folderContent: [FileNavigatorItem] = []
    @Binding var currentPath: URL
    @State var url: URL = URL(fileURLWithPath: "")
    @State var pathComponents: [String] = []
    @Binding var selection: Set<FileNavigatorItem>
    @Binding var shouldShowView: Bool
    @Binding var viewsToDismiss: Int
    @State private var quicklookURL: URL? = nil
    @State private var quicklookURLs: [URL] = []
    var body: some View {
        
                ScrollView {
                    ForEach(folderContent.indices, id: \.self) { index in
                        HStack(spacing: 0) {
                            Toggle(isOn: toggleValue(for: index)) {
                            }
                            .disabled(true)
                            .toggleStyle(CheckboxStyle())
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 26))
                            .frame(maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                if selection.contains(folderContent[index]) {
                                    selection.remove(folderContent[index])
                                } else {
                                    selection.insert(folderContent[index])
                                }
                            })
                            
                            //                        Button(action: {
                            //
                            //                        }) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    
                                    if !folderContent[index].isDirectory {
                                        
                                        FileThumbnail(url: folderContent[index].url, size: thumbnailSize)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .quickLookPreview($quicklookURL, in: quicklookURLs)
                                            .onTapGesture(perform: {
                                                quicklookURL = folderContent[index].url
                                                // porcata temporanea
                                                //                                            if selection.contains(folderContent[index].url) {
                                                //                                                selection.remove(folderContent[index].url)
                                                //                                            } else {
                                                //                                                selection.insert(folderContent[index].url)
                                                //                                            }
                                            })
                                        
                                        Button(action: {
                                            //                                url = fn.getFolderContent(url: entry.url)
                                            if selection.contains(folderContent[index]) {
                                                selection.remove(folderContent[index])
                                            } else {
                                                selection.insert(folderContent[index])
                                            }
                                        }) {
                                            HStack{
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text(folderContent[index].name)
                                                        .font(.system(size: 19, weight: .regular))
                                                        .foregroundColor(.white)
                                                        .padding(EdgeInsets(top: 13, leading: 0, bottom: 0, trailing: 26))
                                                    Text(folderContent[index].edited)
                                                        .font(.system(size: 14, weight: .regular))
                                                        .foregroundColor(.secondary)
                                                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 13, trailing: 26))
                                                    Spacer()
                                                }
                                                .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                                Spacer()
                                            }
                                            .contentShape(Rectangle())
                                            
                                            if (!(folderContent.count - 1 == index)) {
                                                Divider()
                                                    .offset(x:13)
                                            }
                                        }
                                        //                                        .onTapGesture(count: 1, perform: {
                                        //                                            //                        if quicklookURL == nil {
                                        //                                            if selection.contains(folderContent[index].url) {
                                        //                                                selection.remove(folderContent[index].url)
                                        //                                            } else {
                                        //                                                selection.insert(folderContent[index].url)
                                        //                                            }
                                        //                                            //                        }
                                        //                                        })
                                    } else {
                                        NavigationLink(destination: FileNavigatorView(currentPath: $currentPath, url: folderContent[index].url, selection: $selection, shouldShowView: $shouldShowView, viewsToDismiss: $viewsToDismiss)) {
                                            VStack(alignment: .leading) {
                                                HStack(spacing: 0) {
                                                    Image("folder")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        Text(folderContent[index].name)
                                                            .multilineTextAlignment(.leading)
                                                            .font(.system(size: 19, weight: .regular))
                                                            .foregroundColor(.white)
                                                            .padding(EdgeInsets(top: 13, leading: 0, bottom: 0, trailing: 26))
                                                        Text(folderContent[index].edited)
                                                            .font(.system(size: 14, weight: .regular))
                                                            .foregroundColor(.secondary)
                                                            .padding(EdgeInsets(top: 2, leading: 0, bottom: 13, trailing: 26))
                                                    }
                                                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                                                        .font(.system(size: 14, weight: .regular))
                                                    //                                                    .offset(x: 32)
                                                        .foregroundColor(Color(UIColor.systemGray3))
                                                    //iOS 16
                                                    //                                                    .font(.system(size: 14, weight: .semibold))
                                                    //                                                   .foregroundColor(Color(UIColor.secondarySystemBackground))
                                                }
                                                .contentShape(Rectangle())
                                                
                                                if folderContent[index].isAlreadyAdded {
                                                    Text("Will already be deleted by")
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .padding(EdgeInsets(top: 6, leading: 13, bottom: 6, trailing: 13))
                                                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.blue))
//                                                        .cornerRadius(6)
                                                }
                                                if (!(folderContent.count - 1 == index)) {
                                                    Divider()
                                                        .offset(x:13 + thumbnailSize.width)
                                                }
                                            }
                                            
                                        }
//                                        .toolbar {
//                                            ToolbarItem(placement: .navigationBarTrailing) {
//                                                Button(action: {
//                                                    self.presentationMode.wrappedValue.dismiss()
//                                                }, label: {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .resizable()
//                                                        .frame(width: 32, height: 32)
//                                                        .font(.system(size: 32, weight: .semibold))
//                                                        .background(Blur(style: .systemChromeMaterial))
//                                                })
//                                            }
//                                        }
                                    }
                                    
                                    
                                    
                                }
                            }
                            //                            .buttonStyle(ListRowStyle())
                            .if(!folderContent[index].isDirectory) { view in
                                view
                                    .background(Color(UIColor.systemBackground))
                                    .contextMenu(navigate: {
                                        //                                    UIApplication.shared.open(url) //User tapped the preview
                                    }) {
                                        GeometryReader { geometry in
                                            FileThumbnail(url: folderContent[index].url, size: CGSize(width: geometry.size.width, height: geometry.size.height))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    }menu: {
                                        let openUrl = UIAction(title: "Open", image: UIImage(systemName: "sidebar.left")) { _ in
                                            withAnimation() {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                        let menu = UIMenu(title: url.absoluteString, image: nil, identifier: nil, options: .displayInline, children: [openUrl]) //Menu
                                        return menu
                                    }
                                    .buttonStyle(ListRowStyle())
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                            //                            .buttonStyle(ListRowStyle())
                            
                            //                        }
                            
                        }
                        
                    }
                }
                .navigationBarTitle(url.lastPathComponent)
//                .frame(alignment: .bottom)
//            }
            //        .navigationBarBackButtonHidden(true)
            .onAppear(perform: {
                concurrentQueue.async {
                    currentPath = url
                    //            folderContent = fn.getRootContent()
                    folderContent = fn.getFolderContent(url: url)
                    for item in folderContent {
                        if !item.isDirectory {
                            quicklookURLs.append(item.url)
                        }
                    }
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
//                        self.presentationMode.wrappedValue.dismiss()
                        selection = Set<FileNavigatorItem>()
                        shouldShowView = false
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
    
    private func toggleValue(for index: Int) -> Binding<Bool> {
        return .init(
            get: {selection.contains(folderContent[index])},
            set: {
                if $0 == true {
                    selection.insert(folderContent[index])
                } else {
                    selection.remove(folderContent[index])
                }
            })
    }
}

struct ListRowStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
//            .background(configuration.isPressed ? Color(UIColor.systemGray4) : Color(UIColor.secondarySystemBackground))
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct FileNavigatorView_InteractivePreview: View {
    @State var x = Set<FileNavigatorItem>()
    var body: some View {
        NavigationView {
            FileNavigatorView(currentPath: .constant(rootURL), url: Bundle.main.bundleURL,  selection: $x, shouldShowView: .constant(true), viewsToDismiss: .constant(0))
//                .toolbar {
//                    ToolbarItem(placement: .navigation) {
//                        VStack(alignment: .leading) {
//                            Text("Select files")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                            Text("/")
//                                .font(.headline)
//                        }
//                    }
//                }
        }
    }
}

struct FileNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        FileNavigatorView_InteractivePreview()
    }
}
