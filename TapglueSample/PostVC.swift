//
//  PostVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 17/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class PostVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var postTextField: UITextField!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var postUIBarButton: UIBarButtonItem!
    
    var postText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        postTextField.becomeFirstResponder()
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        
        self.userImageView.image = UIImage(named: userImage.url)
        
        // Observer for keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Keyboard observer methods
    func keyboardWillShow(notification: NSNotification) {
        postUIBarButton.enabled = false
    }
    func keyboardWillHide(notification: NSNotification) {
        postUIBarButton.enabled = true
    }

    
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postText = textField.text
        textField.resignFirstResponder()
        return false
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}