//
//  JSONParser.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class JSONParser: NSObject {
   
    private let openBrace : Character = "{"
    private let closeBrace : Character = "}"
    
    private(set) var openBraces : Int
    private(set) var JSONString : String
    
    override init() {
        self.openBraces = 0
        self.JSONString = ""
        super.init()
    }
    
    func append(JSONString: String) -> [AnyObject] {
        var JSONArray : [AnyObject] = []
        
        if JSONString.characters.count > 0 {
            
            // Start index
            var startIndex : Int = 0
            
            // Go through string and find open/close braces
            for (index, character) in JSONString.characters.enumerate() {
                
                if character == self.openBrace {
                    openBraces++
                } else if character == self.closeBrace {
                    openBraces--
                    
                    if openBraces == 0 {
                        let range = Range(start: JSONString.startIndex.advancedBy(startIndex), end: JSONString.startIndex.advancedBy(index+1))
                        self.JSONString = self.JSONString + JSONString.substringWithRange(range)
                        if let JSONDictionary: [String:AnyObject] = convertJSONStringToDictionary(self.JSONString) {
                            JSONArray.append(JSONDictionary)
                            self.JSONString = ""
                            startIndex = index + 1
                        }
                    }
                }
            }
            
            // Store remaining json for later use
            self.JSONString = self.JSONString + JSONString.substringFromIndex(JSONString.startIndex.advancedBy(startIndex))
        }
        
        return JSONArray
    }
    
    private func convertJSONStringToDictionary(JSONString: String) -> [String:AnyObject]? {
        if let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
                return json
            } catch {
                print("Can't serialize to dictionary")
            }
        }
        return nil
    }
    
}
