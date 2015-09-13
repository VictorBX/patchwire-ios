//
//  JSONParserTests.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/9/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit
import XCTest

class JSONParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseValidJSON() {
        // Given
        var jsonParser : JSONParser = JSONParser()
        var validJSONString : String = "{\"a\":\"1\"}"
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(validJSONString)
        
        // Then
        XCTAssertEqual(1, jsonBlobs.count, "Valid JSON, must return 1 JSON blob.")
        XCTAssertEqual(0, jsonParser.openBraces, "Braces must have cancelled out.")
        XCTAssertEqual(0, count(jsonParser.JSONString), "JSONString must be empty.")
    }
    
    func testParseInvalidJSON() {
        
        // Given
        var jsonParser : JSONParser = JSONParser()
        var invalidJSONString : String = "{\"a\""
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(invalidJSONString)
        
        // Then
        XCTAssertEqual(0, jsonBlobs.count, "Invalid JSON, must return 0 JSON blobs.")
        XCTAssertEqual(1, jsonParser.openBraces, "There must be 1 open brace.")
        XCTAssertEqual(count(invalidJSONString), count(jsonParser.JSONString), "JSONString must be same length as invalid passed-in JSON.")
    }

    func testAppendCompleteJSONChunks() {
        // Given
        var jsonParser : JSONParser = JSONParser()
        var keyJSONChunk : String = "{\"a\":"
        var valueJSONChunk : String = "\"1\"}{\"b\":\"2\"}"
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(keyJSONChunk)
        jsonBlobs = jsonParser.append(valueJSONChunk)
        
        // Then
        XCTAssertEqual(2, jsonBlobs.count, "Valid JSON chunks, must return 2 JSON blobs.")
        XCTAssertEqual(0, jsonParser.openBraces, "Braces should have cancelled out.")
        XCTAssertEqual(0, count(jsonParser.JSONString), "JSONString must be empty.")
    }
    
    func testAppendIncompleteJSONChunks() {
        // Given
        var jsonParser : JSONParser = JSONParser()
        var keyJSONChunk : String = "{\"a\":"
        var valueJSONChunk : String = "\"1\"}{\"b\":\"2\""
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(keyJSONChunk)
        jsonBlobs = jsonParser.append(valueJSONChunk)
        
        // Then
        XCTAssertEqual(1, jsonBlobs.count, "1 Valid JSON blob")
        XCTAssertEqual(1, jsonParser.openBraces, "1 Open Brace must remain.")
        XCTAssertEqual(count("{\"b\":\"2\""), count(jsonParser.JSONString), "Must be remaining invalid json.")
    }
    
    func testAppendCompleteComplexJSONChunks() {
        // Given
        var jsonParser : JSONParser = JSONParser()
        var keyJSONChunk : String = "{\"a\":"
        var valueJSONChunk : String = "\"1\"}{\"b\":{\"c\":\"2\"},\"d\":\"3\"}"
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(keyJSONChunk)
        jsonBlobs = jsonParser.append(valueJSONChunk)
        
        // Then
        XCTAssertEqual(2, jsonBlobs.count, "2 Valid JSON blobs")
        XCTAssertEqual(0, jsonParser.openBraces, "Braces must have cancelled out.")
        XCTAssertEqual(0, count(jsonParser.JSONString), "JSONString must be empty.")
    }
    
    func testAppendIncompleteComplexJSONChunks() {
        // Given
        var jsonParser : JSONParser = JSONParser()
        var keyJSONChunk : String = "{\"a\":"
        var valueJSONChunk : String = "\"1\"}{\"b\":{\"c\":\"2\"},\"d\":\"3\"}{\"e\":{"
        
        // When
        var jsonBlobs : [AnyObject] = jsonParser.append(keyJSONChunk)
        jsonBlobs = jsonParser.append(valueJSONChunk)
        
        // Then
        XCTAssertEqual(2, jsonBlobs.count, "2 Valid JSON blobs")
        XCTAssertEqual(2, jsonParser.openBraces, "2 Open Brace must remain.")
        XCTAssertEqual(count("{\"e\":{"), count(jsonParser.JSONString), "Must be remaining invalid json.")
    }
    
}
