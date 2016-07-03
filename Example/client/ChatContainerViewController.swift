//
//  ChatContainerViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/7/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController, UITextFieldDelegate {

    // Defaults
    var patchwire : Patchwire = Patchwire.sharedInstance()
    let chatSegueName : String = "chatSegue"
    var username : String = ""
    
    // Input
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav bar title
        self.navigationItem.title = "Chat"
        
        // Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // User has left the game
        let chatDictionary : Dictionary<String,AnyObject> = Dictionary(dictionaryLiteral: ("username", username))
        patchwire.sendCommand("logout", withData: chatDictionary)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Chat table view controller
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let segueName : String? = segue.identifier
        
        if let _segueName = segueName {
            if _segueName == self.chatSegueName {
                let chatTableController : ChatTableViewController = segue.destinationViewController as! ChatTableViewController
                chatTableController.username = self.username
                chatTableController.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.inputViewHeightConstraint.constant, 0)
            }
        }
        
    }
    
    
    // MARK: - Input
    
    @IBAction func didSelectSendButton(sender: AnyObject) {
        // Send chat event
        let chatDictionary = ["username": username, "message": inputTextField.text ?? ""]
        patchwire.sendCommand("chat", withData: chatDictionary)
        self.inputTextField.text = ""
    }
    
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            if let keyboardInfo: AnyObject = info[UIKeyboardFrameEndUserInfoKey] {
                let keyboardHeight = keyboardInfo.CGRectValue.height
                self.view.layoutIfNeeded()
                self.inputViewBottomConstraint.constant = keyboardHeight
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                });
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
        self.inputViewBottomConstraint.constant = 0
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        });
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    

}
