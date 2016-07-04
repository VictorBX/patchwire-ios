//
//  Patchwire.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import Foundation

/// The `Patchwire` object that will be used to communicate between the client and the server.
public class Patchwire: NSObject {
    
    /// Patchwire shared instance.
    public static let sharedInstance = Patchwire()
    
    /// The IP of the Patchwire server.
    private(set) var serverIP = "localhost"
    
    /// The port of the Patchwire server.
    private(set) var serverPort = 3001
    
    // JSON Parser
    private let jsonParser : JSONParser
    
    // Notifier
    private let notifier : Notifier
    
    // Logger
    private var logger : Logger?
    
    // Streams
    private var inputStream : NSInputStream?
    private var outputStream : NSOutputStream?
    
    /// Enables verbose logging for additional debugging.
    public var verboseLogging : Bool = false {
        didSet {
            logger = verboseLogging ? Logger() : nil
            jsonParser.verboseLogging = verboseLogging
        }
    }
    
    
    //MARK: - Init
    
    override init() {
        jsonParser = JSONParser()
        notifier = Notifier(notificationCenter: NSNotificationCenter.defaultCenter())
        super.init()
    }
    
    
    //MARK: - Configure
    
    /**
        Configure the `Patchwire` instance with an IP address and port.
     
        - parameter serverIP:    Sets the IP of the server.
        - parameter serverPort:  Sets the port the server is listening to.
    */
    public func configure(serverIP serverIP: String, serverPort: Int) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        
        logger?.info(withLog: "Configuring with server IP: \(self.serverIP)")
        logger?.info(withLog: "Configuring with server Port: \(self.serverPort)")
    }
    
    
    /// Connect to the server with the configured IP address and port.
    public func connect() {
        
        logger?.info(withLog: "Trying to connect to: \(serverIP):\(serverPort)")
        
        NSStream.getStreamsToHostWithName(serverIP, port: serverPort, inputStream: &inputStream, outputStream: &outputStream)
        inputStream?.delegate = self
        outputStream?.delegate = self
        inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream?.open()
        outputStream?.open()
        
        logger?.success(withLog: "Finished opening IO stream")
    }
    
    
    /// Disconnect from the server.
    public func disconnect() {
        
        logger?.info(withLog: "Disconnecting from: \(serverIP):\(serverPort)")
        
        if let _inputStream = inputStream {
            _inputStream.delegate = nil
            _inputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            _inputStream.close()
            inputStream = nil
        }
        if let _outputStream = outputStream {
            _outputStream.delegate = nil
            _outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            _outputStream.close()
            outputStream = nil
        }
        
        logger?.success(withLog: "Finished closing IO stream")
    }
    
    
    /**
        Disconnects then connects to the server after a given amount of seconds.
     
        - parameter seconds: The amount of time (in seconds) the client will wait until connecting to the server after disconnecting.
    */
    public func reconnect(connectAfterSeconds seconds: UInt64) {
        disconnect()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.connect()
        }
    }
    
    
    //MARK: - Commands
    
    /**
        Sends a command to the server.
     
        - parameter command: A `Command` object containing the command name and additional data.
    */
    public func sendCommand(command: Command) {
        var sendDictionary = [String: AnyObject]()
        sendDictionary["command"] = command.command
        if let data = command.data {
            for key in data.keys {
                sendDictionary[key] = data[key]
            }
        }
        
        var jsonData : NSData? = nil
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(sendDictionary, options: NSJSONWritingOptions())
        } catch let error as NSError {
            logger?.error(withLog: "Failed parsing - \(error.description)")
        }
        
        if let jsonData = jsonData {
            logger?.info(withLog: "Sending command - \(command)")
            outputStream?.write(UnsafePointer<UInt8>(jsonData.bytes), maxLength: jsonData.length)
        }
    }
    
    
    /**
        Turns a command name into a key that can be used with the `NSNotificationCenter` to listen for incoming server commands.
     
        - parameter command: The command string that will be turned into a key.
    */
    public func notificationKey(forCommand command: String) -> String {
        return notifier.getNotificationKey(forCommand: command)
    }
}


//MARK: - NSStreamDelegate

/// Stream notification enum containing notification keys. Can be used to listen for any `NSStreamEvent` event that can occur
/// on the input stream or output stream.
public enum PatchwireStreamEventKey : String {
    case InputStreamEvent = "com.patchwire.inputstreamevent"
    case OutputStreamEvent = "com.patchwire.outputstreamevent"
}

extension Patchwire: NSStreamDelegate {
    
    // Handle stream data
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            logger?.info(withLog: "Stream opened")
        case NSStreamEvent.HasBytesAvailable:
            logger?.info(withLog: "Stream incoming data")
            handleStream(aStream)
        case NSStreamEvent.ErrorOccurred:
            logger?.error(withLog: "Stream error occured")
        case NSStreamEvent.EndEncountered:
            logger?.info(withLog: "End of stream")
            disconnect()
        default:
            logger?.info(withLog: "Unknown stream event")
        }
        
        // Stream event notifications
        let eventCodeKey = "eventCode"
        if let inputStream = inputStream where inputStream == aStream {
            NSNotificationCenter.defaultCenter().postNotificationName(PatchwireStreamEventKey.InputStreamEvent.rawValue, object: nil, userInfo: [eventCodeKey: eventCode.rawValue])
        } else if let outputStream = outputStream where outputStream == aStream {
            NSNotificationCenter.defaultCenter().postNotificationName(PatchwireStreamEventKey.OutputStreamEvent.rawValue, object: nil, userInfo: [eventCodeKey: eventCode.rawValue])
        }
    }
    
    // Handle incoming data
    private func handleStream(aStream: NSStream) {
        guard let inputStream = inputStream where inputStream == aStream else { return }
        
        let bufferSize = 4096
        var buffer = [UInt8](count: bufferSize, repeatedValue: 1)
        var len = 0
        
        while inputStream.hasBytesAvailable {
            len = inputStream.read(&buffer, maxLength: buffer.count)
            if len > 0 {
                let output = NSString(bytes: buffer, length: len, encoding: NSASCIIStringEncoding)
                if let output = output as? String {
                    handleJSONBlobs(jsonParser.append(output))
                }
            }
        }
    }
    
    // Parse json and post notification
    private func handleJSONBlobs(jsonBlobs: [AnyObject]) {
        for jsonBlob in jsonBlobs {
            if let JSONDictionary = jsonBlob as? [String: AnyObject] {
                if let commandString = JSONDictionary["command"] as? String {
                    let command = Command(command: commandString, data: JSONDictionary)
                    logger?.info(withLog: "Broadcasting command - \(command.command)")
                    notifier.postCommand(command)
                }
            }
        }
    }
    
}