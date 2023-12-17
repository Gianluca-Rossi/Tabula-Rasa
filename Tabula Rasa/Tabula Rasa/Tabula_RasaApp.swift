//
//  Tabula_RasaApp.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 30/12/22.
//

import SwiftUI
import OrderedCollections



@main
struct Tabula_RasaApp: App {
    init() {
        // Set uid and gid  SE LO METTO COSI PRESTO NON CARICA IN TEMPO LA LINGUA USATA, LE NOTAZIONI DELLA REGIONE IMPOSTATA(LA VIRGOLA NEI NUMERI)
//        if (!(setuid(0) == 0 && setgid(0) == 0)) {
//            print("NIENTE ROOT")
////            exit(EXIT_FAILURE);
//        }
    }
//    @State var apps: OrderedDictionary<String, AppInfo> = [:]// = appList
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationBarTitle("")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
