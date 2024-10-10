//
//  Keychain.swift
//  Brickie
//
//  Created by Léo on 09/10/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import KeychainSwift
import SDWebImage
@Observable
class Keychain {
    
    let keychain = KeychainSwift()
    struct Key {
        static let username = "username"
        static let token = "token"
    }
    var user : User? {
        didSet{
            guard let u = user else  {
                keychain.delete(Key.username)
                keychain.delete(Key.token)
                wipe()
                return
            }
            keychain.set(u.username, forKey: Key.username)
            keychain.set(u.token, forKey: Key.token)
            
        }
    }
    init(){
        if let username = keychain.get(Key.username), let hash = keychain.get(Key.token){
            self.user = User(username: username, token: hash)
        }
    }
    
    func wipe(){
        PersistentData().free()
        DataCache().free()
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
        
    }
}
