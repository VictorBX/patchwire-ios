//
//  ViewController.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 9/6/15.
//  Copyright (c) 2015 Victor Barrera. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    var patchwire = Patchwire.sharedInstance
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav bar title
        navigationItem.title = "Patchwire"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    
    // MARK: - Enter button
    
    @IBAction func didSelectEnterButton(sender: AnyObject) {
        guard let username = usernameTextField.text where username.characters.count > 0 else { return }
        
        // Push to chat controller
        if let chatController = ChatContainerViewController.chatContainer(withUsername: username) {
            navigationController?.pushViewController(chatController, animated: true)
        }
    }
    

}

