//
//  JSONParser.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import Foundation

private enum Brace : Character {
    case Open = "{"
    case Close = "}"
}

class JSONParser {
    
    // JSON 
    private(set) var openBraces = 0
    private(set) var storedJSONString = ""
    
    // Debug Logger
    private var logger : Logger?
    var verboseLogging : Bool = false {
        didSet {
            logger = verboseLogging ? Logger() : nil
        }
    }
    
    func append(JSONString: String) -> [AnyObject] {
        var JSONArray = [AnyObject]()
        guard JSONString.characters.count > 0 else { return JSONArray }
        
        // Start index
        var startIndex = 0
        
        // Go through string and find open/close braces
        for (index, character) in JSONString.characters.enumerate() {
            guard let brace = Brace(rawValue: character) else { continue }
            
            switch brace {
            case .Open:
                openBraces += 1
            case .Close:
                openBraces -= 1
                
                if openBraces == 0 {
                    let range = JSONString.startIndex.advancedBy(startIndex)..<JSONString.startIndex.advancedBy(index+1)
                    storedJSONString = storedJSONString + JSONString.substringWithRange(range)
                    if let JSONDictionary = convertJSONStringToDictionary(storedJSONString) {
                        JSONArray.append(JSONDictionary)
                        storedJSONString = ""
                        startIndex = index + 1
                    }
                }
            }
            
        }
        
        // Store remaining json for later use
        storedJSONString = storedJSONString + JSONString.substringFromIndex(JSONString.startIndex.advancedBy(startIndex))
        
        return JSONArray
    }
    
    private func convertJSONStringToDictionary(JSONString: String) -> [String:AnyObject]? {
        if let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
                return json
            } catch {
                logger?.error(withLog: "Can not convert JSON string to dictionary - \(JSONString)")
            }
        }
        return nil
    }
    
}
