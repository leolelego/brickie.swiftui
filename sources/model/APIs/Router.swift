//
//  File.swift
//  BrickSet
//
//  Created by Work on 12/05/2020.
//  Copyright © 2020 Homework. All rights reserved.
//

import Foundation
let pageSizeSearch = 150
let pageSizeSet = 350

enum APIRouter<T:Any> {
    
    // MARK: Base
    case login(String,String)
    
    // MARK: Get Sets Data
    case ownedSets(String,Int)
    case wantedSets(String,Int)
    case searchSets(String,String,Int)
    case searchSetsTheme(String,String,Int)
    case searchSetsSubTheme(String,String,Int)
    case searchSetsYear(String,String,Int)
    
    // MARK: Set Sets Data
    case setWanted(String,Int,Bool)
    //    case setOwned(String,LegoSet,Bool) // Useless as it's done form the server by updating the QTY
    case setQty(String,Int,Int)
    case setNotes(String,Int,String)
    case setRating(String,Int,Int)
    
    // MARK: Get Sets Details
    case setInstructions(Int)
    case additionalImages(Int)
    
    // MARK: Get Sets Data
    case ownedFigs(String)
    case wantedFigs(String)
    case searchMinifigs(String,String)
    
    case minifigWanted(String,String,Bool,Int)
    case minifigQty(String,String,Int,Bool)
    case minifigNotes(String,String,String)
    
    // MARK: Get Theme Theme and Subtheme
    case themes
    case subthemes(String)
    
    // Mark Notes
    case getMinifigNotes(String)
    case getUserNotes(String)
    
    var url : URL? {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(method), resolvingAgainstBaseURL: false)
        else {return nil}
        components.queryItems = querys
        components.percentEncodedQuery = components.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: .plus)
        return components.url
    }
    var baseURL : URL {
        return URL(string: "https://brickset.com/api/v3.asmx")!
    }
    
    var method : String {
        switch self {
        case .login: return "login"
        case .setInstructions: return "getInstructions"
        case .additionalImages: return "getAdditionalImages"
        case .ownedSets,.wantedSets,.searchSets,.searchSetsTheme,.searchSetsSubTheme,.searchSetsYear : return "getSets"
        case .setWanted,.setQty,.setNotes,.setRating: return "setCollection"
        case .ownedFigs,.wantedFigs,.searchMinifigs: return "getMinifigCollection"
        case .minifigWanted,.minifigQty,.minifigNotes: return "setMinifigCollection"
        case .themes : return "getThemes"
        case .subthemes : return "getSubthemes"
        case .getMinifigNotes : return "getUserMinifigNotes"
        case .getUserNotes : return "getUserNotes"
            
        }
    }
    
    var subkey : String {
        switch self {
        case .login: return "hash"
        case .setInstructions: return "instructions"
        case .additionalImages:  return "additionalImages"
        case .ownedSets,.wantedSets,.searchSets,.searchSetsTheme,.searchSetsSubTheme,.searchSetsYear : return "sets"
        case .ownedFigs,.wantedFigs,.searchMinifigs: return "minifigs"
        case .setWanted,.setQty,.minifigWanted,.minifigQty,.setNotes,.minifigNotes,.setRating: return "status"
        case .themes: return "themes"
        case .subthemes: return "subthemes"
        case .getMinifigNotes : return "userMinifigNotes"
        case .getUserNotes : return "userNotes"
            
            
            
        }
    }
    var querys : [URLQueryItem]? {
        var allQueries: [URLQueryItem] = [
            
            URLQueryItem(name: "apiKey", value: APIRouter.bricksetAPIKey)
        ]
        switch self {
        case .login(let u, let p):
            allQueries.append(URLQueryItem(name: "username", value: u))
            allQueries.append(URLQueryItem(name: "password", value: p))
            
        case .setInstructions(let setId),.additionalImages(let setId):
            allQueries.append(URLQueryItem(name: "setID", value: String(setId)))
            
            
        case .ownedSets(let hash, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{owned:1,pageNumber:\(page),pageSize:\(pageSizeSet)}"))
            
        case .ownedFigs(let hash):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{owned:1}"))
            
        case .wantedSets(let hash, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{wanted:1,pageNumber:\(page),pageSize:\(pageSizeSet)}"))
            
        case .wantedFigs(let hash):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{wanted:1}"))
            
        case .searchSets(let hash, let search, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{query:\"\(search)\",pageNumber:\(page),pageSize:\(pageSizeSearch)}"))
            
        case .searchSetsTheme(let hash, let search, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{theme:\"\(search)\",pageNumber:\(page),pageSize:\(pageSizeSearch)}"))
            
        case .searchSetsSubTheme(let hash, let search, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{subtheme:\"\(search)\",pageNumber:\(page),pageSize:\(pageSizeSearch)}"))
            
        case .searchSetsYear(let hash, let search, let page):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{year:\"\(search)\",pageNumber:\(page),pageSize:\(pageSizeSearch)}"))
            
        case .searchMinifigs(let hash, let search):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "params", value: "{query:\"\(search)\"}"))
            
        case .setWanted(let hash,let setId, let want):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "setID", value: String(setId)))
            allQueries.append(URLQueryItem(name: "params", value: "{want:\(want ? 1:0)}"))
            
        case .setQty(let hash,let setId, let qty):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "setID", value: String(setId)))
            allQueries.append(URLQueryItem(name: "params", value: "{qtyOwned:\(qty)}")) //owned:\(qty < 1 ? 0 : 1),
            
        case .minifigWanted(let hash,let minifigNumber, let want, let ownedLoose):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "minifigNumber", value: minifigNumber))
            allQueries.append(URLQueryItem(name: "params", value: "{want:\(want ? 1:0),qtyOwned:\(ownedLoose)}"))
            
        case .minifigQty(let hash,let minifigNumber, let qty, let isWanted):
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "minifigNumber", value: minifigNumber))
            allQueries.append(URLQueryItem(name: "params", value: "{want:\(isWanted ? 1 : 0),qtyOwned:\(qty)}"))
        case .setNotes(let hash,let setId, let notes) :
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "setID", value: String(setId)))
            allQueries.append(URLQueryItem(name: "params", value: "{notes:\"\(notes.isEmpty ? " " : notes)\"}"))
            
        case .setRating(let hash,let setID, let rating) :
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "setID", value: String(setID)))
            allQueries.append(URLQueryItem(name: "params", value: "{rating:\(rating)}"))
            
        case .minifigNotes(let hash,let minifigNumber, let notes) :
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
            allQueries.append(URLQueryItem(name: "minifigNumber", value: minifigNumber))
            allQueries.append(URLQueryItem(name: "params", value: "{notes:\"\(notes.isEmpty ? " " : notes)\"}"))
            
        case .themes :
            log("Do Nothing")
            
        case .subthemes(let theme) :
            allQueries.append(URLQueryItem(name: "theme", value: theme))
            
        case .getMinifigNotes(let hash), .getUserNotes(let hash) :
            allQueries.append(URLQueryItem(name: "userHash", value: hash))
        }
        return allQueries
    }
}


extension APIRouter {
    private func response(completion: @escaping (Result<Any,Error>) -> Void){
        guard let u = url
        else {
            completion(.failure(APIError.invalid))
            return
            
        }
        URLSession.shared.dataTask(with: u){ data, response, error in
            guard error == nil else {
                logerror(error)
                completion(.failure(error!))
                return
                
            }
            guard let d = data,
                  let jsonObj = try? JSONSerialization.jsonObject(with: d, options: [])
            else {
                completion(.failure(APIError.invalid))
                return
            }
            completion(.success(jsonObj))
            
        }.resume()
        
    }
    
    func responseJSON(completion: @escaping (Result<T,Error>) -> Void){
        response { response in
            switch response {
            case .failure(let err):
                logerror(err)
                completion(.failure(err))
                break
            case .success(let jsonObj):
                guard let dict = jsonObj as? [String:Any]
                else {
                    completion(.failure(APIError.invalid))
                    return
                }
                
                if let items = dict[self.subkey] as? T {
                    completion(.success(items))
                } else if let mess = dict["message"] as? String {
                    if mess.contains("Invalid user hash") {
                        completion(.failure(APIError.invalidUserHash))
                    } else if mess.contains("API limit exceeded") {
                        completion(.failure(APIError.apiLimitExceeded))
                    } else {
                        completion(.failure(APIError.badData))
                    }
                } else {
                    completion(.failure(APIError.malformed))
                    
                }
                break
                
            }
        }
    }
    
    func decode<C:Codable>(ofType: C.Type,completion: @escaping (Result<C,Error>) -> Void ){
        responseJSON { response in
            switch response{
            case .success(let object):
                do {
                    
                    let json = try JSONSerialization.data(withJSONObject: object, options: [])
                    let items = try JSONDecoder().decode(ofType.self, from: json)
                    
                    completion(.success(items))
                } catch let DecodingError.dataCorrupted(context) {
                    log("\(context)")
                } catch let DecodingError.keyNotFound(key, context) {
                    
                    log("Key '\(key)' not found: \(context.debugDescription)")
                    log("codingPath: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    log("Value '\(value)' not found: \(context.debugDescription)")
                    log("codingPath: \(context.codingPath)" )
                } catch let DecodingError.typeMismatch(type, context)  {
                    log("Type '\(type)' mismatch: \(context.debugDescription)")
                    log("codingPath: \(context.codingPath)")
                } catch {
                    logerror(error)
                }
                break
            case .failure(let err):
                completion(.failure(err))
                
                break // logged before nobody care
            }
            
        }
    }
    
    
    func responseJSON2() async throws -> T{
        do {
            guard let u = url else {
                throw APIError.invalid
            }
            
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: u))
            
            guard let dict = try? JSONSerialization.jsonObject(with: data, options: [])as? [String:Any]  else {
                throw APIError.invalid
            }
            
            
            if let items = dict[self.subkey] as? T{
                return items
            } else if let mess = dict["message"] as? String {
                
                if mess.contains("Invalid user hash") {
                    throw APIError.invalidUserHash
                } else if mess.contains("API limit exceeded") {
                    throw APIError.apiLimitExceeded
                } else {
                    throw APIError.badData
                }
            } else {
                throw APIError.malformed
            }
            
        } catch(let err) {
            throw err
        }
        
    }
    
    func decode2() async throws -> T where T:Decodable{
        do {
//            let response = try await responseJSON2()
            guard let u = url else {
                throw APIError.invalid
            }
            
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: u))
            
            guard let dict = try? JSONSerialization.jsonObject(with: data, options: [])as? [String:Any]  else {
                throw APIError.invalid
            }
            
            guard  let items = dict[self.subkey] as? [[String:Any]] else {
                if let mess = dict["message"] as? String {
                    
                    if mess.contains("Invalid user hash") {
                        throw APIError.invalidUserHash
                    } else if mess.contains("API limit exceeded") {
                        throw APIError.apiLimitExceeded
                    } else {
                        throw APIError.badData
                    }
                } else {
                    throw APIError.malformed
                }
                
            }
            let json = try JSONSerialization.data(withJSONObject: items, options: [])
            let objs = try JSONDecoder().decode(T.self, from: json)
            
            return objs
        } catch let DecodingError.dataCorrupted(context) {
            log("\(context)")
            throw APIError.malformed
        } catch let DecodingError.keyNotFound(key, context) {
            
            log("Key '\(key)' not found: \(context.debugDescription)")
            log("codingPath: \(context.codingPath)")
            throw APIError.malformed
        } catch let DecodingError.valueNotFound(value, context) {
            log("Value '\(value)' not found: \(context.debugDescription)")
            log("codingPath: \(context.codingPath)" )
            throw APIError.malformed
        } catch let DecodingError.typeMismatch(type, context)  {
            log("Type '\(type)' mismatch: \(context.debugDescription)")
            log("codingPath: \(context.codingPath)")
            throw APIError.malformed
        } catch {
            logerror(error)
            throw APIError.malformed
            
        }
        
    }
    
    
}
extension APIRouter {
    static var bricksetAPIKey: String {
        if let key = ProcessInfo.processInfo.environment["BRICKSET_API_KEY"] {
            return key
        }
        if let key = Bundle.main.infoDictionary?["BRICKSET_API_KEY"] as? String {
            return key
        }
        return "NOSET"
    }
}
