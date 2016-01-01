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
        userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
        self.userImageView.downloadedFrom(link: userImage.url, contentMode: .ScaleAspectFill)
        
        // Prepare postUIBarButton
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
                    print("\nError: \(error)")
                } else {
                    print("\nSucccess: \(success)")
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
        let alertController = UIAlertController(title: "Post Error", message: "You can not post empty or less then two characters of text.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        
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
    // If textField has more then 3 characters enable posUIBarbutton
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location >= 3 {
            postUIBarButton.enabled = true
            postText = textField.text
        } else {
            postUIBarButton.enabled = false
        }
        
        // Keep it true
        return true
    }
}
