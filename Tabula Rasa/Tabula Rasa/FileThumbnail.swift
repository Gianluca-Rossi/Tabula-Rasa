//
//  FileThumbnail.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 13/03/23.
//

import SwiftUI
import QuickLookThumbnailing

struct FileThumbnail: View {
    let url: URL
    let size: CGSize
    
    @State private var thumbnail: CGImage? = nil
    
    var body: some View {
        Group {
            if thumbnail != nil {
                Image(self.thumbnail!, scale: (UIScreen.main.scale), label: Text("PDF"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(3)
                    .frame(width: size.width, height: size.height)
            } else {
                Image(systemName: "folder") // << any placeholder
                    .onAppear(perform: generateThumbnail) // << here !!
            }
        }
    }
    
    func generateThumbnail() {
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared
        
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    //                        assert(false, "Thumbnail failed to generate")
                } else {
                    DispatchQueue.main.async { // << required !!
                        self.thumbnail = thumbnail!.cgImage  // here !!
                    }
                }
            }
        }
    }
}

struct FileThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        FileThumbnail(url: Bundle.main.url(forResource: "Entitlements", withExtension: ".plist") ?? URL(fileURLWithPath: ""), size: CGSize(width: 60, height: 60))
    }
}
