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
        
        if count(JSONString) > 0 {
            
            // Start index
            var startIndex : Int = 0
            
            // Go through string and find open/close braces
            for (index, character) in enumerate(JSONString) {
                
                if character == self.openBrace {
                    openBraces++
                } else if character == self.closeBrace {
                    openBraces--
                    
                    if openBraces == 0 {
                        var range = Range(start: advance(JSONString.startIndex,startIndex), end: advance(JSONString.startIndex, index+1))
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
            self.JSONString = self.JSONString + JSONString.substringFromIndex(advance(JSONString.startIndex, startIndex))
        }
        
        return JSONArray
    }
    
    private func convertJSONStringToDictionary(JSONString: String) -> [String:AnyObject]? {
        if let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String:AnyObject]
            if error != nil {
                println(error)
            }
            return json
        }
        return nil
    }
    
}
