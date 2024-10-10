//
//  WelcomeView.swift
//  Brickie
//
//  Created by Léo on 07/02/2022.
//  Copyright © 2022 Homework. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    let showContinu : Bool
    @State var more = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading,spacing: 16){
                VStack(alignment: .leading, spacing: -8) {
                    Text("wlcm.header").bold().scaledToFill().font(.system(size: 44, weight: .heavy, design: .default)) 

                    Text("Brickie").bold().font(.system(size: 40, weight: .heavy, design: .default))
                        .foreground(LinearGradient.blueBlue)
                }
                
                
                Text("wlcm.subheader").font(.body)
               
                Spacer(minLength: 24)
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(WelcomeEnum.allCases,id:\.self){ i in
                        WelcomeItemView(value: i)
                    }
                }.padding(.horizontal)
                Spacer()
                
            }.padding()
            if more || !showContinu {
                Text("wlcm.more").font(.system(.callout, design: .monospaced))
                    
                    .foregroundColor(.secondary).padding()
            } else {
                Button("wlcm.morebtn"){
                    withAnimation {
                        more = true
                    }
                }.font(.callout)
            }
            if showContinu {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("wlcm.btn").bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                })
                    .buttonStyle(RoundedButtonStyle(backgroundColor:.blue))
                    .padding(.horizontal)
                Text("wlcm.needbrickset").font(.footnote).foregroundColor(.secondary).padding(32)
            }
            Spacer()
            
        }.padding(.horizontal)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(showContinu: true).previewDevice("iPhone SE")
                .environment(\.locale, .init(identifier: "fr"))
        }
    }
}
// MARK: - API
extension View {
    public func foreground<Overlay: View>(_ overlay: Overlay) -> some View {
        self.overlay(overlay).mask(self)
    }
}
