//
//  SetData+Infos.swift
//  Brickie
//
//  Created by Léo on 10/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import SwiftData
extension SetData{
    @Model
    final class SetCollection : Decodable {
        var owned : Bool
        var wanted : Bool
        var qtyOwned : Int
        var rating : Float
        var notes = ""
        
        var legoSet : SetData?
        
        init(owned: Bool, wanted: Bool, qtyOwned: Int, rating: Float, notes: String = "") {
            self.owned = owned
            self.wanted = wanted
            self.qtyOwned = qtyOwned
            self.rating = rating
            self.notes = notes
        }
        
        enum CodingKeys: CodingKey {
            case owned, wanted, qtyOwned, rating, notes
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            owned = try container.decode(Bool.self, forKey: .owned)
            wanted = try container.decode(Bool.self, forKey: .wanted)
            qtyOwned = try container.decode(Int.self, forKey: .qtyOwned)
            rating = try container.decode(Float.self, forKey: .rating)
            notes = try container.decode(String.self, forKey: .notes)
        }
    }
    @Model
    final class SetImage : Decodable {
        var thumbnailURL : String?
        var imageURL : String?
        
        var legoSet : SetData?
        var legoSetAddtionnal : SetData?
        init(thumbnailURL: String? = nil, imageURL: String? = nil) {
            self.thumbnailURL = thumbnailURL
            self.imageURL = imageURL
        }
        enum CodingKeys: CodingKey {
            case thumbnailURL
            case imageURL
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
            thumbnailURL = try container.decodeIfPresent(String.self, forKey: .thumbnailURL)
        }
    }
    
    @Model
    final class Dimension: Decodable {
        
        var height: Float?
        var width: Float?
        var depth: Float?
        var weight: Float?
        
        var legoSet : SetData?
        // Default initializer
        init(height: Float? = nil, width: Float? = nil, depth: Float? = nil, weight: Float? = nil) {
            self.height = height
            self.width = width
            self.depth = depth
            self.weight = weight
        }
        
        // Custom Decodable initializer
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.height = try container.decodeIfPresent(Float.self, forKey: .height)
            self.width = try container.decodeIfPresent(Float.self, forKey: .width)
            self.depth = try container.decodeIfPresent(Float.self, forKey: .depth)
            self.weight = try container.decodeIfPresent(Float.self, forKey: .weight)
        }
        
        private enum CodingKeys: String, CodingKey {
            case height, width, depth, weight
        }
            static var previewData: Dimension {
                Dimension(
                    height: 28.8,
                    width: 28.8,
                    depth: 4.8,
                    weight: 1.2
                )
            }
    }
    
    @Model
    final class Instruction: Decodable {
        var URL: String
        var descriptions: String
        
        var legoSet : SetData?
        // Default initializer
        init(URL: String = "", descriptions: String = "") {
            self.URL = URL
            self.descriptions = descriptions
        }
        
        // Custom Decodable initializer
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.URL = try container.decode(String.self, forKey: .URL)
            self.descriptions = try container.decode(String.self, forKey: .description)
        }
        
        private enum CodingKeys: String, CodingKey {
            case URL, description
        }
    }
    
    @Model
    final class AgeRange: Decodable {
        var min: Int?
        
        var legoSet : SetData?
        
        // Default initializer
        init(min: Int? = nil) {
            self.min = min
        }
        
        // Custom Decodable initializer
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.min = try container.decodeIfPresent(Int.self, forKey: .min)
        }
        
        private enum CodingKeys: String, CodingKey {
            case min
        }
    }
    
    @Model
    final class Prices: Decodable {
        var US: Float?
        var UK: Float?
        var CA: Float?
        var DE: Float?
        
        var legoSet : SetData?
        // Default initializer
        init(US: Float? = nil, UK: Float? = nil, CA: Float? = nil, DE: Float? = nil) {
            self.US = US
            self.UK = UK
            self.CA = CA
            self.DE = DE
        }
        
        // Custom Decodable initializer
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.US = try container.decode(Price.self, forKey: .US).retailPrice
            self.UK = try container.decode(Price.self, forKey: .UK).retailPrice
            self.CA = try container.decode(Price.self, forKey: .CA).retailPrice
            self.DE = try container.decode(Price.self, forKey: .DE).retailPrice
        }
        
        private enum CodingKeys: String, CodingKey {
            case US, UK, CA, DE
        }
        final class Price: Decodable {
            var retailPrice: Float?
            
            var prices : Prices?
            // Default initializer
            init(retailPrice: Float? = nil) {
                self.retailPrice = retailPrice
            }
            
            // Custom Decodable initializer
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.retailPrice = try container.decodeIfPresent(Float.self, forKey: .retailPrice)
            }
            
            private enum CodingKeys: String, CodingKey {
                case retailPrice
            }
        }
        static var previewData: Prices {
                Prices(
                    US: 24,
                    UK: 22,
                    CA: 22,
                    DE: 22
                )
            }
    }
    
    
    
    @Model
    final class BarCode: Decodable {
        var EAN: String?
        var UPC: String?
        var legoSet : SetData?
        // Default initializer
        init(EAN: String? = nil, UPC: String? = nil) {
            self.EAN = EAN
            self.UPC = UPC
        }
        
        // Custom Decodable initializer
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.EAN = try container.decodeIfPresent(String.self, forKey: .EAN)
            self.UPC = try container.decodeIfPresent(String.self, forKey: .UPC)
        }
        
        private enum CodingKeys: String, CodingKey {
            case EAN, UPC
        }
    }
    
    
}
