//
//  Message.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class Message {
    
    enum MessageType: Int {
        case normal
        case joined
        case left
    }
    
    var user : String
    var message : String
    var type : MessageType
    
    init(json: [String: Any]) {
        
        self.user = json["username"] as? String ?? ""
        self.message = json["message"] as? String ?? ""
        self.type = MessageType(rawValue: json["type"] as? Int ?? 0) ?? .normal
    }
    
    func displayMessage() -> String {
        switch type {
        case .normal:
            return user + " : " + message
        default:
            return message
        }
    }
    
    func attributedDisplayMessage() -> NSAttributedString {
        
        var attributeDictionary = [String: AnyObject]()
        
        switch self.type {
        case .normal:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor(red: 34.0/256, green: 38.0/255, blue: 38.0/255, alpha: 1.0)
            attributeDictionary[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        default:
            attributeDictionary[NSForegroundColorAttributeName] = UIColor.gray
            attributeDictionary[NSFontAttributeName] = UIFont.italicSystemFont(ofSize: 17)
        }
        
        let attributedString = NSMutableAttributedString(string: displayMessage(), attributes: attributeDictionary)
        return attributedString.copy() as! NSAttributedString
    }
}
