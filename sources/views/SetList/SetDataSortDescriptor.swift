//
//  SetDataSortDescriptor.swift
//  Brickie
//
//  Created by Léo on 25/11/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import Foundation
import SwiftUI
extension SetData {
    enum SortDescriptorProvider:String,CaseIterable,Identifiable {
        var id: RawValue { rawValue }
        case alphabetical = "alphabetical"

//        case `default` = "default"
        case number = "number"
        case newer = "newer"
        case older = "older"
        case rating = "rating"
        case piece = "piece"
        case pieceDesc = "pieceDesc"
//        case price = "price"
//        case priceDesc = "priceDesc"
//        case pricePerPiece = "pricePerPiece"
//        case pricePerPieceDesc = "pricePerPieceDesc"
//        case owned
        
        var local : LocalizedStringKey {
            switch self {
            case .number:return "sorter.number"
            case .newer:return "sorter.newer"
            case .older:return "sorter.older"
            case .alphabetical:return "sorter.alphabetical"
            case .rating:return "sorter.rating"
            case .piece:return "sorter.piece"
            case .pieceDesc:return "sorter.pieceDesc"
//            case .price:return "sorter.price"
//            case .priceDesc:return "sorter.priceDesc"
//            case .owned:return "filter.owned"
//            case .pricePerPiece:return "sorter.pricePerPiece"
//            case .pricePerPieceDesc:return "sorter.pricePerPieceDesc"
           // default: return "sorter.default"
            }
        }
        
        
        var systemImage : String {
            switch self {
            case .number:return "number"
            case .newer:return "clock"
            case .older:return "clock"
            case .alphabetical:return "textformat.abc"
            case .rating:return "star.leadinghalf.fill"
//            case .piece,.pieceDesc,.pricePerPiece,.pricePerPieceDesc:return "puzzlepiece"
//            case .price,.priceDesc:return "dollarsign.circle"
//            case .owned:return "textformat.abc"
            default: return "staroflife"
            }
        }
        
        var sortDescriptors: [SortDescriptor<SetData>] {
            switch self {
            case .number:return [SortDescriptor(\.number)]
            case .newer:return [SortDescriptor(\.year)]
            case .older:return  [SortDescriptor(\.year,order: .reverse)]
            case .alphabetical:return  [SortDescriptor(\.name)]
            case .rating:return  [SortDescriptor(\.rating)]
            case .piece:return  [SortDescriptor(\.pieces)]
            case .pieceDesc:return [SortDescriptor(\.pieces,order: .reverse)]
//            case .price:return [SortDescriptor(\.price)]
//            case .priceDesc:return [SortDescriptor(\.price,order: .reverse)]
            //case .owned:return "filter.owned"
//            case .pricePerPiece:return [SortDescriptor(\.pricePerPieceFloat,order: .reverse)]
//            case .pricePerPieceDesc:return [SortDescriptor(\.pricePerPieceFloat)]
            default: return [SortDescriptor(\.name)]
            }
        }
    }
}
