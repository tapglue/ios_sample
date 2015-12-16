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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        if userNameTextField.text?.characters.count > 2 && passwordTextField.text?.characters.count > 2 {
            
            let username = userNameTextField.text!
            let password = passwordTextField.text!
            
            Tapglue.loginWithUsernameOrEmail(username, andPasswort: password, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n:\(error)")
                } else {
                    print("User was created\n:\(success)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setupCheckedForEvents()
                        self.navigationController?.popToRootViewControllerAnimated(false)
                        
                    })
                }
            })
        } else {
            print("Please enter all details and select an avatar")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCheckedForEvents(){
        let checked: [Bool] = [true, true, true, true]
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(checked, forKey: "checked")
        defaults.synchronize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
