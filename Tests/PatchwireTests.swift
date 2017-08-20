//
//  PatchwireTests.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/9/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit
import XCTest

class PatchwireTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConfigure() {
        // Given
        let patchwire = Patchwire()
        let ip = "localhost"
        let port = 3002
        
        // When
        patchwire.configure(serverIP: ip, serverPort: port)
        
        // Then
        XCTAssertEqual("localhost", patchwire.serverIP, "IP must be localhost")
        XCTAssertEqual(3002, patchwire.serverPort, "Port must be 3002")
    }
    
    func testGetNotificationKeyForCommands() {
        // Given
        let chat = "chat"
        let updatePlayer = "updatePlayer"
        let collectCoin = "collect coin"
        
        // When
        let chatNotificationKey = Patchwire.notificationKey(command: chat)
        let updatePlayerNotificationKey = Patchwire.notificationKey(command: updatePlayer)
        let collectCoingNotificationKey = Patchwire.notificationKey(command: collectCoin)
        
        // Then
        XCTAssertEqual("com.patchwire.command.chat", chatNotificationKey, "'chat' notification key")
        XCTAssertEqual("com.patchwire.command.updatePlayer", updatePlayerNotificationKey, "'updatePlayer' notification key")
        XCTAssertEqual("com.patchwire.command.collect coin", collectCoingNotificationKey, "'collect coin' notification key")
    }
    

}
