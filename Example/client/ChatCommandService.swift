//
//  ChatCommandService.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

enum ChatCommand : String {
    case Register = "register"
    case Logout = "logout"
    case Chat = "chat"
}

class ChatCommandService: NSObject {

    static func registerCommand(withUsername username: String) -> Command {
        return Command(command: ChatCommand.Register.rawValue, data: ["username": username])
    }
    
    static func logoutCommand(withUsername username: String) -> Command {
        return Command(command: ChatCommand.Logout.rawValue, data: ["username": username])
    }
    
    static func chatCommand(withUsername username: String, message: String) -> Command {
        return Command(command: ChatCommand.Chat.rawValue, data: ["username": username, "message": message])
    }
    
}
