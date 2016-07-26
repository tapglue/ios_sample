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
    
    var tagArr: [String]?
    
    var postBeginEditing = false
    var postTGPost: TGPost!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare postUIBarButton
        postUIBarButton.enabled = false

        postTextField.becomeFirstResponder()
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("profilePic") as! TGImage
        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
        
        // Old post will be edited
        if postBeginEditing {
            postTextField.text = postTGPost.attachments[0].contents!["en"] as? String
            switch postTGPost.visibility.rawValue {
                case 10:
                    visibilitySegmentedControl.selectedSegmentIndex = 0
                case 20:
                    visibilitySegmentedControl.selectedSegmentIndex = 1
                case 30:
                    visibilitySegmentedControl.selectedSegmentIndex = 2
            default: print("More then expected switches")
            }
        }
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        let post = TGPost()
        
        
        if postText?.characters.count > 2 {
            let tempStr = postTextField.text!
            
            postText = tempStr.withoutTags(tempStr)
            tagArr = tempStr.filterTagsAsStrings(tempStr)
            post.tags = tagArr
            
            if postBeginEditing {
                // Prepare TGPost Edit
                // TODO: If content cann be changed, uncomment
//                postTGPost!.attachments[0].contents = postText
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        postTGPost!.visibility = TGVisibility.Private
                    case 1:
                        postTGPost!.visibility = TGVisibility.Connection
                    case 2:
                        postTGPost!.visibility = TGVisibility.Public
                    default: "More options then expected"
                }
                
                Tapglue.updatePost(postTGPost, withCompletionBlock: { (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        print("\nError createPost: \(error)")
                    } else {
                        print("\nSucccess: \(success)")
                    }
                })
            } else {
                // Prepare TGPost
                post.addAttachment(TGAttachment.init(text: ["en": postText!], andName: "status"))
                post.tags = tagArr
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        post.visibility = TGVisibility.Private
                    case 1:
                        post.visibility = TGVisibility.Connection
                    case 2:
                        post.visibility = TGVisibility.Public
                    default: "More options then expected"
                }
                
                
                
                Tapglue.createPost(post) { (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        print("\nError createPost: \(error)")
                    } else {
                        print("\nSucccess: \(success)")
                    }
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
        let textFieldText = textField.text
        
        postText = textFieldText?.withoutTags(textFieldText!)
        tagArr = textFieldText?.filterTagsAsStrings(textFieldText!)
        
        print(postText)
        
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
