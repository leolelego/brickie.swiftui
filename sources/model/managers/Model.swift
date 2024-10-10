//
//  DataModel.swift
//  Brickie
//
//  Created by Léo on 07/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import SwiftUI
import SwiftData
import Reachability
import SDWebImage


@Observable
final class Model {
    let keychain = Keychain()
    let datamanager = DataManager()
    let reachability = Configuration()
    
    
    
    func fetchNotes(for set:SetData) async -> String {
        guard let token = keychain.user?.token else { return  set.collection.notes}
        
        do {
            let notes = try await APIRouter<[SetNote]>.getUserNotes(token).decode2()
            let note = notes.first(where: { $0.setID == set.setID})?.notes ?? ""
            set.collection.notes = note
            
        } catch{
            logerror(error)
        }
        return set.collection.notes
    }
    
    
    
}


