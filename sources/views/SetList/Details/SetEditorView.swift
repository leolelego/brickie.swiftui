//
//  CollectionItemView.swift
//  BrickSet
//
//  Created by Work on 09/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import SwiftUI

struct SetEditorView: View {
    @Environment(Model.self) private var model
    
    var item : SetData
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack{
            HStack(spacing: 16){
                Button(action: {
                    switchWanted()
                }) {
                    HStack(alignment: .lastTextBaseline) {
                        
                        Image(systemName: item.collection.wanted ? "heart.fill" : "heart").foregroundColor(.white).font(.headline)
                        Text("collection.want").fontWeight(.bold)
                        
                    }
                    
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 24)
                }.buttonStyle(RoundedButtonStyle(backgroundColor: .pink  )).opacity(canEdit() ? 0.6: 1.0)
                
                if item.collection.owned {
                    Button(action: {
                        set(qty: item.collection.qtyOwned-1)
                    }) {
                        Image(systemName: "minus").foregroundColor(.background).font(.title)
                            .frame(minHeight: 24, alignment: .center)
                        
                    }.buttonStyle(RoundedButtonStyle(backgroundColor:.backgroundAlt)).opacity(canEdit() ? 0.6 : 1.0)
                    
                    Text("\(item.collection.qtyOwned)").font(.title).bold()
                    Button(action: {
                        set(qty: item.collection.qtyOwned+1)
                    }) {
                        Image(systemName: "plus").foregroundColor(.background).font(.title)
                            .frame(minHeight: 24, alignment: .center)
                        
                    }.buttonStyle(RoundedButtonStyle(backgroundColor:.backgroundAlt)).opacity(canEdit() ? 0.6 : 1.0)
                } else {
                    Button(action: {
                        set(qty: 1)

                    }) {
                        Text("collection.add")
                            .fontWeight(.bold).foregroundColor(.background)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.buttonStyle(RoundedButtonStyle(backgroundColor:.backgroundAlt)).opacity(canEdit() ? 0.8 : 1.0)
                }
            }
            
            if model.reachability.connection == .unavailable {
                Text("message.offline").font(.headline).bold().foregroundColor(.red)
            }
//            } else {
//                APIIssueView(error: $store.error)
//            }
            
        }
        
        
    }
    
    func switchWanted(){
        Task {
            do {
                try await model.perform(.want(!item.collection.wanted), on: item)
                generator.notificationOccurred(.success)
            } catch {
                generator.notificationOccurred(.error)
            }
        }
    }
    
    func set(qty:Int) {
        Task {
            do {
                try await model.perform(.qty(qty), on: item)
                generator.notificationOccurred(.success)
            } catch {
                generator.notificationOccurred(.error)
            }
        }
    }
    func canEdit() -> Bool {
        return model.reachability.connection == .unavailable
    }
}

