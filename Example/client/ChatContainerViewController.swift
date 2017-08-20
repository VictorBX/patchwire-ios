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
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var inputViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    // Defaults
    private let patchwire = Patchwire.sharedInstance
    private let notificationCenter = NotificationCenter.default
    private let chatSegueName = "chatSegue"
    private var username = ""
    
    // MARK: - Init
    
    class func chatContainer(username: String) -> ChatContainerViewController? {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let chatController = sb.instantiateViewController(withIdentifier: "chatContainer") as? ChatContainerViewController {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // User has left the game
        patchwire.send(command: ChatCommandService.logoutCommand(username: username))
    }
    
    
    //MARK: - Chat Table View Controller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let segueName = segue.identifier
        
        if let segueName = segueName, segueName == chatSegueName {
            if let chatTableController = segue.destination as? ChatTableViewController {
                chatTableController.username = username
                chatTableController.tableView.contentInset = UIEdgeInsetsMake(0, 0, inputViewHeightConstraint.constant, 0)
            }
        }
    }
    
    
    //MARK: - Input
    
    @IBAction func didSelectSendButton(_ sender: AnyObject) {
        // Send chat event
        patchwire.send(command: ChatCommandService.chatCommand(
                username: username,
                message: inputTextField.text ?? ""
            )
        )
        inputTextField.text = ""
    }
    
    
    //MARK: - Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo {
            if let keyboardInfo = info[UIKeyboardFrameEndUserInfoKey] {
                let keyboardHeight = (keyboardInfo as AnyObject).cgRectValue.height
                view.layoutIfNeeded()
                inputViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                });
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.layoutIfNeeded()
        inputViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        });
    }
    
    
    //MARK: - Notifications
    
    fileprivate func registerNotifications() {
        // Keyboard notifications
        notificationCenter.addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //MARK: - Deinit
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    

}
