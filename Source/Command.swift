//
//  Command.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

/// A struct that defines the command that will be sent to the Patchwire server.
public struct Command {
    
    /// The command name.
    public var name : String
    
    /// Additional data to be sent with the command.
    public var data : [String: Any]
    
    
    /**
        Initialize the `Command` with name of command and additional data.
     
        - parameter name:     Name of the command.
        - parameter data:     Additional data to be sent to with the command.
     
        - returns: A `Command` instance.
    */
    public init(name: String, data: [String: Any]?) {
        self.name = name
        self.data = data ?? [:]
    }
}
