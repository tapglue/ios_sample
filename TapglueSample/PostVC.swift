//
//  PostVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 17/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import WSTagsField

class PostVC: UIViewController {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate

    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postUIBarButton: UIBarButtonItem!
    
    var postText: String?
    
    var tagArr: [String] = []
    
    var postBeginEditing = false
    var tempPost: Post!
    
    @IBOutlet weak var wsTagsFieldView: UIView!
    
    let tagsField = WSTagsField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable postUIBarButton
        postUIBarButton.enabled = false

        postTextField.becomeFirstResponder()
        
        addWSTagsField()
        
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
        
        // Prepare edit old post
        if postBeginEditing {
            postTextField.text = tempPost.attachments![0].contents!["en"]
            switch tempPost.visibility!.rawValue {
                case 10:
                    visibilitySegmentedControl.selectedSegmentIndex = 0
                case 20:
                    visibilitySegmentedControl.selectedSegmentIndex = 1
                case 30:
                    visibilitySegmentedControl.selectedSegmentIndex = 2
            default: print("More then expected switches")
            }
            var wsTagArr: [WSTag] = []
            for tag in tempPost.tags! {
                let wsTag = WSTag(tag)
                wsTagArr.append(wsTag)
            }
            tagsField.addTags(wsTagArr)
        }
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        
        if postText?.characters.count > 2 {
            
            if tagsField.tags.count != 0 {
                for tag in tagsField.tags {
                    tagArr.append(tag.text)
                    print(tagArr.count)
                }
            }
            
            if postBeginEditing {
                let attachment = Attachment(contents: ["en":postText!], name: "status", type: .Text)
                tempPost.tags = tagArr
                tempPost.attachments = [attachment]
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        tempPost.visibility = Visibility.Private
                    case 1:
                        tempPost.visibility = Visibility.Connections
                    case 2:
                        tempPost.visibility = Visibility.Public
                    default: "More options then expected"
                }
                
                // Update edited post
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
                
                // Create new post
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
        
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    func addWSTagsField() {
        tagsField.placeholder = "Add hashtags to your post"
        tagsField.font = UIFont(name:"HelveticaNeue-Light", size: 14.0)
        tagsField.tintColor = UIColor(red:0.18, green:0.28, blue:0.3, alpha:1.0)
        tagsField.textColor = .whiteColor()
        tagsField.selectedColor = .lightGrayColor()
        tagsField.selectedTextColor = .whiteColor()
        tagsField.spaceBetweenTags = 4.0
        tagsField.padding.left = 0
        tagsField.frame = CGRect(x: 0, y: 0, width: wsTagsFieldView.frame.width, height: wsTagsFieldView.frame.height)
        
        wsTagsFieldView.addSubview(tagsField)
    }
}

extension PostVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let textFieldText = textField.text
        
        postText = textFieldText!
                
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

