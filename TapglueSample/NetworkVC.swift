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
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit

class NetworkVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FBSDKLoginButtonDelegate  {
    
    @IBOutlet weak var networkButton: UIButton!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var networkSegmentedControl: UISegmentedControl!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [TGUser] = []
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
//    var facebookEmails: [String] = []
//    var twitterEmails: [String] = []
    
    var facebookID: String!
    var twitterID: String!
    
    // Array of friends to add to your friends
    var friendThisPeople: [AnyObject]? = []
    var friendsFromTwitter: [AnyObject]? = []
    
    let friendsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends?fields=id", parameters: nil)
    
    let twitterLogInButton = TWTRLogInButton(logInCompletion: { session, error in
        if (session != nil) {
            print("signed in as \(session!.userName)");
        } else {
            print("error: \(error!.localizedDescription)");
        }
    })
    
    let facebookLogInButton = FBSDKLoginButton()
    
    

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
        
        configureFacebook()
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
        // Set all buttons to hidden
        twitterLogInButton.hidden = true
        facebookLogInButton.hidden = true
        networkButton.hidden = true
        
        switch networkSegmentedControl.selectedSegmentIndex {
            case 0:
                print("Still needs implementation")
            case 1:
                clearUsersArrayAndReloadTableView()
                contactsSegmentWasPicked()
            
            case 2:
                clearUsersArrayAndReloadTableView()
                facebookSegmentWasPicked()
            
            case 3:
                clearUsersArrayAndReloadTableView()
                twitterSegmentWasPicked()
            
            case 4:
                clearUsersArrayAndReloadTableView()
                moreSegmentWasPicked()

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
        let facebookPermission = defaults.objectForKey("facebookPermission") as! Bool
        print(facebookPermission)
        
        if facebookPermission {
            print("facebookPermissionGranted")
            self.facebookLogInButton.hidden = true
            self.returnUserFriendsData()
        } else {
            
            // Show twitterLoginButton
            facebookLogInButton.hidden = false
            facebookLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
            facebookLogInButton.layer.masksToBounds = true
            facebookLogInButton.layer.cornerRadius = 4
            self.view.addSubview(facebookLogInButton)
        }
    }
    
    // Twitter Permission check if granted search for friends and reload TableView
    func twitterSegmentWasPicked(){
        // get default checked array
        let twitterPermission = defaults.objectForKey("twitterPermission") as! Bool
        print(twitterPermission)
        
        if twitterPermission {
            print("twitterPermissionGranted")
            self.networkButton.hidden = true
            
        } else {
            
            // Show twitterLoginButton
            twitterLogInButton.hidden = false
            twitterLogInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 25, 200, 50)
            self.view.addSubview(twitterLogInButton)
        }
    }
    
    func moreSegmentWasPicked(){
        networkButton.hidden = false
        networkButton.setTitle("More", forState: .Normal)
        networkButton.backgroundColor = UIColor(red: 0.227, green: 0.227, blue: 0.227, alpha: 1)
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
    
    func configureFacebook(){
        facebookLogInButton.readPermissions = ["public_profile", "email", "user_friends"];
        facebookLogInButton.delegate = self
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large), id"]).startWithCompletionHandler { (connection, result, error) -> Void in

            if error != nil{
                print(error)
            } else {
                //            let strFirstName: String = (result.objectForKey("first_name") as? String)!
                //            let strLastName: String = (result.objectForKey("last_name") as? String)!
                //            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                //            self.lblName.text = "Welcome, \(strFirstName) \(strLastName)"
                //            self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
                
                self.facebookID = (result.objectForKey("id") as? String)!
                print(self.facebookID)
                self.defaults.setObject(true, forKey: "facebookPermission")
            }
            
        }
        returnUserFriendsData()
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
//        ivUserProfileImage.image = nil
//        lblName.text = ""
    }
    
    // start returning facebook friends to tapglue
    func returnUserFriendsData(){
        
        friendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil){
                // error
                print("Error: \(error)")
                print("Connection: \(connection)")
            } else {
                let resultdict = result as! NSDictionary
                //                print("Result Dict: \(resultdict)")
                
                let data: NSArray = resultdict.objectForKey("data") as! NSArray
                //                print("Result Data: \(data)")
                for i in 0 ..< data.count
                {
                    let valueDict: NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    print("Friend id value is \(id)")
                    
                    // save facebook friend ids inside AnyObject array
                    self.friendThisPeople?.append(id)
                }
                // add tapglue social id from facebook
                let currentUser = TGUser.currentUser()
                currentUser.setSocialId(self.facebookID, forKey: "facebook")
                currentUser.saveWithCompletionBlock({ (success: Bool, error: NSError!) -> Void in
                    print(success)
                })
                // add friends that are found
                Tapglue.searchUsersOnSocialPlatform("facebook", withSocialUsersIds: self.friendThisPeople, andCompletionBlock: { (facebookUsers: [AnyObject]!, error: NSError!) -> Void in
                    
                    if error != nil {
                        print("\nError happened")
                        print(error)
                    }
                    else {
                        print("\nSuccess happened")
                        print(facebookUsers)
                        self.users.removeAll(keepCapacity: false)
                        self.users = facebookUsers as! [TGUser]
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.facebookLogInButton.hidden = true
                            self.friendsTableView.reloadData()
                        })
                    }
                })
            }
        })
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
