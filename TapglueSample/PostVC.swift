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
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate

    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postUIBarButton: UIBarButtonItem!
    
    var postText: String?
    
    var tagArr: [String]?
    
    var postBeginEditing = false
    var tempPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare postUIBarButton
        postUIBarButton.enabled = false

        postTextField.becomeFirstResponder()
        
        // TO-DO: Change to new sdk
//        var userImage = TGImage()
//        userImage = User.currentUser().images.valueForKey("profilePic") as! TGImage
//        self.userImageView.kf_setImageWithURL(NSURL(string: userImage.url)!)
        
        // Old post will be edited
//        if postBeginEditing {
//            postTextField.text = tempPost.attachments[0].contents!["en"] as? String
//            switch tempPost.visibility.rawValue {
//                case 10:
//                    visibilitySegmentedControl.selectedSegmentIndex = 0
//                case 20:
//                    visibilitySegmentedControl.selectedSegmentIndex = 1
//                case 30:
//                    visibilitySegmentedControl.selectedSegmentIndex = 2
//            default: print("More then expected switches")
//            }
//        }
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        
        
        
        if postText?.characters.count > 2 {
            let tempStr = postTextField.text!
            
            postText = tempStr.withoutTags(tempStr)
            tagArr = tempStr.filterTagsAsStrings(tempStr)
            
            if postBeginEditing {
                // Prepare TGPost Edit
                
                // TODO: Currently unable to update attachments, no editing post possible atm
                let attachment = Attachment(contents: ["en":postText!], name: "status", type: .Text)
                tempPost.tags = tagArr
                tempPost.attachments?.append(attachment)
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        tempPost.visibility = Visibility.Private
                    case 1:
                        tempPost.visibility = Visibility.Connections
                    case 2:
                        tempPost.visibility = Visibility.Public
                    default: "More options then expected"
                }
                
                // NewSDK
                appDel.rxTapglue.updatePost(tempPost.id!, post: tempPost).subscribe({ (event) in
                    switch event {
                    case .Next(let post):
                        print(post)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        break
                    }
                }).addDisposableTo(self.appDel.disposeBag)

            } else {
                // Prepare Post creation
                let attachment = Attachment(contents: ["en":postText!], name: "status", type: .Text)
                let post = Post(visibility: .Connections, attachments: [attachment])
                post.tags = tagArr
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        post.visibility = Visibility.Private
                    case 1:
                        post.visibility = Visibility.Connections
                    case 2:
                        post.visibility = Visibility.Public
                    default: "More options then expected"
                }
                
                // NewSDK
                appDel.rxTapglue.createPost(post).subscribe({ (event) in
                    switch event {
                    case .Next(let post):
                        print(post)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        break
                    }
                }).addDisposableTo(self.appDel.disposeBag)
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

