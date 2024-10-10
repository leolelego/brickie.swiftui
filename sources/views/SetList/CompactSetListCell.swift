//
//  CompactSetListCell.swift
//  Brickie
//
//  Created by Léo on 05/04/2023.
//  Copyright © 2023 Homework. All rights reserved.
//

import SwiftUI

struct CompactSetListCell : View {
    var set : SetData
    @AppStorage(Settings.setsListSorter) var sorter : LegoListSorter = .default

    let cellHeight : CGFloat = 50
    var body: some View {
        HStack(alignment: .top) {
            ThumbnailView(url: set.image.thumbnailURL, minHeight: cellHeight, maxHeight: cellHeight,canTap: false).frame(width: cellHeight,height: cellHeight)
                .cornerRadius(6)
            VStack(alignment: .leading) {
                Text(set.name).font(.body).bold()
                Text(set.number+" ").font(.lego(size: 14))
            }
        
            Spacer()
            HStack(alignment: .center,spacing: 4) {
                additionalData
                if set.collection.wanted  {
                    Image(systemName: set.collection.wanted ? "heart.fill":"heart")//.font(.footnote)
                        .foregroundColor(.backgroundAlt)
                }
                if set.collection.qtyOwned > 1 {
                    Text("\(set.collection.qtyOwned)").pill
                    
                }
            }
        }
    }
    var additionalData : some View {
        Group{
            switch sorter {
            case .piece, .pieceDesc:
                HStack(alignment: .center){
                    Text("\(set.pieces ?? 0)")
                    Image.brick(height:10)}
                
            case .price,.priceDesc:
                Text(set.price ?? "")
                
            case .pricePerPiece , .pricePerPieceDesc:
                Text("\(set.pricePerPiece ?? "")/p")
            default:
                EmptyView()
            }
        }.foregroundColor(.gray).font(.footnote).padding(.horizontal,4)
    }
}
