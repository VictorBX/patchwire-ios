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
        guard let text = usernameTextField.text where text.characters.count > 0 else { return }
        
        // Push to chat controller
        let chatController: ChatContainerViewController = self.storyboard!.instantiateViewControllerWithIdentifier("chatContainer") as! ChatContainerViewController
        chatController.username = text
        self.navigationController!.pushViewController(chatController, animated: true)
    }
    

}

