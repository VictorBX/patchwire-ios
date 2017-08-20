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
    private (set) var serverIP = "localhost"
    
    /// The port of the Patchwire server.
    private (set) var serverPort = 3001
    
    // JSON Parser
    fileprivate let jsonParser : JSONParser
    
    // Notifier
    fileprivate let notifier : Notifier
    
    // Logger
    fileprivate var logger : Logger?
    
    // Streams
    fileprivate var inputStream : InputStream?
    fileprivate var outputStream : OutputStream?
    
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
        notifier = Notifier(notificationCenter: NotificationCenter.default)
        super.init()
    }
    
    
    //MARK: - Configure
    
    /**
        Configure the `Patchwire` instance with an IP address and port.
     
        - parameter serverIP:    Sets the IP of the server.
        - parameter serverPort:  Sets the port the server is listening to.
    */
    public func configure(serverIP: String, serverPort: Int) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        
        logger?.info(message: "Configuring with server IP: \(self.serverIP)")
        logger?.info(message: "Configuring with server Port: \(self.serverPort)")
    }
    
    
    /// Connect to the server with the configured IP address and port.
    public func connect() {
        
        logger?.info(message: "Trying to connect to: \(serverIP):\(serverPort)")
        
        Stream.getStreamsToHost(withName: serverIP, port: serverPort, inputStream: &inputStream, outputStream: &outputStream)
        inputStream?.delegate = self
        outputStream?.delegate = self
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        inputStream?.open()
        outputStream?.open()
        
        logger?.success(message: "Finished opening IO stream")
    }
    
    
    /// Disconnect from the server.
    public func disconnect() {
        
        logger?.info(message: "Disconnecting from: \(serverIP):\(serverPort)")
        
        if let _inputStream = inputStream {
            _inputStream.delegate = nil
            _inputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            _inputStream.close()
            inputStream = nil
        }
        if let _outputStream = outputStream {
            _outputStream.delegate = nil
            _outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            _outputStream.close()
            outputStream = nil
        }
        
        logger?.success(message: "Finished closing IO stream")
    }
    
    
    /**
        Disconnects then connects to the server after a given amount of seconds.
     
        - parameter seconds: The amount of time (in seconds) the client will wait until connecting to the server after disconnecting.
    */
    public func reconnect(seconds: UInt64) {
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) { () -> Void in
            self.connect()
        }
    }
    
    
    //MARK: - Commands
    
    /**
        Sends a command to the server.
     
        - parameter command: A `Command` object containing the command name and additional data.
    */
    public func send(command: Command) {
        var sendDictionary = [String: Any]()
        sendDictionary["command"] = command.name
        for key in command.data.keys {
            sendDictionary[key] = command.data[key]
        }
        
        var jsonData : Data? = nil
        do {
            jsonData = try JSONSerialization.data(withJSONObject: sendDictionary, options: JSONSerialization.WritingOptions())
        } catch let error as NSError {
            logger?.error(message: "Failed parsing - \(error.description)")
        }
        
        if let jsonData = jsonData {
            logger?.info(message: "Sending command - \(command)")
            outputStream?.write((jsonData as NSData).bytes.bindMemory(to: UInt8.self, capacity: jsonData.count), maxLength: jsonData.count)
        }
    }
    
    
    /**
        Turns a command name into a key that can be used with the `NSNotificationCenter` to listen for incoming server commands.
     
        - parameter command: The command string that will be turned into a key.
    */
    public static func notificationKey(command: String) -> String {
        return Notifier.getNotificationKey(command: command)
    }
}


//MARK: - NSStreamDelegate

/// Stream notification enum containing notification keys. Can be used to listen for any `NSStreamEvent` event that can occur
/// on the input stream or output stream.
public enum PatchwireStreamEventKey : String {
    case InputStreamEvent = "com.patchwire.inputstreamevent"
    case OutputStreamEvent = "com.patchwire.outputstreamevent"
}

extension Patchwire: StreamDelegate {
    
    // Handle stream data
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            logger?.info(message: "Stream opened")
        case Stream.Event.hasBytesAvailable:
            logger?.info(message: "Stream incoming data")
            parse(stream: aStream)
        case Stream.Event.errorOccurred:
            logger?.error(message: "Stream error occured")
        case Stream.Event.endEncountered:
            logger?.info(message: "End of stream")
            disconnect()
        default:
            logger?.info(message: "Unknown stream event")
        }
        
        // Stream event notifications
        let eventCodeKey = "eventCode"
        if let inputStream = inputStream, inputStream == aStream {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: PatchwireStreamEventKey.InputStreamEvent.rawValue),
                object: nil,
                userInfo: [eventCodeKey: eventCode.rawValue]
            )
        } else if let outputStream = outputStream, outputStream == aStream {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: PatchwireStreamEventKey.OutputStreamEvent.rawValue),
                object: nil,
                userInfo: [eventCodeKey: eventCode.rawValue]
            )
        }
    }
    
    // Handle incoming data
    private func parse(stream aStream: Stream) {
        guard let inputStream = inputStream, inputStream == aStream else { return }
        
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 1, count: bufferSize)
        var len = 0
        
        while inputStream.hasBytesAvailable {
            len = inputStream.read(&buffer, maxLength: buffer.count)
            if len > 0 {
                let output = NSString(bytes: buffer, length: len, encoding: String.Encoding.ascii.rawValue)
                if let output = output as String? {
                    parse(jsonBlobs: jsonParser.append(json: output))
                }
            }
        }
    }
    
    // Parse json and post notification
    private func parse(jsonBlobs: [Any]) {
        for jsonBlob in jsonBlobs {
            guard let JSONDictionary = jsonBlob as? [String: Any] else { continue }
            
            // Check for batch commands
            if let batch = JSONDictionary["batch"] as? Bool, batch {
                if let commands = JSONDictionary["commands"] as? [[String: Any]] {
                    logger?.info(message: "Received batch of commands")
                    commands.forEach({ (commandDictionary) in
                        post(commandData: commandDictionary)
                    })
                }
            } else {
                // Single command
                post(commandData: JSONDictionary)
            }
        }
    }
    
    private func post(commandData: [String: Any]) {
        guard let commandName = commandData["command"] as? String else { return }
        let command = Command(name: commandName, data: commandData)
        logger?.info(message: "Broadcasting command - \(command.name)")
        notifier.post(command: command)
    }
    
}
