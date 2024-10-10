//
//  SorterFilterView.swift
//  Brickie
//
//  Created by Work on 08/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI

struct FilterSorterMenu : View {
    @Binding var sorter : LegoListSorter
    @Binding var searchFilter : [LegoListSorter:String]
    var searchFilterEnabled : Bool
    var sorterAvailable : [LegoListSorter]
    var body : some View {
        Menu {
            Section(header: Text("menu.filter")) {
                if searchFilterEnabled{
                    Menu("filter.year"){
                        ForEach((1949...thisYear).reversed(), id: \.self) { y in
                            Button("\(y)"){
                                withAnimation{ searchFilter[.newer] = "\(y)"}
                            }
                        }
                    }
                    Menu("filter.theme"){
//                        ForEach(store.themes) { theme in
//                            Button(theme.theme){
//                                withAnimation{ searchFilter[.default] = theme.theme}
//                            }
//                        }
                    }
                }
                
            }
            Section(header: Text("menu.order")) {
                Picker(selection: $sorter, label: Text("Sorting")) {
                    ForEach(sorterAvailable, id: \.self) { item in
                        HStack{
                            Image(systemName:item.systemImage)
                            Text(item.local)
                        }.tag(item)
                        
                    }
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3.circle").modifier(BarButtonModifier())
        }
    }
}
