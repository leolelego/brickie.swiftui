//
//  Brickie.swift
//  Brickie
//
//  Created by Work on 03/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI

@main
struct TheApp : App {
    
    @AppStorage(Settings.displayWelcome)  var displayWelcome : Bool = true
    /*@AppStorage(Settings.rootTabSelected) */@State var selection : Int = 0
    @State private var model = Model()
    @EnvironmentObject private var  store : Store
    
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
                        SinglePanelView(item: item, view: item.view)
                    }
                }
                .environment(model)
                .modelContainer(model.datamanager.modelContainer)
                .accentColor(.backgroundAlt)
                
                .sheet(isPresented: $displayWelcome) {
                    WelcomeView(showContinu: true)
                }
            }
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
