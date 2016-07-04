//
//  Notifier.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

class Notifier {

    private let commandKeyPrefix = "com.patchwire.command."
    private let notificationCenter : NSNotificationCenter
    
    init(notificationCenter: NSNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    func getNotificationKey(forCommand command: String) -> String {
        return commandKeyPrefix + command
    }
    
    func postCommand(command: Command) {
        let commandNotification = getNotificationKey(forCommand: command.command)
        notificationCenter.postNotificationName(commandNotification, object: nil, userInfo: command.data)
    }
}
