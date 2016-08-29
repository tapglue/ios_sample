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
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var updateUIBarButton: UIBarButtonItem!
        
    let userInfoTitle = ["Username:", "Firstname:", "Lastname:", "About:", "Email:"]
    var userInformation = []
    var currentUser: User!
    var updatedUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = appDel.rxTapglue.currentUser
        updatedUser = currentUser
        
        userInformation = [currentUser.username!, currentUser.firstName!, currentUser.lastName!, currentUser.about!, currentUser.email!]

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileVC.keyboardWillShow(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func updateButtonPressed(sender: UIBarButtonItem) {
        // Update current user information
        appDel.rxTapglue.updateCurrentUser(updatedUser!).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                print(usr.about)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        appDel.rxTapglue.logout().subscribe { (event) in
            switch event {
            case .Next(let element):
                print(element)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }.addDisposableTo(self.appDel.disposeBag)
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
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EditProfilTableViewCell
        
        cell.userInfoTitleLabel.text = userInfoTitle[indexPath.row]
        cell.userInfoEditTextField.text = userInformation[indexPath.row] as? String
        cell.userInfoEditTextField.tag = indexPath.row
        cell.delegate = self
        
        return cell
    }
}

extension EditProfileVC: UpdateUserDelegate {
    // Mark: - Custom delegate to update user information if there is any changes
    func updateUsername(tf: UITextField) {
        updatedUser.username = tf.text
    }
    func updateFirstname(tf: UITextField) {
        updatedUser.firstName = tf.text
    }
    func updateLastname(tf: UITextField) {
        updatedUser.lastName = tf.text
    }
    func updateAbout(tf: UITextField) {
        updatedUser.about = tf.text
    }
    func updateEmail(tf: UITextField) {
        updatedUser.email = tf.text
    }
}
