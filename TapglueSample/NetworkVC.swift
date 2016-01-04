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

class NetworkVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [TGUser] = []
    
    var fromUsers: [TGUser] = []
    var toUsers: [TGUser] = []
    
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = [[:]]
    
    var facebookID: String!
    var twitterID: String!
    
    // Arr of FacebookFriends
    var friendsFromFacebook: [AnyObject]? = []
    
    let facebookLogInButton = FBSDKLoginButton()
    
    var twitterLogInButton = TWTRLogInButton()
    
    var checkingForPendingConnections = false
    
    var currentSegmentedControl = "pending"
    
    var sections = ["Find Friends", "Pending Requests"]
    var networks = ["Contacts", "Facebook", "Twitter"]
    let networkImages = ["AddressBookFilled", "FacebookFilled", "TwitterFilled"]

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
        
        // Setup searchBar
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.placeholder = "Username search"
        self.friendsTableView.tableHeaderView = resultSearchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        clearUsersArrayAndReloadTableView()
        checkForPendingConnections()
        
        // Reload the TableView
        reloadTableViewWithAnimation()
        
        self.resultSearchController.searchBar.hidden = false

    }
    
    override func viewDidDisappear(animated: Bool) {
        self.resultSearchController.searchBar.hidden = true
        self.resultSearchController.active = false
    }

    
    func clearUsersArrayAndReloadTableView(){
        self.fromUsers.removeAll(keepCapacity: false)
        self.toUsers.removeAll(keepCapacity: false)
        self.users.removeAll(keepCapacity: false)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTableView.reloadData()
        })
    }
    
    func checkForPendingConnections(){
        checkingForPendingConnections = true
        
        Tapglue.retrievePendingConncetionsForCurrentUserWithCompletionBlock { (incoming: [AnyObject]!, outgoing: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print("\nError retrievePendingConncetionsForCurrentUser: \(error)")
            } else {
                print("\nSuccess")
                print(incoming)
                print(outgoing)

                for inc in incoming {
                    self.fromUsers.append((inc as! TGConnection).fromUser)
                }
                for out in outgoing {
                    self.toUsers.append((out as! TGConnection).toUser)
                }
                print("\nFrom: \(self.fromUsers)")
                print("\nTo: \(self.toUsers)")
                
                self.users = self.fromUsers
                
                self.users.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1.username < contact2.username
                })
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.facebookLogInButton.hidden = true
                    
                    self.reloadTableViewWithAnimation()
                })
            }
        }
    }
}

extension NetworkVC: UITableViewDataSource {
    // Mark: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionStr: String?
        
        switch section {
        case 0:
            sectionStr = self.sections[section]
        case 1:
            sectionStr = self.sections[section]
        default: "to many sections"
        }
        
        return sectionStr
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                 return self.networks.count
            case 1:
                return self.users.count
            default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        
//        cell.userImageView.image = nil
        print("Section \(indexPath.section), Row \(indexPath.row)")
        
        switch indexPath.section {
        case 0:
            cell.userImageView.image = UIImage(named: self.networkImages[indexPath.row])
            cell.userNameLabel.text = self.networks[indexPath.row]
            self.friendsTableView.rowHeight = 60.0
        case 1:
            cell.selectionStyle = .None
            cell.userNameLabel.text = self.users[indexPath.row].firstName
            self.friendsTableView.rowHeight = 90.0
            let user = self.users[indexPath.row]
            cell.configureCellWithUserWithPendingConnection(user)
        default: "to many sections in creation"
        }

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.section == 0 {
            let fuVC =
            self.storyboard!.instantiateViewControllerWithIdentifier("FindUsersViewController")
                as! FindUsersVC
            
            fuVC.currentSelectedNetwork = networks[indexPath.row]
            
            self.navigationController!.pushViewController(fuVC, animated: true)
        }
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

extension NetworkVC: UISearchResultsUpdating {
    // Mark: -SearchBar
    func updateSearchResultsForSearchController(searchController: UISearchController){
        if (searchController.searchBar.text?.characters.count > 2) {
            Tapglue.searchUsersWithTerm(searchController.searchBar.text) { (users: [AnyObject]!, error: NSError!) -> Void in
                if users != nil && error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.users.removeAll(keepCapacity: false)
                        self.users = users as! [TGUser]
                        
                        self.reloadTableViewWithAnimation()
                    })
                } else if error != nil{
                    print("\nError searchUsersWithTerm: \(error)")
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
}
