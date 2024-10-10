//
//  MinifigDetailView.swift
//  BrickSet
//
//  Created by Work on 19/05/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
struct MinifigDetailView: View {
    @EnvironmentObject private var  store : Store
    
    @ObservedObject var minifig : LegoMinifig
    @State var isImageDetailPresented : Bool = false
    @State var notes = ""
    var body: some View {
        ScrollView( showsIndicators: false){
            ThumbnailView(url: minifig.imageUrl, minHeight: 300, maxHeight: 300).zIndex(80)
            makeThemes().zIndex(999)
            Spacer()
            makeHeader().zIndex(0)
            Divider()
            MinifigEditorView(minifig: minifig).padding()
            LinkView(title: "BrickLink", link: "https://www.bricklink.com/v2/catalog/catalogitem.page?M=\(minifig.minifigNumber)", color: .cyan)
            makeNotes()
            
            
        }
//        .sheet(isPresented: $isImageDetailPresented, content: { FullScreenImageView(isPresented: $isImageDetailPresented, urls: .constant([minifig.imageUrl]), currentIndex: .constant(1))})
//        
        .navigationBarTitle("", displayMode: .inline)
        
        .task {
             loadNotes()
        }
        
    }
    private func makeThemes() -> some View{
        
        HStack(spacing: 8){
            
            NavigationLink(destination: MinifigFilteredView(theme: minifig.theme, filter: .theme)) {
                Text(  minifig.theme).roundText
            }
            ForEach(minifig.subthemes, id: \.self){ sub in
                NavigationLink(destination: MinifigFilteredView(theme: sub, filter: .subtheme)) {
                    Text(sub).roundText
                }
            }
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
        
    }
    private func makeHeader() -> some View{
        VStack(alignment: .center, spacing: 8) {
            TitleView(number: minifig.minifigNumber.uppercased(), name: minifig.nameUI, image: minifig.imageUrl)
            
            ForEach(minifig.subNames, id: \.self){ sub in
                Text(sub).font(.subheadline)
            }
        }.padding(.horizontal)
            .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
    }
    
    
}

extension MinifigDetailView {
    private func makeNotes() -> some View {
        VStack(alignment: .leading,spacing: 16){
            HStack{Text("notes.title").font(.title).bold()}
            NotesView(note: $notes){ completionReturn in
                saveNotes { status in
                    completionReturn(status)
                }
            }
            Spacer(minLength: 50)
        }
        .padding(.horizontal)
        
    }
    private func saveNotes(completion: @escaping (Bool)->Void){
        
        Task {
            let response = try? await APIRouter<String>.minifigNotes(store.user!.token, minifig.minifigNumber, notes).responseJSON2()
            completion(response != nil)
        }
        
//        APIRouter<String>.minifigNotes(store.user!.token, minifig, notes)
//            .responseJSON { response in
//                switch response {
//                case .failure:
//                    completion(false)
//                    break
//                case .success:
//                    completion(true)
//                    break
//                }
//            }
        
    }
    private func loadNotes() {
        self.notes = minifig.notes ?? ""
        
        
         APIRouter<[[String:Any]]>.getMinifigNotes(store.user!.token).decode(ofType: [MinigifNote].self){ response in
            switch response {
            case .success(let notes):
                minifig.notes = notes.first(where: { $0.minifigNumber == minifig.minifigNumber})?.notes ?? ""
                self.notes = minifig.notes ?? ""
                break
            case .failure(_):
                break
            }
            
        }
    }
}
