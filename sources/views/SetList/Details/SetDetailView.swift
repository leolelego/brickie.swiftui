//
//  SetDetailView.swift
//  BrickSet
//
//  Created by Work on 03/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import SwiftUI
import  SDWebImageSwiftUI
struct SetDetailView: View {

    @Environment(Model.self) private var model
    @Environment(\.dataCache) var cache: DataCache

    var item : SetData
    
    
    
    @State var notes = ""
    @State var isEditing = false
    var body: some View {
        ScrollView( showsIndicators: false){
            makeTop()
            SetEditorView(item: item).padding(.horizontal)
            if item.additionalImages?.count ?? 0 > 0 {
                SetAddtionnalImagesView(images: item.additionalImages!)
            }
            makeInstructions()
      
            makeAddtionnalInfos()
            LinkView(title: "BrickLink", link: "https://www.bricklink.com/v2/catalog/catalogitem.page?S=\(item.number)", color: .cyan)
            makeNotes()
            makeCollections()
            
        }
        .onAppear {
            isEditing = false
        }
        .task {
            if item.instructionsCount > 0 && (item.instrucctions?.count ?? 0) ==  0{
                try? await model.perform(.instructions, on: item)
            }
            
            if item.additionalImages == nil || (item.additionalImages?.count ?? 0) == 0 {
                try? await model.perform(.additionalImages, on: item)
            }
            
            notes = await model.fetchNotes(for: item)
            
        }
        .edgesIgnoringSafeArea(.top)
        
//        .navigationBarTitle("", displayMode: .inline)
        
    }
    
    func makeTop() -> some View {
        Group {
        ThumbnailView(url: item.image.imageURL, minHeight: 300, maxHeight: 600).zIndex(500)
        makeThemes().zIndex(999)
        makeHeader().zIndex(0)
        Divider()
        }
    }
    

    func makeThemes() -> some View{
        HStack(spacing: 8){
            NavigationLink(destination: SetsFilteredView(text: item.theme,filter:.theme,sorter:.newer)) {
                Text( item.theme).roundText
            }
            if item.subtheme != nil {
                NavigationLink(destination: SetsFilteredView(text: item.subtheme!,filter:.subtheme,sorter:.alphabetical)) {
                    Text( item.subtheme!).roundText
                }
            }
            Spacer()
            NavigationLink(destination: SetsFilteredView(text: "\(item.year)",filter:.year)) {
                Text(String(item.year)).roundText
            }
        }.padding(.horizontal)
    }
    func makeHeader() -> some View{
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            TitleView(number: item.number, name: item.name, image: item.image.imageURL)
            
            HStack(alignment: .center){
                Text("\(item.pieces ?? 0)").font(.headline)
                Image.brick(height:26)
                Text("\(item.minifigs ?? 0)").font(.headline)
                Image.minifig_head(height:26)
                Spacer()
                Text("\(item.pricePerPiece ?? "")/p").font(.footnote)
                Text(item.price ?? "").font(.title).bold()
            }
        }.padding(.horizontal)
    }


    func makeInstructions() -> some View{
        Group {
            if item.instrucctions?.first != nil && URL(string:item.instrucctions!.first!.URL) != nil {
                NavigationLink(destination: LegoPDFView(string: item.instrucctions!.first!.URL,cache: cache)) {
                    makeInstructionButton().opacity((cache[URL(string:item.instrucctions!.first!.URL)!] == nil && model.reachability.connection == .unavailable) ?  0.4 : 1.0)
                    
                }.disabled(cache[URL(string:item.instrucctions!.first!.URL)!] == nil && model.reachability.connection == .unavailable)
                    .transition(.fade)
                
            } else {
                EmptyView()
            }
        }
        
    }
    
    func makeAddtionnalInfos() -> some View {
        VStack(alignment: .leading,spacing: 16){
            
            Text("meta.title").font(.title).bold()
            if ((item.ageRange.min) != nil) {
                HStack {
                    Text("meta.age").bold()
                    Spacer()
                    Text("\(item.ageRange.min!)+")
                }
            }
            HStack {
                Text("meta.packaging").bold()
                Spacer()
                Text(item.packagingType)
            }
            if item.hasDimensions {
                HStack {
                    Text("meta.dimensions").bold()
                    Spacer()
                    Text("\(String(format: "%.1f", item.dimensions.width!)) x \(String(format: "%.1f", item.dimensions.height!)) x \(String(format: "%.1f", item.dimensions.depth!))") // \(String(format: "%.1f", set.dimensions!.width!))  x ]
                }
                
            }
            if item.hasWeight {
                HStack {
                    Text("meta.weight").bold()
                    Spacer()
                    Text("\(String(format: "%.1f", item.dimensions.weight!)) kg")
                }
            }
            HStack {
                Text("meta.availability").bold()
                Spacer()
                Text(item.availability)
            }
            RatingView(set: item, editable: false)
            

        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal)
        
    }
   
    func makeCollections() -> some View {
        VStack(alignment: .leading){
            Spacer()
//            if item.collections.ownedBy != nil && item.collections.wantedBy != nil {
//                Text("\(item.collections.ownedBy!) ").font(.callout)+Text("meta.ownedBy").foregroundColor(.secondary).font(.callout)
//                Text("\(item.collections.wantedBy!) ").font(.callout)+Text("meta.wantedBy").foregroundColor(.secondary).font(.callout)
//            } else {
                EmptyView()
//            }
            Spacer(minLength: 50)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal)
    }
    
    
    func makeInstructionButton()-> some View {
        Text("sets.instruction")
            .fontWeight(.bold).foregroundColor(Color.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .mask(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
    
}

extension SetDetailView {
    private func makeNotes() -> some View {
        VStack(alignment: .leading,spacing: 16){
            HStack{Text("notes.title").font(.title).bold()}
            RatingView(set: item, editable: true)
            NotesView(note: $notes){ completionReturn in
                Task {
                    do {
                        try await model.perform(.notes(notes), on: item)
                        completionReturn(true)
                    } catch {
                        completionReturn(false)

                    }
                }

            }
        }
        .padding(.horizontal)
    }



}
#Preview {
    @Previewable var model = Model()
    SetDetailView(item:.previewData)
        .environment(model)

}
