//
//  PastilView.swift
//  Brickie
//
//  Created by Leo on 29/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI

struct PastilView: View {
    let owned : Int
    let wanted : Bool
    var body: some View {
            HStack {
                if owned != 0 {
                    Text("\(owned)").font(.body).bold()
                        .padding(.horizontal,8).foregroundColor(.white)
                }
                if wanted  {
                    Image(systemName: wanted ? "heart.fill":"heart").font(.footnote)
                        .padding(.horizontal,8)
                        .foregroundColor(.white)
                        .padding(.vertical,4)
                }
            }
            .background(RoundedCorners(color: Color.black, tl: 16, tr: 0, bl: 0, br: 0))
    }
}

struct PastilView_Previews: PreviewProvider {
    static var previews: some View {
        PastilView(owned: 3, wanted: true)
    }
}
