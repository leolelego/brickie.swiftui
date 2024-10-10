//
//  Colors.swift
//  BrickSet
//
//  Created by Work on 03/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//
import SwiftUI

extension Image {
  
    static var minifig_head: Image { Image("lego_head") }
    static var brick: Image { Image("lego_brick") }
    static var wifiError : Image {Image(systemName:"wifi.slash")}
    public static func minifig_head(height:CGFloat) -> some View {
        Image("lego_head").resizable().frame(width: height*35.0/41.0, height: height)  // 35 × 41 pixels
    }
    public static func brick(height:CGFloat) -> some View {
        Image("lego_brick").resizable().frame(width: height*47.0/43.0, height: height)  // 35 × 41 pixels
    }
}

extension LinearGradient {
    static var blueBlue = LinearGradient(
        gradient: Gradient(colors:[Color(red: 0/255, green: 28/255, blue: 200/255), Color(red: 89/255, green: 170/255, blue: 255/255),Color(red: 89/255, green: 170/255, blue: 255/255)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Font {
    static func lego(size:CGFloat)->Font{
        Font.custom("LEGothicType", size: size)
    }
    static func number(size:CGFloat)->Font{
        return Font.custom("RoundedMplus1c-Black", size: size)
    }
}
