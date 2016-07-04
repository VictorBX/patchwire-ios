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

class Message {
    
    var user : String
    var message : String
    var type : MessageType
    
    init(json: [NSObject: AnyObject]) {
        
        self.user = ""
        self.message = ""
        self.type = .Normal
        
        if let user = json["username"] as? String {
            self.user = user
        }
        
        if let message = json["message"] as? String {
            self.message = message
        }
        
        if let type = json["type"] as? Int {
            self.type = MessageType(rawValue: type) ?? .Normal
        }
    }
    
    func displayMessage() -> String {
        switch type {
        case .Normal:
            return self.user + " : " + self.message
        default:
            return self.message
        }
    }
    
    func attributedDisplayMessage() -> NSAttributedString {
        
        var attributeDictionary = [String: AnyObject]()
        
        switch self.type {
        case .Normal:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor(red: 34.0/256, green: 38.0/255, blue: 38.0/255, alpha: 1.0)
            attributeDictionary[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        default:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor.grayColor()
            attributeDictionary[NSFontAttributeName] = UIFont.italicSystemFontOfSize(17)
        }
        
        let attributedString = NSMutableAttributedString(string: displayMessage(), attributes: attributeDictionary)
        return attributedString.copy() as! NSAttributedString
    }
}
