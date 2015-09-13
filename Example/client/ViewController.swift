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
    
    var patchwire : Patchwire = Patchwire.sharedInstance()
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav bar title
        self.navigationItem.title = "Patchwire"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    
    // MARK: - Enter button
    
    @IBAction func didSelectEnterButton(sender: AnyObject) {
        if count(usernameTextField.text) == 0 {
            NSLog("No username entered")
        } else {
            // Push to chat controller
            var chatController: ChatContainerViewController = self.storyboard!.instantiateViewControllerWithIdentifier("chatContainer") as! ChatContainerViewController
            chatController.username = usernameTextField.text
            self.navigationController!.pushViewController(chatController, animated: true)
        }
    }
    

}

