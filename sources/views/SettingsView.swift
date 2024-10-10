//
//  SettingsView.swift
//  BrickSet
//
//  Created by Work on 02/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import SwiftUI


struct SettingsView: View {
    @Environment(Model.self) private var model
    @EnvironmentObject private var  store : Store
    @AppStorage(Settings.unreleasedSets) var unreleasedSets : Bool = false
    @AppStorage(Settings.collectionNumberBadge) var collectionNumberBadge : Bool = false
    @AppStorage(Settings.compactList) var compactList : Bool = false
    @AppStorage(Settings.appVersion2) var appVersion2 : Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    //    @AppStorage(Settings.currency) var currency : Currency = .default
    
    let feedbacks = [
        Credit(text: "credit.email", link: URL(string:kFeedbackMailto)!,image: Image(systemName:"envelope.fill")),
        Credit(text: "credit.github", link: URL(string: "https://github.com/leolelego/BrickSet")!,image: Image("github")),
        //Credit(text: "credit.twitter", link: URL(string: "https://twitter.com/leolelego")!,image: Image("twitter"))
    ]
    
    @State var logout = false
    
    var body: some View {
        NavigationStack{
            Form {
                Section(header:makeThanks()){
                    
                    HStack{
                        Text("\(model.keychain.user?.username  ?? "DNot Connected")").font(.title)
                        Spacer()
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            self.logout = true
                        }) {
                            Text( "settings.logout")
                                .fontWeight(.bold)
                            
                            
                        }.buttonStyle(RoundedButtonStyle(backgroundColor: .red, padding:8))
                    }
                    
                    
                    if isDebug {
                        HStack{
                            Text("User Hash").font(.title)
                            Spacer()
                            Button(action: {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = self.model.keychain.user?.token ?? ""
                            }) {
                                Text(store.user?.token ?? "")
                                    .fontWeight(.bold)
                            }.buttonStyle(RoundedButtonStyle(backgroundColor: .red, padding:8))
                        }
                        
                        
                    }
                    
                    HStack{
                        Text("settings.collection")
                        Spacer()
                        Text(String(store.sets.qtyOwned)+" ").font(.number(size: 20))
                        Image.brick
                        Text(String(store.minifigs.qtyOwned)+" ").font(.number(size: 20))
                        Image.minifig_head
                    }
                    HStack{
                        Text("settings.pricecollection")
                        Spacer()
                        Text(currencyFormatter.string(for:store.sets.priceOwned) ?? "")
                    }
                }
                
                Section(header: Text("settings.options")){
                    Toggle("App Version 2", isOn: $appVersion2)
                    Toggle( isOn: $unreleasedSets){
                        SettingsOptionsTexts(title: "settings.options.unreleasedsets", sub: "settings.options.unreleasedsetssub")
                    }
                    Toggle( isOn: $compactList){
                        SettingsOptionsTexts(title: "settings.options.compactList", sub: "settings.options.compactListSub")
                    }
                    Toggle( isOn: $collectionNumberBadge){
                        SettingsOptionsTexts(title: "settings.options.collectionNumberBadge", sub: "settings.options.collectionNumberBadgeSub")
                    }
                    Button {
                        store.reset()
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        
                        SettingsOptionsTexts(title: "settings.options.reset", sub: "settings.options.resetsub")
                        
                        
                    }
                    
                    
                }
                
                Section(header: Text("settings.feedbacks"),footer: makeFooter()) {
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
                
            }
            
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            })
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
        .onDisappear {
            if self.logout {
                self.model.keychain.user = nil
                self.store.reset()
            }
        }
        .accentColor(.backgroundAlt)
        
    }
    
    func makeThanks()-> some View{
        VStack{
            NavigationLink {
                WelcomeView(showContinu: false)
            } label: {
                HStack{
                    Spacer()
                    VStack{
                        Image("app_logo")
                            .padding(20)
                            .background(Circle()
                                .fill(Color.white))
                        Text("credit.thanks").bold()
                        Text(" BRICKIE ").font(.lego(size: 32)).foregroundColor(.white)
                            .padding(.top,4)
                            .background(LinearGradient(gradient: Gradient(colors:[Color(red: 0/255, green: 28/255, blue: 200/255), Color(red: 89/255, green: 235/255, blue: 255/255)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                    }
                    Spacer()
                }
            }
            
            
            Spacer()
        }
    }
    
    func makeFooter() -> some View {
        VStack(alignment: .leading, spacing: 16, content: {
            makeBrickSet()
            makeAppVersion()
            
        })
    }
    func makeBrickSet() -> some View {
        HStack(alignment: .center, spacing: 8){
            Text("login.powerby").bold().foregroundColor(.backgroundAlt)
            Image("brickset_logo")
        }
        
    }
    func makeAppVersion() -> some View {
        HStack(alignment: .center, spacing: 8){
            Spacer()
            Text("v\(kAppversion) (\(kAppBuild))").font(.footnote)
            Spacer()
            
        }
        
    }
    
    
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPhone SE")
            .environmentObject(Store())
            .previewDisplayName("Defaults")
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
