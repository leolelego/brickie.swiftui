//
//  SinglePanelView.swift
//  Brickie
//
//  Created by Léo on 04/02/2023.
//  Copyright © 2023 Homework. All rights reserved.
//

import SwiftUI
struct SinglePanelView: View {
    
    @EnvironmentObject private var  store : Store
    @AppStorage(Settings.collectionNumberBadge) var collectionNumberBadge : Bool = false
    @State var isPresentingSettings = false
    
    
    let item : AppPanel
    let view : AnyView
    var body: some View {
        NavigationStack {
            view
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            self.isPresentingSettings.toggle()
                        }, label: {
                            Image(systemName: "gear")
                        })
                    }
                }
                .navigationTitle(item.title)
        }
        
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView().environmentObject(store)
        }
        .tabItem {
            VStack {
                item.image
                Text(item.tab)
            }
        }.tag(item.rawValue)
            .badge(badgeValue)
    }
    
    var badgeValue : Int {
        collectionNumberBadge ?
        item == .sets ? store.sets.qtyOwned : store.minifigs.qtyOwned
        : 0
    }
}

enum AppPanel : Int,CaseIterable {
    case sets = 0
    case minifigures = 1
    
    var view : AnyView {
        switch self {
        case .minifigures: return AnyView(FigsView())
        default: return AnyView(SetsView())
        }
    }
    
    var tab : LocalizedStringKey {
        switch self {
        case .minifigures: return "minifig.tab"
        default: return "sets.tab"
        }
    }
    var title : LocalizedStringKey {
        switch self {
        case .minifigures: return "minifig.tab"
        default: return "sets.tab"
        }
    }
    var image : Image {
        switch self {
        case .minifigures: return Image.minifig_head
        default: return Image.brick
        }
    }
    
    var imageName : String {
        switch self {
        case .minifigures: return  "lego_head"
        default: return "lego_brick"
        }
    }
    
}

