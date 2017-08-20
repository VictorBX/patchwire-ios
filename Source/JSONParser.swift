//
//  JSONParser.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import Foundation

class JSONParser {
    
    private enum Brace : Character {
        case open = "{"
        case close = "}"
    }
    
    // JSON 
    private (set) var openBraces = 0
    private (set) var storedJSONString = ""
    
    // Debug Logger
    private var logger : Logger?
    var verboseLogging = false {
        didSet {
            logger = verboseLogging && logger == nil ? Logger() : nil
        }
    }
    
    func append(json: String) -> [Any] {
        guard json.characters.count > 0 else { return [] }
        var JSONArray = [Any]()
        
        // Start index
        var startIndex = 0
        
        // Go through string and find open/close braces
        for (index, character) in json.characters.enumerated() {
            guard let brace = Brace(rawValue: character) else { continue }
            
            switch brace {
            case .open:
                openBraces += 1
            case .close:
                openBraces -= 1
                
                if openBraces == 0 {
                    let range = json.characters.index(json.startIndex, offsetBy: startIndex)..<json.characters.index(json.startIndex, offsetBy: index+1)
                    
                    storedJSONString = storedJSONString + json.substring(with: range)
                    
                    if let JSONDictionary = convertToDictionary(json: storedJSONString) {
                        JSONArray.append(JSONDictionary)
                        storedJSONString = ""
                        startIndex = index + 1
                    }
                }
            }
            
        }
        
        // Store remaining json for later use
        storedJSONString = storedJSONString + json.substring(from: json.characters.index(json.startIndex, offsetBy: startIndex))
        
        return JSONArray
    }
    
    private func convertToDictionary(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            logger?.error(message: "Can not convert JSON string to dictionary - \(json)")
            return nil
        }
    }
    
}
