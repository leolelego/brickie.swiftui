//
//  SetsListView.swift
//  BrickSet
//
//  Created by Work on 18/05/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import SwiftData
struct SetsListView2: View {
    @Environment(Model.self) private var model
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage(Settings.compactList) var compactList : Bool = false
    @Query private var sets: [SetData]

    let fetchMode : Model.FetchAction
    
    init(fetchMode:Model.FetchAction,sortOrder: [SortDescriptor<SetData>]){
        _sets = Query(filter:fetchMode.predicate(),sort: sortOrder)
        self.fetchMode = fetchMode

    }
    
    var body: some View {
        List {
            if sets.isEmpty {
                noItems()
            }
                  
                    ForEach(sets) { item in
                        NakedListActionCell(
                            owned: item.collection.qtyOwned, wanted: item.collection.wanted,
                            add: {
                                Task(priority: .userInitiated) {
                                    try? await model.perform(.qty(item.collection.qtyOwned+1),on: item)
                                }
                            },
                            remove: {
                                Task(priority: .userInitiated) {
                                    try? await model.perform(.qty(item.collection.qtyOwned-1),on: item)
                                    
                                }
                            },
                            want: {
                                Task(priority: .userInitiated) {
                                    try? await model.perform(.want(!item.collection.wanted),on: item)
                                }
                            },
                            destination: SetDetailView(item: item)) {
                                if (compactList) {
                                    CompactSetListCell(set:item)
                                } else {
                                    SetListCell(set:item)
                                }
                            }
                            .padding(.leading,16).padding(.trailing,8)
                    }
                    
                
             
                
            
        }
        .naked
        .refreshable {
            try? await model.fetch(fetchMode)
        }
        
//        .onAppear {
//            Task {
//                try? await model.fetch(fetchMode)
//                print("onAppear")
//            }
//
//        }
        
        .task {
            print("task")
            try? await model.fetch(fetchMode)
            
        }
        
        
    }
    
    
    
    @ViewBuilder func noItems() -> some View {
       switch fetchMode {
       case .search(let search):
           if search.count < 3 {
               Text("Searching...").bold()
           } else {
               Text("sets.noitems").bold()
           }
       default:
           Text("sets.noitems").bold()
       }
    }
    
    
    
}
