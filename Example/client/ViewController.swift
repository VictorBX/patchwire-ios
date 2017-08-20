//
//  ViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var usernameTextField: UITextField!
    
    private let patchwire = Patchwire.sharedInstance
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav bar title
        navigationItem.title = "Patchwire"
    }
    
    
    // MARK: - Enter button
    
    @IBAction func didSelectEnterButton(_ sender: AnyObject) {
        guard let username = usernameTextField.text, username.characters.count > 0 else { return }
        
        // Push to chat controller
        if let chatController = ChatContainerViewController.chatContainer(username: username) {
            navigationController?.pushViewController(chatController, animated: true)
        }
    }
    

}

