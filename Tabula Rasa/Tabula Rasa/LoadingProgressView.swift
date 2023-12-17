//
//  LoadingProgressView.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 05/03/23.
//

import SwiftUI

struct LoadingProgressView: View {
    @State var isScanning = false
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [.black, .black, .white]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                    lineWidth: 2
                )
                .rotationEffect(.degrees(isScanning ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: false))
                .frame(width: 200, height: 200)
                .onAppear(perform: {isScanning = true})
                .animation(nil)
            Circle()
                .strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [.black, .black, .white]), center: .center, startAngle: .zero, endAngle: .degrees(260)),
                    lineWidth: 2
                )
                .rotationEffect(.degrees(isScanning ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: false))
                .frame(width: 300, height: 300)
                .onAppear(perform: {isScanning = true})
                .animation(nil)
            Circle()
                .strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [.black, .black, .white]), center: .center, startAngle: .zero, endAngle: .degrees(160)),
                    lineWidth: 2
                )
                .rotationEffect(.degrees(isScanning ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: false))
                .frame(width: 400, height: 400)
                .onAppear(perform: {isScanning = true})
                .animation(nil)
        }.frame(width: 0, height: 0)
        .zIndex(-1)
        .animation(nil)
    }
}

struct LoadingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingProgressView()
    }
}
