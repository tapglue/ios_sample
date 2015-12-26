//
//  EditProfileVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class EditProfileVC: UIViewController, UITableViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var updateUIBarButton: UIBarButtonItem!
    
    let tapglueUser = TGUser.currentUser()

    var defaultTGUser = TGUser()
    
    let userInfoTitle = ["Username:", "Firstname:", "Lastname:", "About:", "Email:"]
    var userInformation = [TGUser.currentUser().username, TGUser.currentUser().firstName, TGUser.currentUser().lastName, "edit about", TGUser.currentUser().email]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Observer for keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func updateButtonPressed(sender: UIBarButtonItem) {
        // Update user information
        TGUser.currentUser().saveWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n\(error)")
                } else {
                    print("Successful: \n\(success)")
                }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        Tapglue.logoutWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
            if error != nil {
                print(error)
            } else {
                print(success)
            }
        }
    }
    
    // Mark: Keyboard methods(update button will enabled, if keyboard is dismissed)
    func keyboardWillShow(notification: NSNotification) {
        updateUIBarButton.enabled = false
    }
    func keyboardWillHide(notification: NSNotification) {
        updateUIBarButton.enabled = true
    }
}

extension EditProfileVC: UITableViewDataSource {
    // MARK: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EditProfilTableViewCell
        
        cell.userInfoTitleLabel.text = userInfoTitle[indexPath.row]
        cell.userInfoEditTextField.text = userInformation[indexPath.row]
        cell.userInfoEditTextField.tag = indexPath.row
        
        return cell
    }
}