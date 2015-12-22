//
//  NetworkVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 21/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import Contacts

class NetworkVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating  {
    
    @IBOutlet weak var networkButton: UIButton!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var networkSegmentedControl: UISegmentedControl!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [TGUser] = []
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var facebookEmails: [String] = []
    var twitterEmails: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.friendsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        self.friendsTableView.reloadData()
        
        // hide button
        networkButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = false;

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = true;
        self.resultSearchController.active = false;
    }
    
    @IBAction func networkButtonPressed(sender: UIButton) {
        switch networkSegmentedControl.selectedSegmentIndex {
        case 0:
            print("Pending")
            
        case 1:
            print("Contacts")
            
            for email in contactEmails {
                print(email)
            }
            
            defaults.setObject(true, forKey: "contactsPermission")
            searchForUserByEmail()
        case 2:
            print("Facebook")
            
        case 3:
            print("Twitter")
            
        case 4:
            print("More")
            
        default: print("More segments then expected")
        }
    }
    
    @IBAction func networkSegmentedChanged(sender: UISegmentedControl) {
        print(sender.tag)
        switch networkSegmentedControl.selectedSegmentIndex {
            
        case 0:
            print("Pending")
            networkButton.hidden = true
        case 1:
            print("Contacts")
            clearUsersArrayAndReloadTableView()

            contactsSegmentWasPicked()
        case 2:
            print("Facebook")
            clearUsersArrayAndReloadTableView()
            
            facebookSegmentWasPicked()
        case 3:
            print("Twitter")
            clearUsersArrayAndReloadTableView()
            
            twitterSegmentWasPicked()
        case 4:
            print("More")
            clearUsersArrayAndReloadTableView()
            
            networkButton.hidden = false
            networkButton.setTitle("More", forState: .Normal)
            networkButton.backgroundColor = UIColor(red: 0.227, green: 0.227, blue: 0.227, alpha: 1)
        default: print("Segments index wrong")
        }
    }
    
    /*
    * TableView Methods
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        let user = self.users[indexPath.row]
        cell.configureCellWithUser(user)
        return cell
        
    }
    
    /*
    * Searchbar Methods
    */
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        
        if (searchController.searchBar.text?.characters.count > 2) {
            Tapglue.searchUsersWithTerm(searchController.searchBar.text) { (users: [AnyObject]!, error: NSError!) -> Void in
                if users != nil && error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.users.removeAll(keepCapacity: false)
                        self.users = users as! [TGUser]
                        self.friendsTableView.reloadData()
                    })
                } else if error != nil{
                    print("Error happened\n")
                    print(error)
                }
            }
        } else {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
        
        if !searchController.active {
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
    }
    
    // Contacts Permission check if granted search for friends and reload TableView
    func contactsSegmentWasPicked(){
        // get default checked array
        let contactPermission = defaults.objectForKey("contactsPermission") as! Bool
        print(contactPermission)
        
        if contactPermission {
            print("contactPermissionGranted")
            self.networkButton.hidden = true
            self.searchForUserByEmail()
        } else {
            self.networkButton.hidden = false
            self.networkButton.setTitle("Contacts", forState: .Normal)
            self.networkButton.backgroundColor = UIColor.brownColor()
        }
    }
    
    // Facebook Permission check if granted search for friends and reload TableView
    func facebookSegmentWasPicked(){
        // get default checked array
        let contactPermission = defaults.objectForKey("facebookPermission") as! Bool
        print(contactPermission)
        
        if contactPermission {
            print("contactPermissionGranted")
            self.networkButton.hidden = true
        } else {
            networkButton.hidden = false
            networkButton.setTitle("Facebook", forState: .Normal)
            networkButton.backgroundColor = UIColor(red: 0.231, green: 0.349, blue: 0.596, alpha: 1)
        }
    }
    
    // Twitter Permission check if granted search for friends and reload TableView
    func twitterSegmentWasPicked(){
        // get default checked array
        let contactPermission = defaults.objectForKey("twitterPermission") as! Bool
        print(contactPermission)
        
        if contactPermission {
            print("contactPermissionGranted")
            self.networkButton.hidden = true
            
        } else {
            networkButton.hidden = false
            networkButton.setTitle("Twitter", forState: .Normal)
            networkButton.backgroundColor = UIColor(red: 0.251, green: 0.6, blue: 1, alpha: 1)
        }
    }
    
    // SearchForUserByEmail and reload tableview if user was found
    func searchForUserByEmail() {
        readAddressBookByEmail()
        
        Tapglue.searchUsersWithEmails(contactEmails) { (users: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError happened")
                print(error)
            }
            else {
                print("\nSuccess happened")
                print(users)
                self.users.removeAll(keepCapacity: false)
                self.users = users as! [TGUser]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.networkButton.hidden = true
                    self.friendsTableView.reloadData()
                })
            }
        }
    }
    
    // ReadAddressBookByEmail and saving contacts in dicionary
    func readAddressBookByEmail(){
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey])) {
                (contact, cursor) -> Void in
                if (!contact.emailAddresses.isEmpty){
                    
                    for item in contact.emailAddresses {
                        self.contactEmails.append(String(item.value))
                    }
                }
            }
        }
        catch{
            print("Handle the error please")
        }
    }
    
    func clearUsersArrayAndReloadTableView(){
        self.users.removeAll(keepCapacity: false)
        self.friendsTableView.reloadData()
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
