//
//  SetAdditionalImageView.swift
//  BrickSet
//
//  Created by Work on 23/05/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
struct FullScreenImageView: View {
    @Binding var urls : [String]
    @Binding var currentIndex : Int
    @State var lastScale: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @Environment(\.dismiss) var dismiss
    var body: some View {
        let scaleGesture = MagnificationGesture(minimumScaleDelta: 0.1).onChanged { value in
            let delta = value / self.lastScale
            self.lastScale = value
            let newScale = self.scale * delta
            self.scale = min(max(newScale, 1), 6)
        }.onEnded { value in
            self.lastScale = 1.0
        }
        let dragGesture =
            DragGesture()
            .onChanged { value in
                if self.scale  > 1 {
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                }
                
            }
            .onEnded { value in
                if self.scale  > 1 {
                    
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    self.newPosition = self.currentPosition
                }
            }
        
       // let dragBeforePinch =  scaleGesture.exclusively(before:dragGesture )
        return
            NavigationStack{
                TabView (selection:$currentIndex){
                    ForEach(0..<urls.count, id: \.self){ idx in
                        
                        makeIt(idx)
                            .scaleEffect(self.scale)
                            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                            .gesture(scale > 1 ? dragGesture : nil)
                            .gesture(scaleGesture)
                            .onAppear {
                                resetGesture()
                            }
                    }
                }.tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                })
                .navigationBarTitle("", displayMode: .inline)
                .onTapGesture {
                    resetGesture()
                }
                
                
            }
            .accentColor(.backgroundAlt)
           .edgesIgnoringSafeArea(.all)

        
    }
    
    func resetGesture(){
        self.lastScale = 1.0
        self.scale = 1.0
        self.currentPosition = .zero
        self.newPosition = .zero
    }
    
    func makeIt(_ idx:Int)-> some View {
        let url = urls[idx]
        return WebImage(url: URL(string: url), options: [.progressiveLoad, .delayPlaceholder])
            .resizable()
            .placeholder(Image.wifiError.resizable())
            .renderingMode(.original)
            .indicator(.progress)
            .scaledToFit()
            .tag(idx)
    }
}


