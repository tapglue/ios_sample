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
    
    // AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
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
            
            let usr = User()
            
            usr.username = userNameTextField.text!
            usr.firstName = firstNameTextField.text!
            usr.lastName = lastNameTextField.text!
            usr.email = emailTextField.text!
            usr.password = passwordTextField.text
            usr.about = aboutTextField.text!
            
            // New SDK
            let randomIndex = Int(arc4random_uniform(UInt32(userProfileImageURLs.count)))
            let imageURL = userProfileImageURLs[randomIndex]
            let userImage = Image(url: imageURL)
            usr.images = ["profile": userImage]
            
            // Create New User
            appDel.rxTapglue.createUser(usr).subscribe { (event) in
                switch event {
                case .Next(let newUser):
                    print(newUser.email)
                    // Login new User
                    self.appDel.rxTapglue.loginUser(usr.username!, password: usr.password!).subscribe({ (event) in
                        switch event {
                        case .Next(let newUser):
                            print(newUser.email)
                            print("Go to next screen")
                        case .Error(let error):
                            self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                        case .Completed:
                            print("Completed Login")
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popToRootViewControllerAnimated(false)
                            })
                        }
                    }).addDisposableTo(self.appDel.disposeBag)
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    break
                }
            }.addDisposableTo(self.appDel.disposeBag)
            
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

