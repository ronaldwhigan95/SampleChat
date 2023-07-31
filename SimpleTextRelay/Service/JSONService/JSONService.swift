//
//  JSONService.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/31/23.
//

import Foundation

class JsonService {
    static var shared = JsonService()
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    func decode<T:Decodable>(to model: T.Type, source: Data?, completionHandler: (T) -> ()) {
        if let data = source {
            do {
                let currentUserCustomData = try decoder.decode(T.self, from: data)
                completionHandler(currentUserCustomData)
            } catch {
                print("Error decoding custom data: \(error)")
            }
        }
    }
    
    func encode<T:Encodable>(from model: T? = nil, completionHandler: (String?)->()){
        do {
            encoder.outputFormatting = .prettyPrinted
            let customJSONData = try encoder.encode(model.self)
            completionHandler(String(data: customJSONData, encoding: .utf8))
        } catch {
            print("Error encoding custom data: \(error)")
            return
        }
    }
}
