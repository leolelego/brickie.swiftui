//
//  SetsView.swift
//  Brickie
//
//  Created by Léo on 07/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//

import SwiftUI
import Combine
import SwiftData


struct SetsView2: View {
    @Environment(Model.self) private var model
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SetData>{set in set.collection.owned == true})
    private var sets: [SetData]
    
    @Query private var sets2: [SetData]
    @Query private var collec: [SetData.SetCollection]
    @Query private var age: [SetData.AgeRange]
    @Query private var dim: [SetData.Dimension]
    @Query private var prices: [SetData.Prices]
    @Query private var code: [SetData.BarCode]
    @Query private var images: [SetData.SetImage]
    @Query private var instru: [SetData.Instruction]
    
    @AppStorage(Settings.appVersion2) private var appVersion2: Bool = true
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack{
            SetsListView(fetchMode:.ownedSets,sorter:.constant(.default))

        }
        
        .task {
            isLoading = true
            try? await model.fetch(.ownedSets)
            isLoading = false
        }
        
        
    }
    
}

#Preview {
    SetsView2()
}

