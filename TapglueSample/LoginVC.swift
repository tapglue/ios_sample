//
//  LoginVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 25.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue

class LoginVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var avatarOneImageView: UIImageView!
    @IBOutlet weak var avatarTwoImageView: UIImageView!
    @IBOutlet weak var avatarThreeImageView: UIImageView!
    
    var currentAvatar: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarOneImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imagePressed:"))
        avatarTwoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imagePressed:"))
        avatarThreeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imagePressed:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        if userNameTextField.text?.characters.count > 2 && passwordTextField.text?.characters.count > 2 && currentAvatar != nil{
            
            let username = userNameTextField.text!
            let password = passwordTextField.text!
            
            let tapglueUser = TGUser()
            tapglueUser.username = username
            tapglueUser.setPassword(password)
            
            let userImage = TGImage()
            userImage.url = currentAvatar
            
            tapglueUser.images.setValue(userImage, forKey: "avatar")
            
            Tapglue.createAndLoginUser(tapglueUser, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n")
                    print(error)
                } else {
                    print(success)
                    print("User was created\n")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.popToRootViewControllerAnimated(false)
                        
                    })
                }
            })
        } else {
            print("Please enter all details and select an avatar")
        }
    }
    
    func imagePressed(sender: UITapGestureRecognizer) {
        avatarOneImageView.backgroundColor = UIColor.clearColor()
        avatarTwoImageView.backgroundColor = UIColor.clearColor()
        avatarThreeImageView.backgroundColor = UIColor.clearColor()
        
        
        let currentTag = sender.view?.tag
        
        switch currentTag! {
        case 0:
            print("First Avatar Pressed")
            avatarOneImageView.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
            currentAvatar = "avatar-1"
        case 1:
            print("Second Avatar Pressed")
            avatarTwoImageView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
            currentAvatar = "avatar-6"
        case 2:
            print("Third Avatar Pressed")
            avatarThreeImageView.backgroundColor = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0)
            currentAvatar = "avatar-3"
        default:
            "No avatar was pressed"
        }
    }
    

}
