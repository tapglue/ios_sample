//
//  LoginSignInVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class LoginSignInVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Show navigationBar again when view disappears
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        // If textFields have more then 2 characters, begin Tapglue login
        if userNameTextField.text?.characters.count > 2 &&
            passwordTextField.text?.characters.count > 2 {
            
            let username = userNameTextField.text!
            let password = passwordTextField.text!
            
            // NewSDK
            appDel.rxTapglue.loginUser(username, password: password).subscribe({ (event) in
                switch event {
                case .Next(let user):
                    print("User logged in: \(user)")
                    
                case .Error(let error):
                    let err = error as! TapglueError
                    
                    switch err.code! {
                    case 1001:
                        let alertController = UIAlertController(title: "Error", message:
                            "User does not exist.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    case 0:
                        let alertController = UIAlertController(title: "Error", message:
                            "Wrong password.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    default:
                        "Error code was not added to switch"
                    }
                    
                case .Completed:
                    self.navigationController?.popToRootViewControllerAnimated(false)
                }
            }).addDisposableTo(self.appDel.disposeBag)
            
        } else {
            
            let alertController = UIAlertController(title: "Not enough characters", message:
                "Username and Password must be at least 3 characters.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
