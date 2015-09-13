//
//  Message.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

enum MessageType: Int {
    case Normal = 0, Joined, Left
}

class Message: NSObject {
    
    var user : String
    var message : String
    var type : MessageType
    
    init(json: Dictionary<NSObject, AnyObject>) {
        
        self.user = ""
        self.message = ""
        self.type = .Normal
        
        if let _user = json["username"] as? String {
            self.user = _user
        }
        
        if let _message = json["message"] as? String {
            self.message = _message
        }
        
        if let _type : Int = json["type"] as? Int {
            type = MessageType(rawValue: _type) ?? .Normal
        }
    }
    
    func displayMessage() -> String {
        switch type {
        case .Normal:
            return self.user + " : " + self.message
        case .Joined, .Left:
            return self.message
        }
    }
    
    func attributedDisplayMessage() -> NSAttributedString {
        
        var attributeDictionary : Dictionary<String, AnyObject> = Dictionary()
        
        switch self.type {
        case .Normal:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor(red: 34.0/256, green: 38.0/255, blue: 38.0/255, alpha: 1.0)
            attributeDictionary[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        case .Joined, .Left:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor.grayColor()
            attributeDictionary[NSFontAttributeName] = UIFont.italicSystemFontOfSize(17)
        }
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: displayMessage(), attributes: attributeDictionary)
        return attributedString.copy() as! NSAttributedString
    }
}
