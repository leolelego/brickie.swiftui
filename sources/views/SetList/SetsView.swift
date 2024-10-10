//
//  SetsView.swift
//  Brickie
//
//  Created by Leo on 29/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI


struct SetsView: View {
//    @EnvironmentObject private var  store : Store
    @State var isPresentingScanner = false
    @AppStorage(Settings.setsListSorter) var sorter : LegoListSorter = .default

    
    var body: some View {
//        VStack(alignment: .leading, spacing: 8){
//            SetsListView()
////            .searchable(text: $store.searchSetsText,
////                        prompt: searchPlaceholder()) 
//               
//            .disableAutocorrection(true)
//        }
        SetsListView(fetchMode: .ownedSets, sorter:$sorter)
        .sheet(isPresented: $isPresentingScanner) {
            makeScanner()
        }
//        .toolbar{
//
//                Button(action: {
//                    isPresentingScanner.toggle()
//                }, label: {
//                    Image(systemName: "barcode.viewfinder")
//                })
//
//            
//        }
    }
    
    func makeScanner() -> some View{
        NavigationStack{
            CodeScannerView(codeTypes: [.ean8, .ean13,.upce, .pdf417], completion: self.handleScan)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button {
                            self.isPresentingScanner.toggle()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }).navigationBarTitle("", displayMode: .inline)
            
        }
        .accentColor(.backgroundAlt)
    }
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isPresentingScanner.toggle()
        
        switch result {
        case .success(let code):
            var theCode = code
            if code.first == "0"{
                theCode.removeFirst()
            }
            //store.searchSetsText = theCode
        case .failure(let error):
            logerror(error)
        }
    }
    
//    fileprivate func searchPlaceholder() -> LocalizedStringKey{
//        return filter == .wanted ?
//            "search.placeholderwanted" :
//            config.connection == .unavailable ?
//                "search.placeholderoffline":"search.placeholder"
//        
//    }

    
}

//struct SetsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SinglePanelView(item: AppPanel.sets,
//                        view: AnyView(SetsView()),
//                        toolbar: AppRootView().toolbar() )
//            .environmentObject(PreviewStore() as Store)
//            .environmentObject(Configuration())
//    }
//}




