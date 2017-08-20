//
//  NotificationCenter+Patchwire.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 8/19/17.
//  Copyright © 2017 Victor Barrera. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    public func addObserver(_ observer: Any, selector aSelector: Selector, command: String, object anObject: Any?) {
        let name = Patchwire.notificationKey(command: command)
        addObserver(
            observer,
            selector: aSelector,
            name: NSNotification.Name(rawValue: name),
            object: anObject
        )
    }
}
