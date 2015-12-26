//
//  PostVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 17/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostVC: UIViewController {

    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postUIBarButton: UIBarButtonItem!
    
    var postText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTextField.becomeFirstResponder()
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        self.userImageView.image = UIImage(named: userImage.url)
        
        postUIBarButton.enabled = false
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        if postText?.characters.count > 2 {
            let publicPost = TGPost()
            
            switch visibilitySegmentedControl.selectedSegmentIndex {
                case 0:
                    publicPost.visibility = TGVisibility.Private
                case 1:
                    publicPost.visibility = TGVisibility.Connection
                case 2:
                    publicPost.visibility = TGVisibility.Public
                default: "More options then expected"
            }
            
            postText = postTextField.text!
            
            // Add attachment to TGPost
            publicPost.addAttachment(TGAttachment(text: postText, andName: "status"))
            
            Tapglue.createPost(publicPost) { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print(success)
                }
            }
            
            resignKeyboardAndDismissVC()
        } else {
            showAlert()
        }
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        resignKeyboardAndDismissVC()
    }
 
    func resignKeyboardAndDismissVC(){
        postTextField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert() {
        // Init UIAlertController
        let alertController = UIAlertController(title: "Post Error", message: "You can not post empty or less then two characters of text.", preferredStyle: .Alert)
        
        // Init UIAlertAction
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // You can add a action if you like
            print("OK button was pressed, dissmiss AlertView.")
        }
        
        // Add UIAlertAction to UIAlertController
        alertController.addAction(OKAction)
        
        // Present UIAlertController
        self.presentViewController(alertController, animated: true) {
        }
    }
}

extension PostVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postText = textField.text
        
        textField.resignFirstResponder()
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 2 {
            postUIBarButton.enabled = true
            postText = textField.text
        }
        
        if range.location <= 2{
            postUIBarButton.enabled = false
        }
        
        return true
    }
}
