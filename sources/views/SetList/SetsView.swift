//
//  SetsView.swift
//  Brickie
//
//  Created by Leo on 29/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI

struct SetsView: View {
    @EnvironmentObject private var  store : Store
    @EnvironmentObject var config : Configuration
    @State var filter : LegoListFilter = .all
    @AppStorage(Settings.setsListSorter) var sorter : LegoListSorter = .default
    @State var isPresentingScanenr = false
    
 
    
    var body: some View {
        ScrollView {
            APIIssueView(error: $store.error)
            SetsListView(items: store.mainSets,sorter:$sorter,filter: $filter)
            //footer()
        }
        .searchable(text: $store.searchSetsText,
                    prompt:config.connection == .unavailable ? "search.placeholderoffline":"search.placeholder")
        .disableAutocorrection(true)
        .sheet(isPresented: $isPresentingScanenr) {
            CodeScannerView(codeTypes: [.ean8, .ean13, .pdf417], completion: self.handleScan)
        }
        .toolbar{
            
            ToolbarItemGroup(placement: .navigationBarTrailing){
                if store.isLoadingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    EmptyView()
                }
                FilterSorterMenu(sorter: $sorter,
                                 filter: $filter,
                                 sorterAvailable: [.default,.alphabetical,.number,.older,.newer,.piece,.pieceDesc,.price,.priceDesc],
                                 filterAvailable: store.searchSetsText.isEmpty ? [.all,.wanted] : [.all,.wanted,.owned]
                )
//                if store.error == nil {
                    Button(action: {
                        isPresentingScanenr.toggle()
                    }, label: {
                        Image(systemName: "barcode.viewfinder")
                    })
//                }
                
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isPresentingScanenr.toggle()
        
        switch result {
        case .success(let code):
            store.searchSetsText = code
        case .failure(let error):
            logerror(error)
        }
    }
    
    fileprivate func footer() -> some View{
        VStack(){
            Spacer(minLength: 16)
            HStack{
                Spacer()
                Text(String(store.sets.qtyOwned)+" ").font(.lego(size: 20))
                Image.brick
                Spacer()
            }
            Spacer(minLength: 16)
        }
    
    }
    
}







