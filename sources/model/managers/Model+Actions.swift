//
//  Model+Actions.swift
//  Brickie
//
//  Created by Léo on 14/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import Foundation

extension Model {
    @MainActor
    func perform(_ action:Action,on item:SetData) async throws {
        guard let token = keychain.user?.token else {return}
        
        switch action {
        case .want(let wanted):
            
            _ = try await APIRouter<String>.setWanted(token, item.setID, wanted).responseJSON2()
            
            let c = item.collection
            c.wanted = wanted
            item.collection = c
            break
        case .qty(let q):
            _ = try await APIRouter<String>.setQty(token, item.setID, q).responseJSON2()
            let c = item.collection
            c.qtyOwned = q >= 0 ?  q : 0
            c.owned = q > 0
            item.collection = c

            break
        case .notes(let note):
            _ = try await APIRouter<String>.setNotes(token, item.setID, note).responseJSON2()
            break
        case .instructions:
            let instructions = try await APIRouter<[SetData.Instruction]>.setInstructions(item.setID).decode2()
            item.instrucctions = instructions
        case .additionalImages:
            let images = try await APIRouter<[SetData.SetImage]>.additionalImages(item.setID).decode2()
            item.additionalImages = images
            break
            
        case .rating(let rate):
            _ = try? await APIRouter<String>.setRating(token, item.setID, rate).responseJSON2()
            let c = item.collection
            c.rating = Float(rate)
            item.collection = c
            break
        }
        
    }
    enum Action {
        case want(Bool)
        case qty(Int)
        case notes(String)
        case instructions
        case additionalImages
        case rating(Int)
    }
}
