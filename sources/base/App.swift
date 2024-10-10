//
//  Brickie.swift
//  Brickie
//
//  Created by Work on 03/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import Combine
let kCollection = Store.singleton
var kConfig = Configuration()

@main
struct TheApp : App {
    
    @State private var model = Model()
    @EnvironmentObject private var  store : Store


    @AppStorage(Settings.displayWelcome)  var displayWelcome : Bool = true
    @AppStorage(Settings.rootTabSelected)  var selection : Int = 0
    @AppStorage(Settings.reviewRuntime) var reviewRuntime : Int = 0
    @AppStorage(Settings.reviewVersion) var reviewVersion : String?
    @AppStorage(Settings.rootSideSelected)  var sideSelection : Int?
    @State var isPresentingSettings = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @AppStorage(Settings.appVersion2) private var appVersion2: Bool = true



    func toolbar() -> Button<Image> {
        Button(action: {
            self.isPresentingSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
    }
    var body : some Scene {
        WindowGroup{
            
            if model.keychain.user == nil  {
                LoginView().accentColor(.backgroundAlt)
                    .sheet(isPresented: $displayWelcome) {
                        WelcomeView(showContinu: true)
                    }
                    .environment(model)
            } else   {
                    TabView(selection: $selection){
                        ForEach(AppPanel.allCases, id: \.self) { item in
                            SinglePanelView(item: item, view: item.view, toolbar: toolbar() )
                        }
                    }
                    .environment(model)
                    .modelContainer(model.datamanager.modelContainer)

                    .accentColor(.backgroundAlt)
                        .sheet(isPresented: $isPresentingSettings) {
                            SettingsView().environmentObject(store)
                        }
                        .sheet(isPresented: $displayWelcome) {
                            WelcomeView(showContinu: true)
                        }
                
     
            }
            
            
//            AppRootView()
               
//                .environmentObject(kCollection)
        }
    }


    
    
}

let currencyFormatter : NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    switch Locale(identifier: Locale.currentRegionCode).identifier {
    case "ca":
        f.currencyCode = "CAD"
        break
    case "us":
        f.currencyCode = "USD"
        break
    case "gb":
        f.currencyCode = "GBP"
        break
    default:
        f.currencyCode = "EUR"
    }
    return f
}()
