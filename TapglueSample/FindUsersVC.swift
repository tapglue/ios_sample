//
//  FindUsersVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 04/01/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Contacts

class FindUsersVC: UIViewController, UITableViewDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var currentSelectedNetwork: String!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = []
    
    var users: [User] = []
    
    var fromUsers: [User] = []
    var toUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch currentSelectedNetwork {
        case "Contacts":
            self.searchForUserByEmail()
        default: print("default")
        }
    }
    
    // SearchForUserByEmail and reload tableview if user was found
    func searchForUserByEmail() {
        readAddressBookByEmail()
        
        appDel.rxTapglue.searchEmails(contactEmails).subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                self.users = usr
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Completed")
                
                self.friendsTableView.reloadData()
            }
            }.addDisposableTo(self.appDel.disposeBag)
    }
    
    // ReadAddressBookByEmail and saving contacts in dicionary
    func readAddressBookByEmail(){
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey])) {
                (contact, cursor) -> Void in
                if (!contact.emailAddresses.isEmpty){
                    
                    var itemCount = 0
                    for item in contact.emailAddresses {
                        itemCount += 1
                        if itemCount <= 1 {
                            self.contacts.append(["givenName": contact.givenName, "email" : String(item.value)])
                            self.contactEmails.append(String(item.value))
                        }
                    }
                }
                
                // Sort Contacts by GivenName
                self.contacts.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1["givenName"] < contact2["givenName"]
                })
            }
        }
        catch{
            print("Handle the error please")
        }
    }
}

extension FindUsersVC: UITableViewDataSource {
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSelectedNetwork {
        case "Contacts":
            return contacts.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FindUsersTableViewCell
        
        switch currentSelectedNetwork {
        case "Contacts":
            
            // Show users that use the app in the right cell
            for usr in users {
                let tempContact = contacts[indexPath.row]
                
                if usr.email == tempContact["email"] {
                    cell.configureCellWithUserFromContactsThatUsesApp(contacts[indexPath.row], user: usr)
                    break
                } else {
                    cell.configureCellWithUserFromContacts(contacts[indexPath.row])
                }
            }
            
        default: print("more then expected segments")
        }
        
        return cell
    }
    
    func reloadTableViewWithAnimation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.friendsTableView,
                duration:0.1,
                options:.TransitionCrossDissolve,
                animations:
                { () -> Void in
                    self.friendsTableView.reloadData()
                },
                completion: nil);
        })
    }
}
