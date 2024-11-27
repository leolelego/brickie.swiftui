//
//  Model+Fetch.swift
//  Brickie
//
//  Created by Léo on 15/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import SwiftData
import Foundation
extension Model {
   
    func fetch(_ action:FetchAction) async throws {
        guard let token = keychain.user?.token else {return}
        
        switch action {
        case .ownedSets:
            await fetchSets(
                apiRouter: { page in APIRouter<[SetData]>.ownedSets(token,page)},
                updateCollection: { set, isOwned in
                    set.collection.owned = isOwned
                    if !isOwned {
                        set.collection.qtyOwned = 0
                    }
                }
            )
            break
        case .wantedSets:
            await fetchSets(
                apiRouter:  { page in APIRouter<[SetData]>.wantedSets(token,page)},
                updateCollection: { set, isWanted in
                    set.collection.wanted = isWanted
                }
            )
            break
        case .all:
            break
        case .search(let search):
            log("Search for action \(search)")
            await fetchSets(
                apiRouter: { page in APIRouter<[SetData]>.searchSets(token, search, page)},
                updateCollection: { set, _ in }
            )
            break
        
        case .searchQR(let search):
            await fetchSets(
                apiRouter: { page in APIRouter<[SetData]>.searchSets(token, search, page)},
                updateCollection: { set, _ in }
            )
            break
        }
    }
    
    enum FetchAction {
        case ownedSets
        case wantedSets
        case all
        case search(String)
        case searchQR(String)
        func predicate() -> Predicate<SetData>? {
            switch self {
            case .ownedSets:
                return #Predicate {$0.collection.owned == true}
            case .wantedSets:
                return #Predicate { $0.collection.wanted == true }
            case .all:
                return nil // No predicate needed, fetch all
            case .search(let search):
                return #Predicate {
                       $0.name.localizedStandardContains(search) ||
                       $0.number.localizedStandardContains(search) ||
                       $0.theme.localizedStandardContains(search) ||
                       ($0.themeGroup?.localizedStandardContains(search) ?? false) ||
                       ($0.subtheme?.localizedStandardContains(search) ?? false) ||
                       $0.category.localizedStandardContains(search) //||
                     // ($0.barcode?.EAN?.localizedStandardContains(search) ?? false)// ||
//                       ($0.barcode?.UPC?.localizedStandardContains(search) ?? false)
                   }
            case .searchQR(let search):
                return #Predicate {
                    ($0.barcode?.EAN?.localizedStandardContains(search) ?? false)
                    || ($0.barcode?.UPC?.localizedStandardContains(search) ?? false)
       
                   }
                
            }
        }
    }
    
    
    
    private func fetchSets(
        apiRouter: (Int) -> APIRouter<[SetData]>,
        updateCollection: @escaping (SetData, Bool) -> Void
    ) async {
        var page = 1
        var fetchedSets: [SetData] = []
        print("fetch Looping")

        // Fetch data from the API
        while let data = try? await apiRouter(page).decode2(), !data.isEmpty {
            fetchedSets.append(contentsOf: data)
            page += 1
            
            print("fetch Loop \(page)")

        }
        print("fetch OK")
        
        // Update the database on the main thread
        Task { @MainActor in
            do {
                print("fetch Udpate data")
                let modelContext =  datamanager.modelContext

                let descriptor = FetchDescriptor<SetData>()
                let sets = try modelContext.fetch(descriptor)
                
                // Update existing sets in the database
                sets.forEach { set in
                    updateCollection(set, fetchedSets.contains(set))
                }
                
                // Insert new sets into the database
                fetchedSets.forEach { set in
                    modelContext.insert(set)
                }
                
//                Task { @MainActor in
                    try modelContext.save()

//                }
                log("Fetch sets: \(fetchedSets.count)")
            } catch {
                logerror(error)
            }
        }
    }
}
