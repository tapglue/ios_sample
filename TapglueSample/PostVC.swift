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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        postTextField.becomeFirstResponder()
        
        var userImage = TGImage()
        userImage = TGUser.currentUser().images.valueForKey("avatar") as! TGImage
        
        self.userImageView.image = UIImage(named: userImage.url)
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
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
        let postText = postTextField.text!
        publicPost.addAttachment(TGAttachment(text: postText, andName: "status"))
        
        Tapglue.createPost(publicPost) { (success: Bool, error: NSError!) -> Void in
            if error != nil {
                print(error)
            } else {
                print(success)
            }
        }
        
        resignKeyboardAndDismissVC()
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        resignKeyboardAndDismissVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func resignKeyboardAndDismissVC(){
        postTextField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
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
