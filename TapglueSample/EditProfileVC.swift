//
//  EditProfileVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 14/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue

class EditProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var updateUIBarButton: UIBarButtonItem!
    
    let tapglueUser = TGUser.currentUser()

    var defaultTGUser = TGUser()
    
    let userInfoTitle = ["Username", "Firstname", "Lastname", "About", "Email"]
    var userUserInfo = [TGUser.currentUser().username, TGUser.currentUser().firstName, TGUser.currentUser().lastName, "edit about", TGUser.currentUser().email]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Observer for keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func updateButtonPressed(sender: UIBarButtonItem) {
        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaultTGUser = defaults.objectForKey("tgUser") as! TGUser
//        
//        Tapglue.updateUser(TGUser.currentUser().sa) { (success: Bool, error: NSError!) -> Void in
//            if error != nil {
//                print("Error happened\n\(error)")
//            }
//            else {
//                print("Successful: \n\(success)")
//            }
//        }
        
        // Update user information
        TGUser.currentUser().saveWithCompletionBlock { (success: Bool, error: NSError!) -> Void in
                if error != nil {
                    print("Error happened\n\(error)")
                }
                else {
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
    

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userInfoTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EditProfilTableViewCell
        
        // Configure the cell...
        cell.userInfoTitleLabel.text = userInfoTitle[indexPath.row]
        cell.userInfoEditTextField.text = userUserInfo[indexPath.row]
        cell.userInfoEditTextField.tag = indexPath.row
        
        return cell
    }
    
    // Mark: Keyboard observer methods
    func keyboardWillShow(notification: NSNotification) {
        updateUIBarButton.enabled = false
    }
    func keyboardWillHide(notification: NSNotification) {
        updateUIBarButton.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
