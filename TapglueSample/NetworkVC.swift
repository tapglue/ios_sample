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
//import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit

class NetworkVC: UIViewController, UITableViewDelegate {
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var users: [User] = []
    var fromUsers: [User] = []
    var toUsers: [User] = []
    
    var resultSearchController: UISearchController!
    
    let contactStore = CNContactStore()
    var contactEmails: [String] = []
    var contacts: [[String:String]] = []
    
    var searchingForUser = false
    
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
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.placeholder = "search"
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
    
    @IBAction func conctactsBtnPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "FindUsers", bundle: nil)
        let fuVC = storyboard.instantiateViewControllerWithIdentifier("FindUsersViewController")
                as! FindUsersVC
        //TO-DO
        fuVC.currentSelectedNetwork = "Contacts"
        self.navigationController!.pushViewController(fuVC, animated: true)
    }
    
    @IBAction func facebookBtnPressed(sender: UIButton) {
        
    }
    
    @IBAction func twitterBtnPressed(sender: UIButton) {
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
        
        appDel.rxTapglue.retrievePendingConnections().subscribe { (event) in
            switch event {
            case .Next(let connections):
                print("Next")
                
                for inc in connections.incoming! {
                    print("incomging user: \(inc.userFrom)")
                    self.fromUsers.append(inc.userFrom!)
                }
                
                for out in connections.outgoing! {
                    self.toUsers.append(out.userTo!)
                }
                
                print("From user: \(self.fromUsers)")
                print("To user: \(self.toUsers)")
                
                // As an example we are just showing inbound friends request
                self.users = self.fromUsers
                
                self.users.sortInPlace({ (contact1, contact2) -> Bool in
                    return contact1.username < contact2.username
                })
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.reloadTableViewWithAnimation()
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // OldSDK TODO: update pending request to new sdk
//        Tapglue.retrievePendingConncetionsForCurrentUserWithCompletionBlock { (incoming: [AnyObject]!, outgoing: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                print("\nError retrievePendingConncetionsForCurrentUser: \(error)")
//            } else {
//                for inc in incoming {
//                    self.fromUsers.append((inc as! TGConnection).fromUser)
//                }
//                for out in outgoing {
//                    self.toUsers.append((out as! TGConnection).toUser)
//                }
//                print("\nFrom: \(self.fromUsers)")
//                print("\nTo: \(self.toUsers)")
//                
//                self.users = self.fromUsers
//                
//                
//                self.users.sortInPlace({ (contact1, contact2) -> Bool in
//                    return contact1.username < contact2.username
//                })
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.reloadTableViewWithAnimation()
//                })
//            }
//        }
    }
}

extension NetworkVC: UITableViewDataSource {
    // Mark: -TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NetworkUserTableViewCell
        
            if searchingForUser {
                cell.searchingForUser = true
                cell.configureCellWithUserToFriendOrFollow(self.users[indexPath.row])
            } else {
                cell.selectionStyle = .None
                cell.userNameLabel.text = self.users[indexPath.row].firstName
                let user = self.users[indexPath.row]
                cell.configureCellWithUserWithPendingConnection(user)
            }

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "FindUsers", bundle: nil)
            let fuVC = storyboard.instantiateViewControllerWithIdentifier("FindUsersViewController")
                as! FindUsersVC
            //TO-DO
            fuVC.currentSelectedNetwork = networks[indexPath.row]
            
            self.navigationController!.pushViewController(fuVC, animated: true)
        }
    }
    
    func reloadTableViewWithAnimation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.friendsTableView,
                duration:0.3,
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
            // NewSDK
            appDel.rxTapglue.searchUsersForSearchTerm(searchController.searchBar.text!).subscribe({ (event) in
                switch event {
                case .Next(let usr):
                    print("Next")
                    self.searchingForUser = true
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.users.removeAll(keepCapacity: false)
                        self.users = usr
                        
                        self.reloadTableViewWithAnimation()
                    })
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                }
                
            }).addDisposableTo(self.appDel.disposeBag)
            
        } else {
            // Clear tableView aslong a user was not found
            searchingForUser = true
            users.removeAll(keepCapacity: false)
            self.friendsTableView.reloadData()
        }
        
        if !searchController.active {
            clearUsersArrayAndReloadTableView()
            checkForPendingConnections()
            searchingForUser = false
        }
    }
}
