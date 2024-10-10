//
//  SwiftDataManager.swift
//  Brickie
//
//  Created by Léo on 09/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import SwiftData
import Foundation
class DataManager {
    lazy var modelContainer: ModelContainer = {
        let schema = Schema([
            SetData.self,
            SetData.SetCollection.self,
            SetData.BarCode.self,
            SetData.Dimension.self,
            SetData.AgeRange.self ,
            SetData.Prices.self,
            SetData.SetImage.self,
            SetData.Instruction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("ModelContainer creation failed: \(error)")
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not recreate ModelContainer: \(error)")
            }
        }
    }()
    @MainActor
    var modelContext: ModelContext {
        modelContainer.mainContext
    }
    

}
