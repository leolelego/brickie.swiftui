//
//  Model+Fetch.swift
//  Brickie
//
//  Created by Léo on 15/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import SwiftData
extension Model {
    @MainActor
    func fetch(_ action:FetchAction) async throws {
        guard let token = keychain.user?.token else {return}
        
        switch action {
        case .ownedSets: await fetchOwnedSets(token: token)
            break
        case .wantedSets:
            
            break
        case .all:
            
            break
        }
    }
    enum FetchAction {
        case ownedSets
        case wantedSets
        case all
    }
    
    
    private func fetchOwnedSets(token:String) async  {
        var page = 1
        var ownedSets: [SetData] = []
        while let data =  try? await APIRouter<[SetData]>.ownedSets(token,page).decode2() , data.count > 0 {
            
            for datum in data {
                ownedSets.append(datum)
            }
            page = page + 1
        }
        
        Task { @MainActor in
            
            do {
                let descriptor = FetchDescriptor<SetData>()
                let sets = try datamanager.modelContext.fetch(descriptor)
                
                // Items not found in the request are set to 0
                sets.forEach { set in
                    set.collection.owned = ownedSets.contains(set)
                    set.collection.qtyOwned = 0
                }
                
                // append to DB
                ownedSets.forEach { set in
                    datamanager.modelContext.insert(set)
                }
                try? datamanager.modelContext.save()
                
                log("Owned sets \(ownedSets.count)")
            } catch {
                logerror(error)
            }
        }
        
    }
}
