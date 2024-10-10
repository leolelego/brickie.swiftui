//
//  Store.swift
//  BrickSet
//
//  Created by Work on 03/05/2020.
//  Copyright © 2020 LEOLELEGO. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import KeychainSwift
import Reachability
import SDWebImage

class Store : ObservableObject{
    
    static let singleton = Store()
    let keychain = KeychainSwift()
    
    @Published private(set) var sets = [LegoSet]()
    @Published private(set) var minifigs = [LegoMinifig]()
    @Published private(set) var themes = [LegoTheme]()
    @Published private(set) var subthemes = [LegoTheme.Subtheme]()
    @Published var searchSetsText = ""
    private var searchSetsCancellable: AnyCancellable?
    @Published var searchMinifigsText = ""
    private var searchMinifigsCancellable: AnyCancellable?
    private var syncronizeCancellable: AnyCancellable?
    @Published var requestForSync : Bool = false
    @Published var isLoadingData : Bool = true
    @Published var error : APIError? = nil
    var lastsync = Date()
    @Published var user : User? {
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
    
    
    struct Key {
        static let username = "username"
        static let token = "token"
        
        static let setsBackupURL = URL(string: "sets.json")!
        static let figsBackupURL = URL(string: "minigures.json")!
        static let themesBackupURL = URL(string: "themes.json")!
        static let subthemesBackupURL = URL(string: "subthemes.json")!
        
    }
    
    enum SearchFilter {
        case none
        case theme
        case subtheme
        case year
    }
    
    init(preview: Bool) {
        commonInit(preview:preview)
    }
    
    init() {
        commonInit(preview:false)
    }
    
    func commonInit(preview: Bool) {
        if let username = keychain.get(Key.username), let hash = keychain.get(Key.token){
            self.user = User(username: username, token: hash)
        }
        if (!preview) {
            loadFromBack()
        }
        searchSetsCancellable = $searchSetsText
            .debounce(for: .milliseconds(850), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink{  _ in
                guard !self.searchSetsText.isEmpty else {self.setsFilter = .owned;return}
                if self.searchSetsText.count > 2 {
                    self.searchSets(text: self.searchSetsText, by: .none)
                }
                self.setsFilter = .search(self.searchSetsText)
                
                
            }
        
        searchMinifigsCancellable = $searchMinifigsText
            .debounce(for: .milliseconds(850), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink{  _ in
                guard !self.searchMinifigsText.isEmpty else {self.minifigFilter = .owned;return}
                if self.searchMinifigsText.count > 2 {
                    self.searchMinifigs(text: self.searchMinifigsText)
                }
                self.minifigFilter = .search(self.searchMinifigsText)
                
            }
        
        syncronizeCancellable = $requestForSync
            .filter{ $0 }
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { _ in
                self.sync()
                self.backup()
            }
        
        requestForSync = self.user != nil
        
        self.getThemes()
        
    }

    func getThemes(){
        APIRouter<[[String:Any]]>.themes.decode(ofType: [LegoTheme].self) { response in
            switch response {
            case .success(let data):
                self.themes = data

//                
                break
            case .failure:
                log("Themes Load failed")
                break
            }
        }
    }
    enum Filter : Equatable{
        case owned
        case search(String)
    }
    
    var setsFilter : Filter = .owned {
        didSet{
            objectWillChange.send()
        }
    }
    var minifigFilter : Filter = .owned {
        didSet{
            objectWillChange.send()
        }
    }
    
    var mainSets : [LegoSet] {
        switch setsFilter {
        case .owned:
            return sets.filter({$0.collection.owned})
        case .search(let str):
            return sets.filter({$0.match(str)})
        }
    }
    
    var minifigsUI : [LegoMinifig] {
        switch minifigFilter {
        case .owned:
            return minifigs.filter({$0.ownedTotal > 0})
        case .search(let str):
            return minifigs.filter({$0.match(str)})
        }
    }
    
    enum Action {
        case want(Bool)
        case qty(Int)
        
        
        func query(obj:LegoSet,user:User?,completion: @escaping (Result<String,Error>) -> Void){
            guard let token = user?.token else {return}
            
            switch self {
            case .want(let wanted):
                APIRouter<String>.setWanted(token, obj.setID, wanted).responseJSON(completion: completion)
                break
            case .qty(let q):
                APIRouter<String>.setQty(token, obj.setID, q).responseJSON(completion: completion)
                break
            }
        }
        func query(obj:LegoMinifig,user:User?,completion: @escaping (Result<String,Error>) -> Void){
            guard let token = user?.token else {return}
            
            switch self {
            case .want(let wanted):
                APIRouter<String>.minifigWanted(token, obj.minifigNumber, wanted,obj.ownedLoose).responseJSON(completion: completion)
                break
            case .qty(let q):
                APIRouter<String>.minifigQty(token, obj.minifigNumber, q,obj.wanted).responseJSON(completion: completion)
                break
            }
        }
        
        func manage(obj:LegoSet,store:Store){
            DispatchQueue.main.async {
                obj.objectWillChange.send()
                store.objectWillChange.send()
                
                switch self {
                case .want(let wanted):
                    obj.collection.wanted = wanted
                    break
                case .qty(let q):
                    obj.collection.qtyOwned = q
                    obj.collection.owned = q > 0
                    break
                }
            }
        }
        
        func manage(obj:LegoMinifig,store:Store){
            DispatchQueue.main.async {
                obj.objectWillChange.send()
                store.objectWillChange.send()
                
                switch self {
                case .want(let wanted):
                    obj.wanted = wanted
                    break
                case .qty(let q):
                    obj.ownedLoose = q
                    obj.ownedTotal = q + obj.ownedInSets
                    break
                }
            }
        }
        
    }
    
    func fireApiError(_ err:Error){
        DispatchQueue.main.async {
            self.isLoadingData = false
        }
        if (err as NSError).code != -1009 {
            DispatchQueue.main.async{
                self.error = (err as? APIError) ?? APIError.unknown
                if self.error == .invalidUserHash {
                    self.user = nil
                    self.reset()
                    self.error = nil
                }
            }
        }
    }
    var alert: Alert {
        Alert(title:Text("apierror.title"), message: Text(error?.localizedDescription ?? "error.noapiresponse"), dismissButton: .default(Text("Ok")){
            DispatchQueue.main.async {
                //                self.asError = false
                self.isLoadingData = false
            }
            
        }
        )
    }
    
}

// MARK: Call for Figs

extension Store {
    
    
    func append(_ new:[LegoMinifig]){
        var toAppend = [LegoMinifig]()
        let u = Array(Set(new))
        
        for fig in u {
            if let idx  = self.minifigs.firstIndex(of: fig){
                DispatchQueue.main.async {
                    self.minifigs[idx].update(from: fig)
                }
            } else {
                toAppend.append(fig)
            }
        }
        self.objectWillChange.send()
        self.minifigs.append(contentsOf: toAppend)
    }
    
    // Remove set taht are NOT wanted
    func updateWanted(with wanted:[LegoMinifig]){
        DispatchQueue.main.async {
            self.objectWillChange.send()
            for item in self.minifigs {
                item.wanted = wanted.contains(item)
            }
            self.append(wanted)
        }
        
        
        let urls = wanted.compactMap { return URL(string:$0.imageUrl) }
        fetchImages(urls)
    }
    func updateOwned(with owned:[LegoMinifig]){
        
        DispatchQueue.main.async {
            for item in self.minifigs {
                let dbItem = owned.first(where: {$0 == item})
                item.ownedLoose = dbItem?.ownedLoose ?? 0
                item.ownedInSets = dbItem?.ownedLoose ?? 0
                item.ownedTotal = dbItem?.ownedLoose ?? 0
            }
            self.append(owned)
        }
        
        let urls = owned.compactMap { return URL(string:$0.imageUrl) }
        fetchImages(urls)
        
    }
    
    func searchMinifigs(text:String){
        guard let token = user?.token else {return}
        DispatchQueue.main.async { self.isLoadingData = true}
        APIRouter<[[String:Any]]>.searchMinifigs(token, text).decode(ofType: [LegoMinifig].self) {response in
            switch response {
            case .success(let sets):
                DispatchQueue.main.async {
                    self.append(sets)
                    self.isLoadingData = false
                }
                break
            case .failure(let err):
                self.fireApiError(err)
                break
            }
            
            
        }
        
    }
    
    func action(_ action:Action,on item:LegoMinifig){
        
        action.query(obj: item,user:user) { res in
            let generator = UINotificationFeedbackGenerator()

            switch res {
            case .success:
                action.manage(obj: item,store:self)
                generator.notificationOccurred(.success)
                self.backup()

                break
            default:
                generator.notificationOccurred(.error)

                break
            }
            
        }
    }
}
// MARK: Call for Sets
extension Store {
    func append(_ new:[LegoSet]){
        // This should be called in main thread
        
        var toAppend = [LegoSet]()
        let unique = Array(Set(new))
        
        for set in unique {
            if let idx = sets.firstIndex(of: set){
                DispatchQueue.main.async {
                    self.sets[idx].update(from: set)
                }
            } else {
                toAppend.append(set)
            }
        }
        self.objectWillChange.send()
        self.sets.append(contentsOf: toAppend)
        
        
        
        
        
    }
    
    // Remove set taht are NOT wanted
    func updateWanted(with wanted:[LegoSet]){
        DispatchQueue.main.async {
            self.objectWillChange.send()
            for set in self.sets {
                set.collection.wanted = wanted.contains(set)
            }
            self.append(wanted)
            
        }
        let urls = wanted.compactMap { return $0.image.thumbnailURL != nil ? URL(string:$0.image.thumbnailURL!) : nil }
        fetchImages(urls)
        
    }
    func updateOwned(with owned:[LegoSet]){
//        for set in self.sets {
//            let owned = owned.contains(set)
//            DispatchQueue.main.async {
//                set.objectWillChange.send()
//                set.collection.owned = owned
//                if owned == false {
//                    set.collection.qtyOwned = 0
//                }
//            }
//        }
//        self.append(owned)
//        DispatchQueue.main.async {
//            
//            self.isLoadingData = false
//        }
//        
//        let urls = owned.compactMap { return $0.image.thumbnailURL != nil ? URL(string:$0.image.thumbnailURL!) : nil }
//        fetchImages(urls)
        
    }
    
    
    private func sync() {
        guard let token = user?.token  else {return}
        
        DispatchQueue.main.async {
            self.isLoadingData = true
            
        }
        func ownedSets(page:Int,  incrmentatl_sets:  [LegoSet]){
            APIRouter<[[String:Any]]>.ownedSets(token,page).decode(ofType: [LegoSet].self) { response in
                switch response {
                case .success(let sets):
                    var sets2 = incrmentatl_sets
                    sets2.append(contentsOf: sets)
                    if sets .count >= pageSizeSet {
                        ownedSets(page: page+1,incrmentatl_sets:sets2)
                    } else {
                        self.updateOwned(with: sets2)
                    }
                    break
                case .failure(let err):
                    
                    self.fireApiError(err)
                    break
                }
            }
        }
        
 
        func wantedSets(page:Int,  incrmentatl_sets:  [LegoSet]){
            APIRouter<[[String:Any]]>.wantedSets(token,page).decode(ofType: [LegoSet].self) {
                response in
                switch response {
                case .success(let sets):
                    
                    var sets2 = incrmentatl_sets
                    sets2.append(contentsOf: sets)
                    if sets .count >= pageSizeSet {
                        wantedSets(page: page+1,incrmentatl_sets:sets2)
                    } else {
                        self.updateWanted(with: sets)
                    }
                    break
                case .failure(let err):
                    self.fireApiError(err)
                    break
                }
            }
        }
        ownedSets(page: 1,incrmentatl_sets: [LegoSet]())
        wantedSets(page: 1,incrmentatl_sets: [LegoSet]())
        
        APIRouter<[[String:Any]]>.ownedFigs(token).decode(ofType: [LegoMinifig].self) { response in
            switch response {
            case .success(let items):
                self.updateOwned(with: items)
                
                break
            case .failure(let err):
                self.fireApiError(err)
                break
            }
            
        }
        APIRouter<[[String:Any]]>.wantedFigs(token).decode(ofType: [LegoMinifig].self) { response in
            switch response {
            case .success(let items):
                self.updateWanted(with: items)
                break
            case .failure(let err):
                self.fireApiError(err)
                break
            }
        }
        
    }
    func searchSets(text:String,by filter:SearchFilter,completion: (([LegoSet]) -> Void)? = nil){
        guard let token = user?.token, try! Reachability().connection != . unavailable else {return }
        
        
        func search(page:Int){
            
            let request : APIRouter<[[String : Any]]>
            switch filter {
            case .none:
                request = APIRouter<[[String:Any]]>.searchSets(token, text,page)
            case .theme:
                request = APIRouter<[[String:Any]]>.searchSetsTheme(token, text,page)
            case .subtheme:
                request = APIRouter<[[String:Any]]>.searchSetsSubTheme(token, text,page)
            case .year:
                request = APIRouter<[[String:Any]]>.searchSetsYear(token, text,page)
            }
            DispatchQueue.main.async {self.isLoadingData = true}
            request.decode(ofType: [LegoSet].self) { response in
                switch response {
                case .success(let sets):
                    completion?(sets)
                    if sets .count >= pageSizeSearch {
                        search(page: page+1)
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.append(sets)
                    }
                    
                    DispatchQueue.main.async {
                        self.isLoadingData = false
                    }
                    break
                case .failure(let err):
                    self.fireApiError(err)
                    break
                }
                
                
            }
        }
        search(page: 1)
    }
    
    func action(_ action:Action,on item:LegoSet){
        action.query(obj: item,user:user) { res in
            let generator = UINotificationFeedbackGenerator()

            switch res {
            case .success:
                action.manage(obj: item,store: self)
                generator.notificationOccurred(.success)

                self.backup()
                break
            default:
                generator.notificationOccurred(.error)
                break
            }
        }
    }
    
}

extension Array where  Element:LegoMinifig {
    var qtyOwned : Int {
        let v = self.compactMap { return $0.ownedTotal}.reduce(0, +)
        
        return v
    }
}

extension Store {
    func backup(){
        do {
            var persistance = PersistentData()
            let setsData = try JSONEncoder().encode(sets)
            let figsData = try JSONEncoder().encode(minifigs)
            //let themesData = try JSONEncoder().encode(themes)
            //let subthemesData = try JSONEncoder().encode(subthemes)
            persistance[Key.setsBackupURL] = setsData
            persistance[Key.figsBackupURL] = figsData
            //persistance[Key.themesBackupURL] = themesData
            //persistance[Key.subthemesBackupURL] = subthemesData
            log("Model Saved.")
            
        } catch {
            logerror(error)
        }
    }
    
    func loadFromBack(){
        let persistance = PersistentData()
        if let data = persistance[Key.setsBackupURL] {
            do {
                let items = try JSONDecoder().decode([LegoSet].self, from: data)
                self.append(items)
            } catch {
                logerror(error)
            }
        }
        if let data = persistance[Key.figsBackupURL] {
            do {
                let items = try JSONDecoder().decode([LegoMinifig].self, from: data)
                self.append(items)
            } catch {
                logerror(error)
            }
        }
        if let data = persistance[Key.themesBackupURL] {
            do {
                let items = try JSONDecoder().decode([LegoTheme].self, from: data)
                self.themes = items
            } catch {
                logerror(error)
            }
        }
        if let data = persistance[Key.subthemesBackupURL] {
            do {
                let items = try JSONDecoder().decode([LegoTheme.Subtheme].self, from: data)
                self.subthemes = items
            } catch {
                logerror(error)
            }
        }
        
        
    }
    
    
    func wipe(){
        PersistentData().free()
        DataCache().free()
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
        self.minifigs = [LegoMinifig]()
        self.sets = [LegoSet]()
        
        
    }
    func reset(){
        wipe()
        requestForSync = true
    }
    
    func fetchImages(_ urls:[URL]){
        
        if try! Reachability().connection == .wifi && ProcessInfo.processInfo.isLowPowerModeEnabled == false {
            SDWebImagePrefetcher.shared.prefetchURLs(urls)
        }
    }
}


