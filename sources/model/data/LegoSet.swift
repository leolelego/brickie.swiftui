//
//  LegoSet.swift
//  BrickSet
//
//  Created by Work on 02/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import Foundation

class LegoSet : Lego, Hashable {
    var setID : Int = 0
    var number : String = ""
    var name : String = ""
    var year : Int = 0
    
    var theme : String = ""
    var themeGroup : String? = ""
    var subtheme : String? = ""
    var category : String = ""
    //var released : Bool = true
    var pieces : Int? = 0
    let minifigs : Int?
    let image : SetImage
    let bricksetURL : String
    var collection : Collection
    let rating : Float
    let packagingType : String
    let availability : String
    let instructionsCount : Float
    let LEGOCom : [String:Prices.Price]
    let barcode : BarCode?
    let dimensions : Dimension
    let ageRange : AgeRange
    let collections : Collections
    
    var price : String? {
        switch Locale(identifier: Locale.currentRegionCode).identifier {
        case "ca":
            return currencyFormatter.string(for: LEGOCom["CA"]?.retailPrice)
        case "us":
            return currencyFormatter.string(for: LEGOCom["US"]?.retailPrice)
        case "gb":
            return currencyFormatter.string(for: LEGOCom["UK"]?.retailPrice)
        default:
            currencyFormatter.currencyCode = "EUR"
            return currencyFormatter.string(for: LEGOCom["DE"]?.retailPrice)
        }
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
    
    var pricePerPieceFloat: Float {
        guard let piec = pieces, piec != 0 else {return 0}
        return priceFloat / Float(piec)
    }
    
    var priceFloat : Float {
           switch Locale(identifier: Locale.currentRegionCode).identifier {
           case "ca":
               return LEGOCom["CA"]?.retailPrice ?? 0
           case "us":
               return LEGOCom["US"]?.retailPrice ?? 0
           case "gb":
               return LEGOCom["UK"]?.retailPrice ?? 0
           default:
               return LEGOCom["DE"]?.retailPrice ?? 0
           }
       }
    
    
    var additionalImages : [SetImage]?
    var instrucctions : [Instruction]?

    
    static func == (lhs: LegoSet, rhs: LegoSet) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(setID)
        hasher.combine(category)
    }
    
    func update(from: LegoSet){
        objectWillChange.send()
        self.collection = from.collection
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
extension LegoSet : CustomStringConvertible {
    var description: String {
        return "\(name) - O:\(collection.owned) - W:\(collection.wanted) - Q:\(collection.qtyOwned)"
    }
}

extension LegoSet : Identifiable {
    var id: Int {setID}
}
extension LegoSet : ObservableObject{}

extension Array where  Element:LegoSet {
    var qtyOwned : Int {
        return self.compactMap { return $0.collection.qtyOwned}.reduce(0, +)
    }
    var priceOwned : Float {
        return self.compactMap { return Float($0.collection.qtyOwned) * $0.priceFloat}.reduce(0, +)
    }
}

extension LegoSet {
    var hasDimensions : Bool {
        return dimensions.width != nil && dimensions.height != nil && dimensions.depth != nil
    }
    var hasWeight : Bool {
        return dimensions.weight != nil
    }
}

