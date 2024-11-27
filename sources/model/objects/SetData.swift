//
//  SetData.swift
//  Brickie
//
//  Created by Léo on 07/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import Foundation
import SwiftData


@Model
final class SetData : Decodable,Equatable{
    #Unique<SetData>([\.setID])
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
    var minifigs : Int?
    @Relationship(deleteRule: .cascade, inverse: \SetImage.legoSet)
    var image : SetImage
    
    @Relationship(deleteRule: .cascade, inverse: \SetImage.legoSetAddtionnal)
    var additionalImages : [SetImage]?
    var bricksetURL : String
    @Relationship(deleteRule: .cascade, inverse: \SetCollection.legoSet)
    var collection : SetCollection
    
    var rating : Float
    var packagingType : String
    var availability : String
    var instructionsCount : Float
    
    @Relationship(deleteRule: .cascade, inverse: \Prices.legoSet)
    var prices : Prices?
    @Relationship(deleteRule: .cascade, inverse: \BarCode.legoSet)
    var barcode : BarCode?
    @Relationship(deleteRule: .cascade, inverse: \Dimension.legoSet)
    var dimensions : Dimension
    @Relationship(deleteRule: .cascade, inverse: \AgeRange.legoSet)
    var ageRange : AgeRange
//    let collections : Collections
    

    
    @Relationship(deleteRule: .cascade, inverse: \Instruction.legoSet)
    var instrucctions : [Instruction]?

    
    init(setID: Int, number: String, name: String, year: Int,theme: String, themeGroup: String?, subtheme: String?, category: String,
         pieces: Int?, minifigs: Int?,image:SetImage, bricksetURL: String, rating: Float, packagingType: String, availability: String,
         instructionsCount: Float,collection: SetCollection,barcode:BarCode,dimensions: Dimension, ageRange: AgeRange,prices:Prices,
         additionalImages:[SetImage]?,instrucctions:[Instruction]?
    
    ) {
        self.setID = setID
        self.number = number
        self.name = name
        self.year = year
        self.theme = theme
        self.themeGroup = themeGroup
        self.subtheme = subtheme
        self.category = category
        self.pieces = pieces
        self.minifigs = minifigs
        self.bricksetURL = bricksetURL
        self.rating = rating
        self.packagingType = packagingType
        self.availability = availability
        self.instructionsCount = instructionsCount
        self.collection = collection
        self.image = image
        self.barcode = barcode
        self.dimensions = dimensions
        self.ageRange = ageRange
        self.prices = prices
        self.additionalImages = additionalImages
        self.instrucctions = instrucctions
        
    }
    
    enum CodingKeys: CodingKey {
        case setID, name, number, year, theme, themeGroup, subtheme, category, pieces, minifigs, bricksetURL, rating,
             packagingType, availability, instructionsCount, collection, barcode,image,dimensions,ageRange, LEGOCom,
        additionalImages, instructions
    }
//    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.setID = try container.decode(Int.self, forKey: .setID)
        self.number = try container.decode(String.self, forKey: .number)
        self.name = try container.decode(String.self, forKey: .name)
        self.year = try container.decode(Int.self, forKey: .year)
        self.theme = try container.decode(String.self, forKey: .theme)
        self.themeGroup = try? container.decode(String.self, forKey: .themeGroup)
        self.subtheme = try? container.decode(String.self, forKey: .subtheme)
        self.category = try container.decode(String.self, forKey: .category)
        self.pieces = try? container.decode(Int.self, forKey: .pieces)
        self.minifigs = try? container.decode(Int.self, forKey: .minifigs)
        self.bricksetURL = try container.decode(String.self, forKey: .bricksetURL)
        self.rating = try container.decode(Float.self, forKey: .rating)
        self.packagingType = try container.decode(String.self, forKey: .packagingType)
        self.availability = try container.decode(String.self, forKey: .availability)
        self.instructionsCount = try container.decode(Float.self, forKey: .instructionsCount)
        self.collection = try container.decode(SetCollection.self, forKey: .collection)
        self.barcode = try container.decodeIfPresent(BarCode.self, forKey: .barcode)
        self.image = try container.decode(SetImage.self, forKey: .image)
        self.dimensions = try container.decode(Dimension.self, forKey: .dimensions)
        self.ageRange = try container.decode(AgeRange.self, forKey: .ageRange)
        self.prices = try container.decodeIfPresent(Prices.self, forKey: .LEGOCom)
        if let data =  try container.decodeIfPresent([SetImage].self, forKey: .additionalImages){
            self.additionalImages = data // Update only if exist so we keep download from another way
        }
        if let data =  try container.decodeIfPresent([Instruction].self, forKey: .instructions) {
            self.instrucctions = data // Update only if exist so we keep download from another way
        }
        
    }
    
    class SetNote : Codable {
        let setID : Int
        let notes : String
    }


}


extension SetData {
    static var previewData: SetData {
        let setImage = SetImage(thumbnailURL: "https://images.brickset.com/sets/small/1371-1.jpg",
                                imageURL: "https://images.brickset.com/sets/images/1371-1.jpg")

        let setCollection = SetCollection(owned: true, wanted: false, qtyOwned: 1, rating: 0, notes: "")

        return SetData(
            setID: 268,
            number: "1371",
            name: "Spinosaurus Attack",
            year: 2001,
            theme: "Studios",
            themeGroup: "Modern day",
            subtheme: "Jurassic Park III",
            category: "Normal",
            pieces: 155,
            minifigs: 2,
            image: setImage,
            bricksetURL: "https://brickset.com/sets/1371-1",
            rating: 0,
            packagingType: "Box",
            availability: "REtail",
            instructionsCount: 1,
            collection: setCollection,
            barcode: BarCode(EAN: "02681371100000"),
            dimensions: .previewData,
            ageRange: .init(min:3),
            prices: .previewData,
            additionalImages: nil,
            instrucctions: []
        )
    }
}
