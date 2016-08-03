//
//  LoginRegisterVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 25.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class LoginRegisterVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentAvatar: String?
    
    // Free http://uifaces.com/authorized profile pictures
    let userProfileImageURLs =  ["https://s3.amazonaws.com/uifaces/faces/twitter/rem/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/nedknowles/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/jadlimcaco/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/zack415/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/rssems/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/philcoffman/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/kfriedson/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/nuraika/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/raquelromanp/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/geeftvorm/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/hellgy/128.jpg",
                                "https://s3.amazonaws.com/uifaces/faces/twitter/allisongrayce/128.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(animated: Bool) {
        // Show navigationBar again when view disappears
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        // If all textFields have more than 2 charcaters, begin Tapglue login
        if userNameTextField.text?.characters.count > 2 && firstNameTextField.text?.characters.count > 2 && lastNameTextField.text?.characters.count > 2 && aboutTextField.text?.characters.count > 2 && emailTextField.text?.characters.count > 2 && passwordTextField.text?.characters.count > 2 {
            
            let tapglueUser = TGUser()
            
            let about: [NSObject : AnyObject!] = ["about" : aboutTextField.text]
            tapglueUser.metadata = about
            
            tapglueUser.username = userNameTextField.text!
            tapglueUser.firstName = firstNameTextField.text!
            tapglueUser.lastName = lastNameTextField.text!
            tapglueUser.email = emailTextField.text!
            tapglueUser.setPassword(passwordTextField.text!)
            
            let userImage = TGImage()
            let randomIndex = Int(arc4random_uniform(UInt32(userProfileImageURLs.count)))
            userImage.url = userProfileImageURLs[randomIndex]
            tapglueUser.images.setValue(userImage, forKey: "profilePic")
            
            Tapglue.createAndLoginUser(tapglueUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("\nError createAndLoginUser: \(error)")
                } else {
                    print("\nUser was created: \(success)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.popToRootViewControllerAnimated(false)
                    })
                }
            })
        } else {
            print("Not enough characters")
        }
    }
}

extension LoginRegisterVC: UITextFieldDelegate {
    // Mark: TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Jump to the next textField, when you press next
        switch textField.tag {
            case 0:
                firstNameTextField.becomeFirstResponder()
            case 1:
                lastNameTextField.becomeFirstResponder()
            case 2:
                aboutTextField.becomeFirstResponder()
            case 3:
                emailTextField.becomeFirstResponder()
            case 4:
                passwordTextField.becomeFirstResponder()
            case 5:
                textField.resignFirstResponder()
            default: print("default was triggered")
        }
        
        return false
    }
}

