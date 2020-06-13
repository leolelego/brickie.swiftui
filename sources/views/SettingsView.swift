//
//  SettingsView.swift
//  BrickSet
//
//  Created by Work on 02/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var  collection : UserCollection
    //    @EnvironmentObject var config: Configuration
    @Environment(\.presentationMode) var presentationMode

    let feedbacks = [
        Credit(text: "credit.github", link: URL(string: "https://github.com/leolelego/BrickSet")!,image: Image("github")),
        //Credit(text: "credit.instagram", link: URL(string: "https://instagram.com/leolelego")!,image: Image("instagram")),
        Credit(text: "credit.twitter", link: URL(string: "https://twitter.com/leolelego")!,image: Image("twitter")),
        //Credit(text: "credit.testflight", link: URL(string: "https://testflight.apple.com/join/9IE197Mt")!,image: Image("lego_head")),
        
    ]
    @State var logout = false
    
    var body: some View {
        NavigationView{
            Form {
                HStack{
                    Text("\(collection.user?.username  ?? "Debug Name")").font(.title)
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.logout = true
                        // self.collection.user = nil
                    }) {
                        Text( "settings.logout")
                            .fontWeight(.bold)
                        
                        
                    }.buttonStyle(RoundedButtonStyle(backgroundColor: .red, padding:8))
                }
                
                if Configuration.isDebug {
                    HStack{
                        Text("User Hash").font(.title)
                        Spacer()
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = self.collection.user?.token ?? ""
                        }) {
                            Text(collection.user?.token ?? "")
                                .fontWeight(.bold)
                        }.buttonStyle(RoundedButtonStyle(backgroundColor: .red, padding:8))
                    }
                    
                }
                
                Section(header: Text("settings.feedbacks"),footer: makeBrickSet()) {
                    ForEach(feedbacks){ c in
                        Button(action: {
                            UIApplication.shared.open(c.link)
                        }) {
                            HStack {
                                c.image
                                Text(c.text)
                            }
                        }
                    }
                }
                
                //                if config.connection != .unavailable {
                //                    Section(header: Text("settings.dangerzone")) {
                //                        HStack{
                //
                //                            Text("settings.cache").font(.title)
                //                            Spacer()
                //                            Button(action: {
                //                                self.collection.reset()
                //                            }) {
                //                                Text( "settings.free")
                //                                    .fontWeight(.bold)
                //                            }.buttonStyle(RoundedButtonStyle(backgroundColor: .red, padding:8))
                //                        }
                //                    }
                //                }
                
                
            }
            .listStyle(GroupedListStyle())
                        .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle("settings.title")
        }
        .onAppear {
            tweakTableView(on:false)
        }.onDisappear {
            tweakTableView(on:true)
            if self.logout {
                self.collection.user = nil
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.backgroundAlt)
        
    }
    func makeBrickSet() -> some View {
        HStack(alignment: .center, spacing: 8){
            Text("login.powerby").bold().foregroundColor(.backgroundAlt)
            Image("brickset_logo")
        }
        
    }
    
    
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


struct Credit : Identifiable {
    let text : LocalizedStringKey
    let link : URL
    let image : Image
    var id : URL {
        return link
    }
}
