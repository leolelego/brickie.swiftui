//
//  ThumbnailView.swift
//  Brickie
//
//  Created by Léo on 16/02/2022.
//  Copyright © 2022 Homework. All rights reserved.
//

import SwiftUI
import  SDWebImageSwiftUI

struct ThumbnailView: View {
    
    let url : String?
    let minHeight : CGFloat
    let maxHeight : CGFloat
    var canTap : Bool = true
    @State var present : Bool = false
    @State var presentedURLs : [String] = []
    var body: some View {
        if canTap {
            Button(action: {
                presentedURLs = [url ?? "" ]
                present.toggle()
                
            }) {
                imageView
            }
//            .sheet(isPresented: $present, content: { FullScreenImageView(isPresented: $present, urls: $presentedURLs,currentIndex: .constant(0) )})
            
        } else {imageView}
    }
    
    var imageView : some View {
        WebImage(url: URL(string: url ?? ""), options: [.progressiveLoad, .delayPlaceholder])
            .resizable()
            .renderingMode(.original)
            .placeholder(.wifiError)
            .indicator(.progress)
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight, maxHeight: maxHeight, alignment: .center)
            .background(.white)
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(url: "https://images.brickset.com/sets/large/71765-1.jpg",minHeight: 200,maxHeight: 400)
    }
}
