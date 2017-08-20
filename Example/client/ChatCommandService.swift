//
//  ChatCommandService.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

class ChatCommandService {

    enum ChatCommand : String {
        case register = "register"
        case logout = "logout"
        case chat = "chat"
    }
    
    static func registerCommand(username: String) -> Command {
        return Command(
            name: ChatCommand.register.rawValue,
            data: [
                "username": username
            ]
        )
    }
    
    static func logoutCommand(username: String) -> Command {
        return Command(
            name: ChatCommand.logout.rawValue,
            data: [
                "username": username
            ]
        )
    }
    
    static func chatCommand(username: String, message: String) -> Command {
        return Command(
            name: ChatCommand.chat.rawValue,
            data: [
                "username": username,
                "message": message
            ]
        )
    }
    
}
