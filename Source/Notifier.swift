//
//  Notifier.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

class Notifier {

    private static let commandKeyPrefix = "com.patchwire.command."
    private let notificationCenter : NotificationCenter
    
    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    static func getNotificationKey(command: String) -> String {
        return commandKeyPrefix + command
    }
    
    func post(command: Command) {
        let commandNotification = Notifier.getNotificationKey(command: command.name)
        notificationCenter.post(
            name: Notification.Name(rawValue: commandNotification),
            object: nil,
            userInfo: command.data
        )
    }
}
