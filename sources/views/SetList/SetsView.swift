//
//  SetsView.swift
//  Brickie
//
//  Created by Leo on 29/11/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import Combine

struct SetsView: View {
    @Environment(Model.self) private var model
    @State var isPresentingScanner = false
    @State private var currentIndex : Int = 2
    @State private var sortOrder = SetData.SortDescriptorProvider.alphabetical
//    @State private var searchText : String = ""
    @State private var isLoading: Bool = false
    @StateObject private var searchText = DebouncedString()
    @State private var searchString = ""
    var body: some View {
//        VStack(alignment: .leading, spacing: 8){
//            SetsListView()
////            .searchable(text: $store.searchSetsText,
////                        prompt: searchPlaceholder()) 
//               
//            .disableAutocorrection(true)
//        }
        TabView(selection: $currentIndex) {
            SetsListView2(fetchMode: .ownedSets,sortOrder: sortOrder.sortDescriptors).tag(0).toolbar(.hidden, for: .tabBar)
            SetsListView2(fetchMode: .wantedSets,sortOrder: sortOrder.sortDescriptors).tag(1).toolbar(.hidden, for: .tabBar)
            SetsListView2(fetchMode: .search(searchText.debouncedValue),sortOrder: SetData.SortDescriptorProvider.alphabetical.sortDescriptors)
           //atman Text(searchText.debouncedValue)
                .searchable(text: $searchText.value,isPresented: .constant(true))
                .onChange(of: searchText.debouncedValue) {
                    Task {
                        try? await model.fetch(.search(searchText.debouncedValue))
                    }
                }
                .tag(2).toolbar(.hidden, for: .tabBar)
        }
        .background(.red)
        
        /*.tabViewStyle(.tabBarOnly)*/ //(indexDisplayMode: .never)
        //.gesture(DragGesture().onChanged { _ in })
        .sheet(isPresented: $isPresentingScanner) {
            makeScanner()
        }
        .toolbar {
            Menu {
                Picker(selection: $sortOrder, label: Text("Sorting")) {
                    ForEach(SetData.SortDescriptorProvider.allCases) { item in
                        HStack{
                            Image(systemName:item.systemImage)
                            Text(item.local)
                            if item == sortOrder {
                                Image(systemName:"checkmark")

                            }
                        }.tag(item)
                        
                    }
                }
                    } label: {
                        Label("Sort", systemImage: "arrow.left.arrow.right")
                    }
        }
    }
//    
//    @ViewBuilder func SearchView() -> some View{
////        Group {
////            if isLoading {
////                SetsListView2(fetchMode: .search(searchText),sortOrder: SetData.SortDescriptorProvider.alphabetical.sortDescriptors)
////                    .redacted(reason: .placeholder)
////            } else {
//                SetsListView2(fetchMode: .search(searchText),sortOrder: SetData.SortDescriptorProvider.alphabetical.sortDescriptors)
////            }
////                
////        
////        }
//            .searchable(text: $searchText,isPresented: .constant(true))
////            .onChange(of: searchText, {
////                searchAction()
////            })
//    }
//    func searchAction() {
//        print("Search for \(searchText)")
//        searchCancellable?.cancel()
//        withAnimation {
//            isLoading = true
//        }
//       
//        searchCancellable = Just(searchText)
//            .delay(for: .milliseconds(850), scheduler: DispatchQueue.main)
//            .sink { searchQuery in
//                print("Debounced \(searchQuery)")
//                Task {
//                   
//                   // try? await model.fetch(.search(searchText))
//                    withAnimation {
//                        isLoading = false
//
//                    }
//                }
//                
//            }
//        searchCancellable = searchText.publisher
//        
//                    .debounce(for: .milliseconds(3), scheduler: DispatchQueue.main)
//                    .removeDuplicates()
//                    .sink { debouncedText in
//                        print("Debounced")
//
//                        Task {
//                            print("Debounced 2")
//                            try? await model.fetch(.search(searchText))
//                        }
//                    }
  
//    }
    
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
//        return model.reachability.connection == .unavailable ? "search.placeholderoffline":"search.placeholder"
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




