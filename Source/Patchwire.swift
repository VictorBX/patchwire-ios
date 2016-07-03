//
//  Patchwire.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class Patchwire: NSObject {
    
    // Config
    private(set) var serverIP : String
    private(set) var serverPort : Int
    
    // Handlers
    private let commandKeyPrefix : String
    
    // Streams
    private var inputStream : NSInputStream?
    private var outputStream : NSOutputStream?
    
    // JSON
    private var jsonParser : JSONParser
    
    // Debugging
    var verboseLogging : Bool
    
    
    //MARK: - Init
    
    class func sharedInstance() -> Patchwire! {
        struct Static {
            static var instance: Patchwire? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self.init()
        }
        
        return Static.instance!
    }
    
    required override init() {
        self.serverIP = "localhost"
        self.serverPort = 3001
        self.commandKeyPrefix = "com.patchwire.command."
        self.jsonParser = JSONParser()
        self.verboseLogging = false
        super.init()
    }
    
    //MARK: - Configure
    
    func configure(serverIP serverIP: String, serverPort: Int) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        
        verboseLogging("Configuring with server IP: \(self.serverIP)")
        verboseLogging("Configuring with server Port: \(self.serverPort)")
    }
    
    func connect() {
        
        verboseLogging("Trying to connect to: \(self.serverIP):\(self.serverPort)")
        
        NSStream.getStreamsToHostWithName(self.serverIP, port: self.serverPort, inputStream: &self.inputStream, outputStream: &self.outputStream)
        self.inputStream?.delegate = self
        self.outputStream?.delegate = self
        self.inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.inputStream?.open()
        self.outputStream?.open()
        
        verboseLogging("Finished opening IO stream")
    }
    
    func disconnect() {
        
        verboseLogging("Disconnecting from: \(self.serverIP):\(self.serverPort)")
        
        if let _inputStream = self.inputStream {
            _inputStream.delegate = nil
            _inputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            _inputStream.close()
            self.inputStream = nil
        }
        if let _outputStream = self.outputStream {
            _outputStream.delegate = nil
            _outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            _outputStream.close()
            self.outputStream = nil
        }
        
        verboseLogging("Finished closing IO stream")
    }
    
    func reconnect(connectAfterSeconds seconds: UInt64) {
        self.disconnect()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.connect()
        }
    }
    
    
    //MARK: - Notifications
    
    private func postNotification(command: String, data: [NSObject: AnyObject]?) {
        verboseLogging("Broadcasting command: \(command)")
        let fullCommandKey : String = self.getNotificationKey(command: command)
        NSNotificationCenter.defaultCenter().postNotificationName(fullCommandKey, object: nil, userInfo: data)
    }
    
    
    //MARK: - Sender
    
    func sendCommand(command: String, withData data: Dictionary<String, AnyObject>?) {
        var sendDictionary : Dictionary<String, AnyObject> = Dictionary()
        sendDictionary["command"] = command
        if let _data = data {
            for key in _data.keys {
                sendDictionary[key] = _data[key]
            }
        }
        
        var jsonData : NSData? = nil
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(sendDictionary, options: NSJSONWritingOptions())
        } catch let error as NSError {
            verboseLogging("Parsing error: " + error.description)
        }
        
        if let jsonData = jsonData {
            verboseLogging("Sending data")
            self.outputStream?.write(UnsafePointer<UInt8>(jsonData.bytes), maxLength: jsonData.length)
        }
    }
    
    
    //MARK: - Helper Functions
    
    func getNotificationKey(command command: String) -> String {
        return self.commandKeyPrefix + command
    }
    
    private func verboseLogging(log: String?) {
        if verboseLogging {
            if let _log = log {
                NSLog("\(_log)")
            }
        }
    }
}


//MARK: - Patchwire + NSStreamDelegate

// Stream Notifications
let kPWRInputStreamEventNotificationKey = "com.patchwire.inputstreamevent"
let kPWROutputStreamEventNotificationKey = "com.patchwire.outputstreamevent"
let kPWRStreamEventKey = "eventCode"

extension Patchwire: NSStreamDelegate {
    
    // Handle stream data
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            verboseLogging("Stream opened")
        case NSStreamEvent.HasBytesAvailable:
            verboseLogging("Stream incoming data")
            handleStream(aStream)
        case NSStreamEvent.ErrorOccurred:
            verboseLogging("Stream error occured")
        case NSStreamEvent.EndEncountered:
            verboseLogging("End of stream")
            self.disconnect()
        default:
            verboseLogging("Uknown stream event")
        }
        
        // Stream event notifications
        if self.inputStream != nil && aStream == self.inputStream {
            NSNotificationCenter.defaultCenter().postNotificationName(kPWRInputStreamEventNotificationKey, object: nil, userInfo: [kPWRStreamEventKey: eventCode.rawValue])
        } else if self.outputStream != nil && aStream == self.outputStream {
            NSNotificationCenter.defaultCenter().postNotificationName(kPWROutputStreamEventNotificationKey, object: nil, userInfo: [kPWRStreamEventKey: eventCode.rawValue])
        }
    }
    
    // Handle incoming data
    private func handleStream(aStream: NSStream) {
        if self.inputStream != nil && aStream == self.inputStream {
            let bufferSize : Int = 4096
            var buffer : [UInt8] = [UInt8](count: bufferSize, repeatedValue: 1)
            var len : Int
            
            while self.inputStream!.hasBytesAvailable {
                len = self.inputStream!.read(&buffer, maxLength: buffer.count)
                if len > 0 {
                    let output : NSString? = NSString(bytes: buffer, length: len, encoding: NSASCIIStringEncoding)
                    if let _output = output {
                        handleJSONBlobs(jsonParser.append(_output as String))
                    }
                }
            }
        }
    }
    
    // Parse json and post notification
    private func handleJSONBlobs(jsonBlobs: [AnyObject]) {
        for jsonBlob in jsonBlobs {
            if let JSONDictionary = jsonBlob as? [String: AnyObject] {
                let command : String = (JSONDictionary["command"] ?? "") as! String
                postNotification(command, data: JSONDictionary)
            }
        }
    }
    
}