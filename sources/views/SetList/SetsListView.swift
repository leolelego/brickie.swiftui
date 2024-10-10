//
//  SetsListView.swift
//  BrickSet
//
//  Created by Work on 18/05/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import SwiftData
struct SetsListView: View {
    @Environment(Model.self) private var model
    @Environment(\.modelContext) private var modelContext
    @Query() //filter: #Predicate<SetData>{set in set.collection.owned == true}
    private var sets: [SetData]
    let fetchMode : Model.FetchAction
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    @Binding var sorter : LegoListSorter
    @State var searchFilter : [LegoListSorter:String] = [:]

    @AppStorage(Settings.compactList) var compactList : Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                ForEach(Array(searchFilter.keys)) { key in
                    Button(action: {
                        withAnimation {
                            searchFilter[key] = nil
                        }
                    }, label: {
                        (Text(searchFilter[key] ?? "" + " ") + Text(Image(systemName: "xmark"))).roundText
                    })
                }
            }
     
            
                
            
            if sets.count == 0 {
                TrySyncView(count: sets.filter({$0.collection.owned}).count)
            } else {
                if horizontalSizeClass == . compact || compactList {
                    List{
                        
                        ForEach(sections(for:  setsToShow ),id: \.self){ theme in
                            if theme == "" {
                                sectionListView(theme: theme)
                            } else {
                                Section(header:
                                            
                                            Button(action: { withAnimation{ searchFilter[sorter] = theme}}, label: {
                                    Text(theme).roundText
                                        .padding(.leading, -12)
                                        .padding(.bottom, -26)
                                })
                                        
                                ){
                                    sectionListView(theme: theme)
                                    
                                }
                            }
                            
                        }
                    }
                    .naked
                    .refreshable {
                            try? await model.fetch(fetchMode)
                        
                    }
                } else { // iPad double list
                    ScrollView{
                        LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                            ForEach(sections(for:  setsToShow ), id: \.self){ theme in
                                Section(header:
                                            
                                            Button(action: {withAnimation {searchFilter[sorter] = theme}}, label: {
                                            Text(theme).roundText
                                                .padding(.leading, 4)
                                                .padding(.bottom, -26)

                                        })
                                ) {
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                                        sectionView(theme: theme)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
                try? await model.fetch(fetchMode)
            
        }
        .toolbar {
            
            FilterSorterMenu( sorter: $sorter, searchFilter: $searchFilter, searchFilterEnabled: true, sorterAvailable: [.default,.alphabetical,.number,.older,.newer,.piece,.pieceDesc,.price,.priceDesc,.pricePerPiece,.pricePerPieceDesc])
        }
  
    }
    
    func sectionView(theme:String) -> some View{
        ForEach(self.items(for: theme, items: sets ), id: \.setID) { item in
            NavigationLink(destination: SetDetailView(item: item)) {
                SetListCell(set:item)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.leading,16).padding(.trailing,8)
            .contextMenu {
                CellContextMenu(owned: item.collection.qtyOwned, wanted: item.collection.wanted) {
                    Task(priority: .userInitiated) {
                        try? await model.perform(.qty(item.collection.qtyOwned+1),on: item)
                    }
                } remove: {
                    Task(priority: .userInitiated) {
                        try? await model.perform(.qty(item.collection.qtyOwned-1),on: item)
                    }
                } want: {
                    Task(priority: .userInitiated) {
                        try? await model.perform(.want(!item.collection.wanted),on: item)
                    }
                }
            }
            
        }
    }
    
    func sectionListView(theme:String) -> some View{
        ForEach(items(for: theme, items: sets ), id: \.setID) { item in
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
    
    func sections(for items:[SetData]) -> [String] {
        
        switch sorter {
        case .number,.piece,.price,.pieceDesc,.priceDesc,.pricePerPiece,.pricePerPieceDesc:
            return [""]
        case .alphabetical:
            return Array(Set(items.compactMap({String($0.name.prefix(1))}))).sorted()
        case .older:
            return Array(Set(items.compactMap({"\($0.year)"}))).sorted()
        case .newer:
            return Array(Set(items.compactMap({"\($0.year)"}))).sorted(by: {$0 > $1})
        default:
            return Array(Set(items.compactMap({$0.theme}))).sorted()
        }
    }
    func items(for section:String,items:[SetData]) -> [SetData] {
        switch sorter {
        case .number:
            return items.sorted(by: {Int($0.number) ?? 0 < Int($1.number) ?? 0})
        case .piece:
            return items.sorted(by: {$0.pieces ?? 0 < $1.pieces ?? 0})
        case .pieceDesc:
            return items.sorted(by: {$0.pieces ?? 0 > $1.pieces ?? 0})
        case .price:
            return items.sorted(by: {$0.priceFloat  < $1.priceFloat})
        case .priceDesc:
            return items.sorted(by: {$0.priceFloat  > $1.priceFloat})
        case .pricePerPiece:
            return items.sorted(by: {$0.pricePerPieceFloat  < $1.pricePerPieceFloat})
        case .pricePerPieceDesc:
            return items.sorted(by: {$0.pricePerPieceFloat  > $1.pricePerPieceFloat})
        case .alphabetical:
            return items.filter({String($0.name.prefix(1)) == section}).sorted(by: {$0.name < $1.name})
        case .older,.newer:
            return items.filter({"\($0.year)" == section}).sorted(by: {$0.name < $1.name})
        default:
            return items.filter({$0.theme == section}).sorted(by: {$0.name < $1.name})
        }
    }
    
    var setsToShow : [SetData] {
        return searchFilter.count > 0  ?  searchFilteredSets(sets) : sets
    }
    
    func searchFilteredSets(_ sets:[SetData]) -> [SetData] {
        var filtered = sets
        
        for (key,value) in searchFilter{
            switch key {
            case .alphabetical:
                filtered = filtered.filter({String($0.name.prefix(1)) == value})
            case .older,.newer:
                filtered =  filtered.filter({"\($0.year)" == value})
            default:
                filtered =  filtered.filter({$0.theme == value})
            }
        }

        return filtered
    }
    
    
}
