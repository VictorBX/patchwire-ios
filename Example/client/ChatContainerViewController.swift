//
//  ChatContainerViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/7/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController, UITextFieldDelegate {
    
    // Input
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    // Defaults
    private let patchwire = Patchwire.sharedInstance
    private let chatSegueName = "chatSegue"
    private var username = ""
    
    
    // MARK: - Init
    
    class func chatContainer(withUsername username: String) -> ChatContainerViewController? {
        let sb = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let chatController = sb.instantiateViewControllerWithIdentifier("chatContainer") as? ChatContainerViewController {
            chatController.username = username
            return chatController
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chat"
        registerNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // User has left the game
        patchwire.sendCommand(ChatCommandService.logoutCommand(withUsername: username))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Chat Table View Controller
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let segueName = segue.identifier
        
        if let segueName = segueName where segueName == chatSegueName {
            if let chatTableController = segue.destinationViewController as? ChatTableViewController {
                chatTableController.username = username
                chatTableController.tableView.contentInset = UIEdgeInsetsMake(0, 0, inputViewHeightConstraint.constant, 0)
            }
        }
    }
    
    
    //MARK: - Input
    
    @IBAction func didSelectSendButton(sender: AnyObject) {
        // Send chat event
        patchwire.sendCommand(ChatCommandService.chatCommand(withUsername: username, message: inputTextField.text ?? ""))
        inputTextField.text = ""
    }
    
    
    //MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            if let keyboardInfo: AnyObject = info[UIKeyboardFrameEndUserInfoKey] {
                let keyboardHeight = keyboardInfo.CGRectValue.height
                view.layoutIfNeeded()
                inputViewBottomConstraint.constant = keyboardHeight
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                });
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.layoutIfNeeded()
        inputViewBottomConstraint.constant = 0
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        });
    }
    
    
    //MARK: - Notifications
    
    private func registerNotifications() {
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Deinit
    
    deinit {
        unregisterNotifications()
    }
    

}
