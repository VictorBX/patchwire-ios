//
//  ChatTableViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {

    var username : String = ""
    var patchwire : Patchwire = Patchwire.sharedInstance()
    var messages : [Message] = []
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview settings
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Register for Patchwire notifications
        var chatCommandKey : String = patchwire.getNotificationKey(command: "chat")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveChatCommand:", name: chatCommandKey, object: nil)
        var logoutCommandKey : String = patchwire.getNotificationKey(command: "logout")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLogoutCommand:", name: logoutCommandKey, object: nil)
        
        // Register user
        var registerDictionary : Dictionary<String,AnyObject> = Dictionary(dictionaryLiteral: ("username", username))
        patchwire.sendCommand("register", withData: registerDictionary)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : ChatCell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! ChatCell
        cell.configure(messages[indexPath.row])
        return cell
    }
    
    
    // MARK: - Patchwire Notifications
    
    func didReceiveChatCommand(notification: NSNotification) {
        NSLog("\nDid Receive chat command")
        if let info = notification.userInfo {
            self.addNewMessageUsingInfo(info)
        }
    }
    
    func didReceiveLogoutCommand(notification: NSNotification) {
        NSLog("\nDid Receive logout command")
        if let info = notification.userInfo {
            self.addNewMessageUsingInfo(info)
        }
    }
    
    private func addNewMessageUsingInfo(info: Dictionary<NSObject, AnyObject>) {
        var newMessage : Message = Message(json: info)
        messages.append(newMessage)
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messages.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    
    deinit {
        // Remove notifications
        var chatCommandKey : String = patchwire.getNotificationKey(command: "chat")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: chatCommandKey, object: nil)
        var logoutCommandKey : String = patchwire.getNotificationKey(command: "logout")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: logoutCommandKey, object: nil)
    }
}


// MARK: - ChatCell

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func configure(message: Message) {
        messageLabel.attributedText = message.attributedDisplayMessage()
    }
}