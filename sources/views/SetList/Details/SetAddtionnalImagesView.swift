//
//  SetAddtionnalImagesView.swift
//  Brickie
//
//  Created by Léo on 17/02/2022.
//  Copyright © 2022 Homework. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
struct SetAddtionnalImagesView: View {
    @Environment(Model.self) private var model

    let images :  [SetData.SetImage]
    @State var present : Bool = false
    @State var presentedURLs : [String] = []
    @State var index : Int = 1
    var body: some View {
            VStack(alignment: .leading){
                Text("sets.images").font(.title).bold().padding()
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack(spacing: 16){
                        ForEach(images, id: \.thumbnailURL){ image in
                            
                            Button(action: {
                                let urls = images.compactMap{$0.imageURL}
                                self.index = urls.firstIndex(of: image.imageURL ?? "") ?? 1
                                self.presentedURLs = urls
                                self.present.toggle()
                            }) {
                                
                                WebImage(url: URL(string: image.thumbnailURL ?? ""))
                                
                                    .resizable()
                                    .renderingMode(.original)
                                    .indicator(.activity)
                                    .transition(.fade)
                                    .aspectRatio(contentMode: .fill)
                                    .modifier(RoundedShadowMod())
                            }.disabled(!SDImageCache.shared.diskImageDataExists(withKey: image.imageURL) && model.reachability.connection == .unavailable)
                            
                        }
                    }.padding(.horizontal,32)
                }.frame(height: 100).padding(.horizontal, -16)
                
            }.transition(.fade)
            .sheet(isPresented: $present, content: { FullScreenImageView(urls: $presentedURLs,currentIndex: $index )})
    }
}


