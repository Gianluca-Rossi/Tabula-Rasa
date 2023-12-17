//
//  CheckboxStyle.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 31/12/22.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            if #available(iOS 15.0, *) {
//                Image(systemName: "circle.inset.filled")
//                    .symbolRenderingMode(.palette)
//                    .font(.system(size: 42))
//                    .foregroundColor(.white)
//                    .scaledToFit()
//                    .frame(width: 38.0, height: 38.0)
//                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                if configuration.isOn {
                    Image("circle.inset.filled")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .font(.system(size: 32, weight: .semibold))
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(UIColor(named: "ToggleEnabled") ?? .gray))
                        .font(.system(size: 32, weight: .semibold))
                }
            } else {
                //                Image("questionmark.app.dashed")
                //                    .resizable()
                //                    .scaledToFit()
                //                    .frame(width: 38.0, height: 38.0)
                //                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //            }
                if configuration.isOn {
                    Image("circle.inset.filled")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .font(.system(size: 32, weight: .semibold))
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(UIColor(named: "ToggleEnabled") ?? .gray))
                        .font(.system(size: 32, weight: .semibold))
                }
            }
        }
        .onTapGesture { configuration.isOn.toggle() }

    }
}
