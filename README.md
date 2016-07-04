# Patchwire for iOS
iOS Library for the [Patchwire](https://github.com/twisterghost/patchwire) multiplayer server framework created by Michael Barrett.

[![Build Status](https://travis-ci.org/VictorBX/patchwire-ios.svg?branch=master)](https://travis-ci.org/VictorBX/patchwire-ios)

## Installation

#### CocoaPods
Coming soon

#### Carthage
Coming soon

## Usage

Once you have installed Patchwire-iOS into your project, we can start setting it up.

#### Connecting to the server
```swift
Patchwire.sharedInstance.verboseLogging = false
Patchwire.sharedInstance.configure(serverIP: "localhost", serverPort: 3001)
Patchwire.sharedInstance.connect()
```

#### Sending a command
With every command, you can send a dictionary containing some information.
```swift
let chatCommand = Command(command: "chat", data: ["username": "victor", "message": "hello"])
Patchwire.sharedInstance.sendCommand(chatCommand)
```

#### Receiving a command
To receive incoming commands from the server, use `NSNotificationCenter`.
```swift
var chatCommandKey = Patchwire.sharedInstance.notificationKey(forCommand: "chat")
NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatTableViewController.didReceiveChatCommand(_:)), name: chatCommandKey, object: nil)
```

The `NSNotification`'s `userInfo` dictionary will contain the JSON blob sent from the server.

#### Disconnect/Reconnect
```swift
// To disconnect from the server
Patchwire.sharedInstance.disconnect()

// To reconnect to the server
Patchwire.sharedInstance.reconnect()
```

## Example Chat Project

#### Server Side

To run the example chat project, first let's setup the Patchwire server.

1. Open a terminal and go to the `Example/server` directory
2. Install Patchwire using `npm install patchwire@0.1.2` if you haven't done so already
3. Run the server using `node example.js`

Your server should now be running locally on `localhost:3001`.

#### Client Side

Next setup the iOS client. For this example, we're using two iOS simulators that will have a build of the chat app.

1. Open `Patchwire-iOS.xcodeproj` using Xcode
2. Select an iOS simulator (ex. iPhone 6s)
3. Hit run (⌘R)
4. Stop the simulator (⌘.)
5. Repeat step 2, 3, and 4 but select another simulator (ex. iPhone 6s Plus)
6. Close all simulators
7. Open a terminal and: `cd /Applications/Xcode.app/Contents/Developer/Applications`
8. Type `open -n Simulator.app`
9. Repeat step 8 (a warning will pop up, ignore it)
10. On the second simulator, under `Hardware > Device` select a device with the chat app installed (ex. if the first simulator is an iPhone 6s Plus, select iPhone 6s)
11. Run the chat app on both devices.

## License

patchwire-ios is released under the MIT license. See LICENSE for details.
