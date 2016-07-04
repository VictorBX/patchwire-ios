//
//  ChatTableViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {

    private let patchwire = Patchwire.sharedInstance
    var username = ""
    var messages = [Message]()
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview settings
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Register for Patchwire notifications
        registerNotifications()
        
        // Register user
        patchwire.sendCommand(ChatCommandService.registerCommand(withUsername: username))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table View Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ChatCell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! ChatCell
        cell.configure(messages[indexPath.row])
        return cell
    }
    
    
    // MARK: - Patchwire Notifications
    
    func didReceiveChatCommand(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        addNewMessageUsingInfo(info)
    }
    
    func didReceiveLogoutCommand(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        addNewMessageUsingInfo(info)
    }
    
    private func addNewMessageUsingInfo(info: Dictionary<NSObject, AnyObject>) {
        let newMessage = Message(json: info)
        messages.append(newMessage)
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messages.count-1, inSection: 0)], withRowAnimation: .Bottom)
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    
    //MARK: - Notifications
    
    private func registerNotifications() {
        let chatCommandKey = patchwire.notificationKey(forCommand: ChatCommand.Chat.rawValue)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatTableViewController.didReceiveChatCommand(_:)), name: chatCommandKey, object: nil)
        let logoutCommandKey = patchwire.notificationKey(forCommand: ChatCommand.Logout.rawValue)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatTableViewController.didReceiveLogoutCommand(_:)), name: logoutCommandKey, object: nil)
    }
    
    private func unregisterNotifications() {
        let chatCommandKey : String = patchwire.notificationKey(forCommand: ChatCommand.Chat.rawValue)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: chatCommandKey, object: nil)
        let logoutCommandKey : String = patchwire.notificationKey(forCommand: ChatCommand.Logout.rawValue)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: logoutCommandKey, object: nil)
    }
    
    
    //MARK: - Deinit
    
    deinit {
        unregisterNotifications()
    }
}


// MARK: - ChatCell

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func configure(message: Message) {
        messageLabel.attributedText = message.attributedDisplayMessage()
    }
}