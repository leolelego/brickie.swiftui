//
//  LoginView.swift
//  BrickSet
//
//  Created by Work on 01/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @Environment(Model.self) private var model
    @State var username = ""
    @State var password = ""
    @State var error : LocalizedStringKey?
    @State var loading = false
    let loginURL = URL(string:"https://brickset.com/signup")!
    var body: some View {
        VStack(spacing: 16){
            makeImage().offset(y: -80)
            if model.reachability.connection == .unavailable {
                Text("login.offline").font(.headline).bold().foregroundColor(.red)
            } else {
                if !loading {
                    Text("login.howto")
                        .font(.caption)
                        .foregroundColor(.gray).offset(y: -60)
                    makeFields().offset(y: -60)
                    
                }
                makeLoginButton().offset(y:-60)
                if !loading {
                    Text("login.create")
                    //            Link("login.create", destination: loginURL)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(y:-60)
                }
            }
            
            
            if  error != nil && !self.loading {
                VStack{
                    Text(error!).font(.callout).multilineTextAlignment(.center).foregroundColor(.red).lineLimit(10)
                    
                }
            }
            makeFeedback()
            makeBrickSet()
            
        }
        .frame(maxWidth: 375, alignment: .center)
        .padding([.leading, .trailing], 32)
        .modifier(DismissingKeyboardOnSwipe())
        
        
        
    }
    
    func makeImage() -> some View {
        VStack{
            Image("app_logo")
                .padding(20)
                .background(Circle()
                    .fill(Color.white))
                .rotationEffect(Angle(degrees:loading ? 320 : 0))
                .offset(y: loading ? -600 : 0)
                .animation(Animation.interpolatingSpring(stiffness: 170, damping: 5),value: loading)
            Text("login.welcome").bold()
            Text(" BRICKIE ").font(.lego(size: 32)).foregroundColor(.white)
                .padding(.top,4)
                .background(LinearGradient(gradient: Gradient(colors:[Color(red: 0/255, green: 28/255, blue: 200/255), Color(red: 89/255, green: 235/255, blue: 255/255)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
        }
    }
    
    func makeFields() -> some View {
        VStack(alignment: .leading,spacing: 8){
            TextField("login.username", text: $username)
                .textContentType(.username)
                .autocapitalization(.none)
            //                .textCase(.lowercase)
                .disableAutocorrection(true)
            Divider()
            SecureField("login.password", text: $password,prompt: Text("login.password")).textContentType(.password).transition(.move(edge: .bottom))
            Divider()
        }
    }
    
    func makeLoginButton() -> some View{
        Button(action: {
            withAnimation{
                self.loading.toggle()
            }
            Task { @MainActor in
                do {
                                        
                    let hash = try await APIRouter<String>.login(self.username, self.password).responseJSON2()
                    self.model.keychain.user = User(username: self.username, token: hash)
                    print("Login success \(hash)")
                    
 
                } catch(let err) {
                    if  let errApi  = err as? APIError {
                        self.error = errApi.localizedDescription
                    } else {
                        self.error = "error.badlogin"
                    }
                }
                withAnimation{
                    self.loading.toggle()
                }
            }
            
            
        }) {
            Text(loading ? "login.buttonactive" : "login.button")
                .fontWeight(.bold).foregroundColor(.background)
                .frame(minWidth: 0, maxWidth: .infinity)
            
        }.buttonStyle(
            RoundedButtonStyle(backgroundColor:loading ? .indigo : (username.isEmpty || password.isEmpty) ? Color.backgroundAlt.opacity(0.1) : Color.backgroundAlt)
        ).disabled(username.isEmpty || password.isEmpty || loading)
    }
    
    func makeFeedback() -> some View {
        VStack(alignment: .leading, spacing: 0){
            Button(action: {
                UIApplication.shared.open(URL(string: kFeedbackMailto)!)
            }, label: {
                Text("login.feedback").font(.caption)
                    .foregroundColor(.gray)
            })
        }.offset( y: 64)
    }
    func makeBrickSet() -> some View {
        VStack(alignment: .leading, spacing: 0){
            Text("login.powerby").bold().foregroundColor(.backgroundAlt)
            Image("brickset_logo")
        }.offset( y: 64)
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//        //            .previewDevice("iPhone SE")
//            .environmentObject(PreviewStore() as Store)
//            .previewDisplayName("Defaults")
//    }
//}
