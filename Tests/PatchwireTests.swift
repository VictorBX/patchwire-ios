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

    func testAddCommand() {
        // Given
        var patchwire : Patchwire = Patchwire()
        
        // When
        patchwire.addCommand("chat")
        patchwire.addCommand("updatePlayer")
        
        // Then
        XCTAssertEqual(2, patchwire.commandSet.count, "Must have 'chat' and 'updatePlayer' command")
        XCTAssertTrue(patchwire.commandSet.contains("chat"), "Must contain 'chat' command")
        XCTAssertTrue(patchwire.commandSet.contains("updatePlayer"), "Must contain 'updatePlayer' command")
    }
    
    func testRemoveCommand() {
        // Given
        var patchwire : Patchwire = Patchwire()
        
        // When
        patchwire.addCommand("chat")
        patchwire.removeCommand("chat")
        patchwire.removeCommand("fakecommand")
        
        // Then
        XCTAssertEqual(0, patchwire.commandSet.count, "Removed 'chat' command")
    }
    
    func testRemoveAllCommands() {
        // Given
        var patchwire : Patchwire = Patchwire()
        
        // When
        patchwire.addCommand("chat")
        patchwire.addCommand("register")
        patchwire.addCommand("updatePlayer")
        patchwire.removeAllCommands()
        
        // Then
        XCTAssertEqual(0, patchwire.commandSet.count, "Removed all commands")
    }
    
    func testGetNotificationKeyForCommands() {
        // Given
        var patchwire : Patchwire = Patchwire()
        
        // When
        let chatNotificationKey = patchwire.getNotificationKey(command: "chat")
        let updatePlayerNotificationKey = patchwire.getNotificationKey(command: "updatePlayer")
        
        // Then
        XCTAssertEqual("com.patchwire.command.chat", chatNotificationKey, "'chat' notification key")
        XCTAssertEqual("com.patchwire.command.updatePlayer", updatePlayerNotificationKey, "'updatePlayer' notification key")
    }
    

}
