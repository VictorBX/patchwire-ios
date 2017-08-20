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
    private let notificationCenter = NotificationCenter.default
    
    var username = ""
    var messages = [Message]()
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview settings
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Register for Patchwire notifications
        registerNotifications()
        
        // Register user
        patchwire.send(command: ChatCommandService.registerCommand(username: username))
    }

    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        cell.configure(message: messages[indexPath.row])
        return cell
    }
    
    
    // MARK: - Patchwire Notifications
    
    func didReceiveChatCommand(_ notification: Notification) {
        guard let info = notification.userInfo as? [String: Any] else { return }
        addNewMessage(info: info)
    }
    
    func didReceiveLogoutCommand(_ notification: Notification) {
        guard let info = notification.userInfo as? [String: Any] else { return }
        addNewMessage(info: info)
    }
    
    fileprivate func addNewMessage(info: [String: Any]) {
        let newMessage = Message(json: info)
        messages.append(newMessage)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .bottom)
        tableView.endUpdates()
        tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    
    //MARK: - Notifications
    
    fileprivate func registerNotifications() {
        
        notificationCenter.addObserver(
            self,
            selector: #selector(ChatTableViewController.didReceiveChatCommand(_:)),
            command: ChatCommandService.ChatCommand.chat.rawValue,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(ChatTableViewController.didReceiveLogoutCommand(_:)),
            command: ChatCommandService.ChatCommand.logout.rawValue,
            object: nil
        )
    }
    
    
    //MARK: - Deinit
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}


// MARK: - ChatCell

class ChatCell: UITableViewCell {
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        selectionStyle = .none
    }
    
    func configure(message: Message) {
        messageLabel.attributedText = message.attributedDisplayMessage()
    }
}
