//
//  SetData+Ext.swift
//  Brickie
//
//  Created by Léo on 10/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import Foundation
extension SetData {
    var price : String? {
        
        
        switch Locale(identifier: Locale.currentRegionCode).identifier {
        case "ca","us","gb":
            return currencyFormatter.string(for: priceFloat)
        default:
            currencyFormatter.currencyCode = "EUR"
            return currencyFormatter.string(for: priceFloat)
        }
    }
    
    var pricePerPieceFloat: Float {
        guard let piec = pieces, piec != 0 else {return 0}
        return priceFloat / Float(piec)
    }
    
    var pricePerPiece : String? {
        switch Locale(identifier: Locale.current.region?.identifier ?? "us").identifier {
        case "ca", "us","gb":
            return currencyFormatter.string(for: pricePerPieceFloat)
        default:
            currencyFormatter.currencyCode = "EUR"
            return currencyFormatter.string(for: pricePerPieceFloat)
        }
    }
    
    var priceFloat : Float {
           switch Locale(identifier: Locale.currentRegionCode).identifier {
           case "ca": prices?.CA ?? 0
           case "us": prices?.US ?? 0
           case "gb": prices?.UK ?? 0
           default:prices?.DE ?? 0
               
           }
       }
    
    func matchString(_ search: String) -> Bool {
        
        let matched = name.lowercased().contains(search)
            || number.lowercased().contains(search)
            || theme.lowercased().contains(search)
            || themeGroup?.lowercased().contains(search) ?? false
            ||   subtheme?.lowercased().contains(search) ?? false
            || category.lowercased().contains(search)
            || "\(year)".lowercased().contains(search)
            || barcode?.EAN?.contains(search) ?? false
            || barcode?.UPC?.contains(search) ?? false
        
        return matched
    }

}

extension Array where  Element:SetData {
    var qtyOwned : Int {
        return self.compactMap { return $0.collection.qtyOwned}.reduce(0, +)
    }
    var priceOwned : Float {
        return self.compactMap { return Float($0.collection.qtyOwned) * $0.priceFloat}.reduce(0, +)
    }
}

extension SetData {
    var hasDimensions : Bool {
        return dimensions.width != nil && dimensions.height != nil && dimensions.depth != nil
    }
    var hasWeight : Bool {
        return dimensions.weight != nil
    }
}
