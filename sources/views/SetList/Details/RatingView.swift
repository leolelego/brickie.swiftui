//
//  RatingView.swift
//  Brickie
//
//  Created by Léo on 05/01/2022.
//  Copyright © 2022 Homework. All rights reserved.
//

import SwiftUI
enum RatingStar :  String {
    case filled =  "star.fill"
    case half = "star.leadinghalf.fill"
    case empty = "star"
    
    var view : some View {
        Image(systemName: self.rawValue)
    }
}
struct RatingView: View {
    @EnvironmentObject private var  store : Store
    
    var  rating : Float {editable ? set.collection.rating : set.rating}
    var set : SetData
    let editable : Bool
    func star(level:Int) -> RatingStar {
        if Int(rating) >= level {
            return RatingStar.filled
        } else if self.rating.truncatingRemainder(dividingBy: 1) > 0.8 {
            return RatingStar.filled
        } else if  self.rating.truncatingRemainder(dividingBy: 1) > 0.3 {
            return RatingStar.half
        } else {
            return RatingStar.empty
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            HStack(alignment: .center, spacing: 4) {
                HStack {
                    ForEach(1...5, id: \.self){ n in
                        Button {
                            setRating(n)
                        } label: {
                            star(level: n).view
                        }.disabled(!editable)
                        
                        
                    }
                }.modifier(Rainbow())
                Text("(\(String(format: "%.1f", rating)))").bold()
            }
            if editable {
                Text("rating.edit").font(.caption).foregroundColor(.secondary)
            }
        }
    }
    
    func setRating(_ newRating:Int){
        
        Task {
            _ = try? await APIRouter<String>.setRating(store.user!.token, set.setID, newRating).responseJSON2()
            
            set.collection.rating = Float(newRating)
        }
    }
}
extension Float {
    func truncate(places : Int)-> Float {
        return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places)))
    }
}
struct Rainbow: ViewModifier {
    let hueColors = [
        Color(red: 255/255, green: 102/255, blue: 102/255),
        Color(red: 255/255, green: 189/255, blue: 85/255),
        Color(red: 255/255, green: 255/255, blue: 102/255),
        Color(red: 157/255, green: 226/255, blue: 79/255),
        Color(red: 135/255, green: 206/255, blue: 250/255),
    ]
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { (proxy: GeometryProxy) in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: self.hueColors),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    .frame(width: proxy.size.width)
                }.allowsHitTesting(false)
            })
            .mask(content)
    }
}
