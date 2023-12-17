//
//  AppIcon.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 11/03/23.
//

import SwiftUI

//let missingAppIcon: some View {
//    if #available(iOS 15.0, *) {
//        return Image(systemName: "questionmark.app.dashed")
//            .symbolRenderingMode(.hierarchical)
//            .font(.system(size: 42))
//            .foregroundColor(.white)
//            .scaledToFit()
//            .frame(width: 38.0, height: 38.0)
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//    } else {
//        return Image("questionmark.app.dashed")
//            .resizable()
//            .scaledToFit()
//            .frame(width: 38.0, height: 38.0)
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//    }
//}

//var missingAppIcon = Image(systemName: "questionmark.app.dashed")
//            .symbolRenderingMode(.hierarchical)
//            .font(.system(size: 42))
//            .foregroundColor(.white)
//            .scaledToFit()
//            .frame(width: 38.0, height: 38.0)
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

struct AppIcon: View {
    @State var icon: UIImage?
    static var missingAppIcon: some View = Image("questionmark.app.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 38.0, height: 38.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    var body: some View {
        if (icon != nil) {
            Image(uiImage: (icon!))
                .resizable()
                .scaledToFit()
                .frame(width: 38.0, height: 38.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        } else {
            AppIcon.missingAppIcon
        }
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon()
    }
}
