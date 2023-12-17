//
//  SubCategoryRow.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 13/01/23.
//

import SwiftUI
import OrderedCollections

struct SubCategoryRow: View {
    var bundleID: String
    @Binding var shouldShow: Bool// = apps[bundleID]?.isSubMenuOpen
    @Binding var apps: OrderedDictionary<String, AppInfo>
    @Binding var appSpecificErasables: [appSpecificErasable]
    @Binding var appErasables: OrderedDictionary<erasableType, erasableData>
    
    @Binding var appPlugins: OrderedDictionary<pluginType, erasableData>
    @Binding var isAppSelected: Bool
    
    var body: some View {
        
        if shouldShow {
            VStack(alignment: .leading) {
                //                if !appSpecificErasables.isEmpty {
                //                    Text("App Specific")
                //                        .font(.system(size: 18, weight: .bold))
                //                        .foregroundColor(.white)
                //                        .lineLimit(1)
                //                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                //                    List(appSpecificErasables) { specificErasable in
                //                        //NOT WORKing il foreach funziona pero
                //                        VStack(alignment: .leading) {
                //                                Text(specificErasable.erasableName)
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            if ((1...1023).contains(specificErasable.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
                //                                Text("\(specificErasable.bytes) Byte")
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            } else {
                //                                Text(specificErasable.formatted)
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            }
                //                                Text(specificErasable.description)
                //                                    .font(.system(size: 16, weight: .thin))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            }
                //                    }
                //                    .frame(height: 200)
                //
                //                    if !(apps[bundleID]!.erasables.keys.isEmpty) {
                //                        Text("Erasable Files")
                //                            .font(.system(size: 18, weight: .bold))
                //                            .foregroundColor(.white)
                //                            .lineLimit(1)
                //                            .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                //                        List(apps[bundleID]!.erasables.keys, id:\.self) { erasable in
                //                            //NOT WORKing il foreach funziona pero
                //                            VStack(alignment: .leading) {
                //
                //                                Text(erasable.rawValue)
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                if ((1...1023).contains(apps[bundleID]!.erasables[erasable]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
                //                                    Text("\(apps[bundleID]!.erasables[erasable]!.bytes) Byte")
                //                                        .font(.system(size: 16, weight: .bold))
                //                                        .foregroundColor(.white)
                //                                        .lineLimit(1)
                //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                } else {
                //                                    Text(apps[bundleID]!.erasables[erasable]!.formatted)
                //                                        .font(.system(size: 16, weight: .bold))
                //                                        .foregroundColor(.white)
                //                                        .lineLimit(1)
                //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                }
                //                                Text(erasableTypeDescription[erasable] ?? "")
                //                                    .font(.system(size: 16, weight: .thin))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            }
                //                        }
                //                        .frame(height: 200)
                //                    }
                //                    if !(apps[bundleID]!.plugins.keys.isEmpty) {
                //                        Text("App Plugins")
                //                            .font(.system(size: 18, weight: .bold))
                //                            .foregroundColor(.white)
                //                            .lineLimit(1)
                //                            .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                //                        List(apps[bundleID]!.plugins.keys, id:\.self) { plugin in
                //                            //NOT WORKing il foreach funziona pero
                //                            VStack(alignment: .leading) {
                //                                Text(plugin.rawValue)
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                if ((1...1023).contains(apps[bundleID]!.plugins[plugin]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
                //                                    Text("\(apps[bundleID]!.plugins[plugin]!.bytes) Byte")
                //                                        .font(.system(size: 16, weight: .bold))
                //                                        .foregroundColor(.white)
                //                                        .lineLimit(1)
                //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                } else {
                //                                    Text(apps[bundleID]!.plugins[plugin]!.formatted)
                //                                        .font(.system(size: 16, weight: .bold))
                //                                        .foregroundColor(.white)
                //                                        .lineLimit(1)
                //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                }
                //                                Text(pluginTypeDescription[plugin] ?? "")
                //                                    .font(.system(size: 16, weight: .thin))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                            }
                //                        }
                //                        .frame(height: 200)
                //                    }
                
                if !appSpecificErasables.isEmpty {
                    Text("App Specific")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                    ForEach(appSpecificErasables.indices, id: \.self) { index in
                        HStack {
                            Toggle(isOn: bindingAppSpecificErasable(for: index).isChecked) {
                            }
                            .toggleStyle(CheckboxStyle())
                            .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                            VStack(alignment: .leading) {
//                                if ((1...1023).contains(appSpecificErasables[index].bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//
//                                    Text(appSpecificErasables[index].erasableName)
//                                        .font(.system(size: 16, weight: .bold))
//                                        .foregroundColor(.white)
//                                        .lineLimit(1)
//                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                    Text(appSpecificErasables[index].bytes.formatBytes())
//                                        .font(.system(size: 16, weight: .bold))
//                                        .foregroundColor(.white)
//                                        .lineLimit(1)
//                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                    Text(appSpecificErasables[index].description)
//                                        .font(.system(size: 16, weight: .thin))
//                                        .foregroundColor(.white)
//                                        .lineLimit(1)
//                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                } else
                                if (appSpecificErasables[index].bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                                    Text(appSpecificErasables[index].erasableName)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                                    Text(appSpecificErasables[index].formatted)
                                    Text(appSpecificErasables[index].description)
                                }
                            }
                        }
                    }
                }
                Text("Erasables")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                ForEach(apps[bundleID]!.erasables.keys, id: \.self) { erasable in
                    HStack {
                        Toggle(isOn: bindingErasable(for: erasable).isChecked) {
                        }
                        .toggleStyle(CheckboxStyle())
                        .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                        VStack(alignment: .leading) {
                            Text("\(erasable.rawValue)")
//                            if ((1...1023).contains(apps[bundleID]!.erasables[erasable]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                Text("\(apps[bundleID]!.erasables[erasable]!.bytes) Byte")
//                            } else
                            if (apps[bundleID]!.erasables[erasable]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                                Text("\(apps[bundleID]!.erasables[erasable]!.formatted)")
                            }
                            Text(erasableTypeDescription[erasable]!)
                        }
                    }
                }
                .animation(nil) // Prevents the list items from sliding in from the top
                //                                if !apps[bundleID]!.plugins.isEmpty {
                //                                    Text("Plugins")
                //                                    ForEach(apps[bundleID]!.plugins.keys, id: \.self) { plugin in              HStack {
                //                                                        Toggle(isOn: bindingPlugin(for: plugin).isChecked) {
                //                                                        }
                //                                                        .toggleStyle(CheckboxStyle())
                //                                                        .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                //                                        VStack {
                //                                            if ((1...1023).contains(apps[bundleID]!.plugins[plugin]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
                //                                                Text("\(plugin.rawValue)")
                //                                                Text("\(apps[bundleID]!.plugins[plugin]!.bytes) Byte")
                //                                                Text(pluginTypeDescription[plugin]!)
                //                                            } else if (apps[bundleID]!.plugins[plugin]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                //                                                Text("\(plugin.rawValue)")
                //                                                Text("\(apps[bundleID]!.plugins[plugin]!.formatted)")
                //                                                Text(pluginTypeDescription[plugin]!)
                //                                            }
                //                                        }
                //                                    }
                //                                    }
                //                                }
                
                
                
                
                
                
                
                //                ForEach(appErasables.keys, id: \.self) { erasable in
                //                    HStack {
                //                                            Toggle(isOn: $erasables[erasable].isChecked) {
                //                                            }
                //                                            .toggleStyle(CheckboxStyle())
                //                                            .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                //                        VStack(alignment: .leading) {
                //                            if ((1...1023).contains(appErasables[erasable]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
                //                                Text("\(erasable.rawValue)")
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                //                                Text("\(appErasables[erasable]!.bytes) Byte")
                //                                Text(erasableTypeDescription[erasable]!)
                //                            } else if (appErasables[erasable]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                //                                Text("\(erasable.rawValue)")
                //                                    .font(.system(size: 16, weight: .bold))
                //                                    .foregroundColor(.white)
                //                                    .lineLimit(1)
                //                                    .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                //                                Text("\(appErasables[erasable]!.formatted)")
                //                                Text(erasableTypeDescription[erasable]!)
                //                            }
                //                        }
                //                    }
                //                }
                if !appPlugins.isEmpty {
                    Text("Plugins")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
                    ForEach(appPlugins.keys, id: \.self) { plugin in
                        HStack {
                            Toggle(isOn: bindingPlugin(for: plugin).isChecked) {
                            }
                            .toggleStyle(CheckboxStyle())
                            .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                            VStack(alignment: .leading) {
                                Text("\(plugin.rawValue)")
//                                if ((1...1023).contains(appPlugins[plugin]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                    Text("\(appPlugins[plugin]!.bytes) Byte")
//                                } else
                                if (appPlugins[plugin]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
                                    Text("\(appPlugins[plugin]!.formatted)")
                                }
                                Text(pluginTypeDescription[plugin]!)
                            }
                        }
                    }
                }
            }.background(Color.clear)
                .frame(maxHeight: .infinity)
        }
    }
    private func bindingErasable(for key: erasableType) -> Binding<erasableData> {
        return .init(
            get: { self.apps[bundleID]?.erasables[key] ?? erasableData(bytes: 0) },
            set: { self.apps[bundleID]?.erasables[key]  = $0
                appBundleList[bundleID]?.erasables[key] = $0 })
    }
    private func bindingAppSpecificErasable(for index: Int) -> Binding<appSpecificErasable> {
        return .init(
            get: { self.apps[bundleID]?.appSpecificErasables[index] ?? appSpecificErasable() },
            set: { self.apps[bundleID]?.appSpecificErasables[index] = $0
                appBundleList[bundleID]?.appSpecificErasables[index] = $0 })
    }
    private func bindingPlugin(for key: pluginType) -> Binding<erasableData> {
        return .init(
            get: { self.apps[bundleID]?.plugins[key] ?? erasableData(bytes: 0) },
            set: { self.apps[bundleID]?.plugins[key] = $0
                appBundleList[bundleID]?.plugins[key] = $0 })
    }
}

struct SubCategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        let p: OrderedDictionary<pluginType, erasableData> = [.Today : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false)]
        let e: OrderedDictionary<erasableType, erasableData> = [.Cache : erasableData(bytes: 5000, formatted: "50 MB", filesFound: [], isChecked: false)]
        let s: [appSpecificErasable] = [
            appSpecificErasable(appPath: appPath.ContDataApp, subPaths: ["/Documents/AVFSStorage"],
                                fileNameContains: [], fileExtensions: [], erasableName: "Prova", description: "BlablaBla", bytes: 100, formatted: "100 MB", isChecked: false)
        ]
        let mockedApps: OrderedDictionary<String, AppInfo> = [
            "Tabula Rasa":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000),
            "Tabula Rasa2":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000)
        ]
        
        SubCategoryRow(bundleID: "Tabula Rasa", shouldShow: .constant(true), apps: .constant(mockedApps), appSpecificErasables: .constant(s), appErasables: .constant(e), appPlugins: .constant(p), isAppSelected: .constant(true))
    }
}

//
//
////
////  SubCategoryRow.swift
////  Tabula Rasa
////
////  Created by Gianluca Rossi on 13/01/23.
////
//
//import SwiftUI
//import OrderedCollections
//
//struct SubCategoryRow: View {
//    var bundleID: String
//    @Binding var shouldShow: Bool// = apps[bundleID]?.isSubMenuOpen
//    @Binding var apps: OrderedDictionary<String, AppInfo>
//    var body: some View {
//
//        if shouldShow {
//            VStack(alignment: .leading) {
//                if apps[bundleID]!.appSpecificErasables.isEmpty {
//                    Text("App Specific")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 8, trailing: 0))
//                    ForEach(apps[bundleID]!.appSpecificErasables.indices, id: \.self) { index in
//                            HStack {
//                                //                    Toggle(isOn: $apps[bundleID]!.erasables[erasable].isChecked) {
//                                //                    }
//                                //                    .toggleStyle(CheckboxStyle())
//                                //                    .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
//                                VStack {
//                                    if ((1...1023).contains(apps[bundleID]!.appSpecificErasables[index].bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                        Text(apps[bundleID]!.appSpecificErasables[index].erasableName)
//                                        Text("\(apps[bundleID]!.appSpecificErasables[index].bytes) Byte")
//                                        Text(apps[bundleID]!.appSpecificErasables[index].description)
//                                    } else if (apps[bundleID]!.appSpecificErasables[index].bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
//                                        Text(apps[bundleID]!.appSpecificErasables[index].erasableName)
//                                        Text(apps[bundleID]!.appSpecificErasables[index].formatted)
//                                        Text(apps[bundleID]!.appSpecificErasables[index].description)
//                                    }
//                                }
//                            }
//                    }
//                }
//                ForEach(apps[bundleID]!.erasables.keys, id: \.self) { erasable in
//                    HStack {
//                        //                    Toggle(isOn: $apps[bundleID]!.erasables[erasable].isChecked) {
//                        //                    }
//                        //                    .toggleStyle(CheckboxStyle())
//                        //                    .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
//                        VStack {
//                            if ((1...1023).contains(apps[bundleID]!.erasables[erasable]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                Text("\(erasable.rawValue)")
//                                Text("\(apps[bundleID]!.erasables[erasable]!.bytes) Byte")
//                                Text(erasableTypeDescription[erasable]!)
//                            } else if (apps[bundleID]!.erasables[erasable]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
//                                Text("\(erasable.rawValue)")
//                                Text("\(apps[bundleID]!.erasables[erasable]!.formatted)")
//                                Text(erasableTypeDescription[erasable]!)
//                            }
//                        }
//                    }
//                }
//                if !apps[bundleID]!.plugins.isEmpty {
//                    Text("Plugins")
//                    ForEach(apps[bundleID]!.plugins.keys, id: \.self) { plugin in              HStack {
//                        //                Toggle(isOn: $apps[bundleID]!.plugins[plugin].isChecked) {
//                        //                }
//                        //                .toggleStyle(CheckboxStyle())
//                        //                .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
//                        VStack {
//                            if ((1...1023).contains(apps[bundleID]!.plugins[plugin]!.bytes)) { // If the found files sum up from 1 to 1023 bytes, show their size as bytes
//                                Text("\(plugin.rawValue)")
//                                Text("\(apps[bundleID]!.plugins[plugin]!.bytes) Byte")
//                                Text(pluginTypeDescription[plugin]!)
//                            } else if (apps[bundleID]!.plugins[plugin]!.bytes != 0) { // If the found files sum up to 0 bytes, don't show their erasable category
//                                Text("\(plugin.rawValue)")
//                                Text("\(apps[bundleID]!.plugins[plugin]!.formatted)")
//                                Text(pluginTypeDescription[plugin]!)
//                            }
//                        }
//                    }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct SubCategoryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        var p: OrderedDictionary<pluginType, (bytes: Int64, formatted: String,  isChecked: Bool)> = [.Today:(5000, "50 MB", false)]
//        var e: OrderedDictionary<erasableType, (bytes: Int64, formatted: String, isChecked: Bool)> = [.Cache:(50000, "91 MB", false)]
//        var mockedApps: OrderedDictionary<String, AppInfo> = [
//            "Tabula Rasa":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000),
//            "Tabula Rasa2":AppInfo(icon: nil, plugins: p, erasables: e, size: 10000)
//        ]
//
//        SubCategoryRow(bundleID: "Tabula Rasa", shouldShow: .constant(true), apps: .constant(mockedApps))
//    }
//}
