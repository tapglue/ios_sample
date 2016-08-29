//
//  ProfileVC.swift
//  TapglueSample
//
//  Created by Onur Akpolat on 23.10.15.
//  Copyright © 2015 Tapglue. All rights reserved.
//

import UIKit
import Tapglue
import AWSS3

class ProfileVC: UIViewController, UITableViewDelegate, UINavigationControllerDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAboutLabel: UILabel!
    @IBOutlet weak var userFullnameLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileFeedTableView: UITableView!
    
    
    var activityFeed: [Activity] = []
    var posts: [Post] = []
    
    var postEditingText: String?
    var tempPost: Post?

    let imagePicker = UIImagePickerController()
    
    let tapRec = UITapGestureRecognizer()
    
    var selectedImageUrl: NSURL!
    var localFileName: String?
    var imageURL = NSURL()
    
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?
    var awsHost = "https://tapglue-sample.s3-eu-west-1.amazonaws.com/"
    
    var latestUUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listener
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Check for tapglue user
        if appDel.rxTapglue.currentUser != nil {
            
            refreshCurrentUser()
            
            showUserInfos()
        } else {
            // Show loginVC if User is nil
            self.navigationController?.performSegueWithIdentifier("loginSegue", sender: nil)
        }
        
        tapRec.addTarget(self, action: #selector(imageTappged))
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(tapRec)
    }
    
    func imageTappged() {
        print("Image was tapped")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Friends, Follower and Following buttons
    @IBAction func friendsCountButtonPressed(sender: UIButton) {
        // Retrieve friends
        appDel.rxTapglue.retrieveFriends().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)

    }
    
    @IBAction func followerCountButtonPressed(sender: UIButton) {
        // Retrieve followers
        appDel.rxTapglue.retrieveFollowers().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                
                self.navigationController?.pushViewController(usersViewController, animated: true)
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    @IBAction func followingCountButtonPressed(sender: UIButton) {
        // Retrieve your follows
        appDel.rxTapglue.retrieveFollowings().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                let storyboard = UIStoryboard(name: "Users", bundle: nil)
                let usersViewController = storyboard.instantiateViewControllerWithIdentifier("UsersViewController") as! UsersVC
                
                usersViewController.users = usr
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(usersViewController, animated: true)
                })
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    @IBAction func feedSegmentedChanged(sender: UISegmentedControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.profileFeedTableView.reloadData()
        }
    }
    
    func showUserInfos() {
        let usr = appDel.rxTapglue.currentUser!
        self.userNameLabel.text = usr.username
        self.userFullnameLabel.text = usr.firstName! + " " + usr.lastName!
        self.userAboutLabel.text = usr.about!
        
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
    }
    
    func getEventsAndPostsOfCurrentUser() {
        let currentUser = appDel.rxTapglue.currentUser!
        
        // Retrieve activities by user with ID
        appDel.rxTapglue.retrieveActivitiesByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let activities):
                print("Next")
                    self.activityFeed = activities
                    self.profileFeedTableView.reloadData()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
        // Retrieve activities by user with ID
        appDel.rxTapglue.retrievePostsByUser(currentUser.id!).subscribe { (event) in
            switch event {
            case .Next(let posts):
                print("Next")
                    self.posts = posts
                    self.profileFeedTableView.reloadData()
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
            }
        }.addDisposableTo(self.appDel.disposeBag)
        
    }
    
    func countFriendsFollowersAndFollowings() {
        friendsCountButton.setTitle(String(appDel.rxTapglue.currentUser!.friendCount!) + " Friends", forState: .Normal)
        followerCountButton.setTitle(String(appDel.rxTapglue.currentUser!.followerCount!) + " Follower", forState: .Normal)
        followingCountButton.setTitle(String(appDel.rxTapglue.currentUser!.followedCount!) + " Following", forState: .Normal)
    }
    
    func refreshCurrentUser() {
        print("---- Refreshing CURRENTUSER -----")
        
        // Refresh current User
        appDel.rxTapglue.refreshCurrentUser().subscribe { (event) in
            switch event {
            case .Next(let usr):
                print("Next")
                print("referesh \(usr) information of currentuser")
            case .Error(let error):
                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
            case .Completed:
                print("Do the action")
                self.countFriendsFollowersAndFollowings()
                
                self.getEventsAndPostsOfCurrentUser()
            }
        }.addDisposableTo(self.appDel.disposeBag)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postEditSegue" {
            let pVC: PostVC = segue.destinationViewController as! PostVC
            pVC.postBeginEditing = true
            pVC.tempPost = self.tempPost
        }

    }
}

extension ProfileVC: UITableViewDataSource {
    // MARK: -TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                numberOfRows = activityFeed.count
            case 1:
                numberOfRows = posts.count
            default: print("More then two segments")
            }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProfileFeedTableViewCell
        
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                cell.configureCellWithEvent(activityFeed[indexPath.row])
            case 1:
                cell.configureCellWithPost(posts[indexPath.row])
            default: print("More then two segments")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                print("Activity segment")
                if "tg_like" == activityFeed[indexPath.row].type! {
                    // Retrieve post with postID
                    let postID = activityFeed[indexPath.row].postId!
                    appDel.rxTapglue.retrievePost(postID).subscribe({ (event) in
                        switch event {
                        case .Next(let post):
                            let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                            let pdVC = storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                                    as! PostDetailVC
                            
                            pdVC.post = post
                            
                            self.appDel.rxTapglue.retrieveUser(post.userId!).subscribe { (event) in
                                switch event {
                                case .Next(let usr):
                                    print("Next")
                                    pdVC.usr = usr
                                    print("THE USER POST ID USERNAME: \(usr.username!)")
                                    
                                case .Error(let error):
                                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                                case .Completed:
                                    print("Do the action")
                                    self.navigationController?.pushViewController(pdVC, animated: true)
                                }
                            }.addDisposableTo(self.appDel.disposeBag)
                        case .Error(let error):
                            self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                        case .Completed:
                            print("Do the action")
                        }
                    }).addDisposableTo(self.appDel.disposeBag)
                }
            case 1:
                let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
                let pdVC =
                    storyboard.instantiateViewControllerWithIdentifier("PostDetailViewController")
                    as! PostDetailVC
                
                pdVC.post = posts[indexPath.row]
                
                pdVC.usr = posts[indexPath.row].user
                
                self.navigationController?.pushViewController(pdVC, animated: true)
            
            default: print("More then two segments")
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch feedSegmentedControl.selectedSegmentIndex {
            case 0:
                return false
            case 1:
                return true
            default: return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            
            self.tempPost = self.posts[indexPath.row]
            
            self.performSegueWithIdentifier("postEditSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.lightGrayColor()
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            
            // Delete post with postID
            self.appDel.rxTapglue.deletePost(self.posts[indexPath.row].id!).subscribe({ (event) in
                switch event {
                case .Next( _):
                    print("Next")
                case .Error(let error):
                    self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                case .Completed:
                    print("Do the action")
                    self.posts.removeAtIndex(indexPath.row)

                    
                    self.profileFeedTableView.reloadData()
                }
            }).addDisposableTo(self.appDel.disposeBag)

        }
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
}

extension ProfileVC: UIImagePickerControllerDelegate {
    // MARK: - UIImagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // If you like to change the aspect programmatically
            // myImageView.contentMode = .ScaleAspectFit
            userImageView.image = pickedImage
            
            //getting details of image
            let uploadFileURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            print(uploadFileURL)
            
            let imageName = uploadFileURL.lastPathComponent
            print(imageName)
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
            
            // getting local path
            let localPath = (documentDirectory as NSString).stringByAppendingPathComponent(imageName!)
            
            
            //getting actual image
            let originalImg = info[UIImagePickerControllerOriginalImage] as! UIImage
            let size = CGSizeApplyAffineTransform(originalImg.size, CGAffineTransformMakeScale(0.1, 0.1))
            let resizedImg = scaleImageToSize(originalImg, size: size)
            
            let data = UIImageJPEGRepresentation(resizedImg, 0.6)
            data!.writeToFile(localPath, atomically: true)
            
            let imageData = NSData(contentsOfFile: localPath)!
            imageURL = NSURL(fileURLWithPath: localPath)
            
            uploadData(imageData)
            
            
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadData(data: NSData) {
        //defining bucket and upload file name
        latestUUID = NSUUID().UUIDString
        
        let S3UploadKeyName: String = "public/" + latestUUID! + ".jpeg"
        let S3BucketName: String = "tapglue-sample"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.uploadData(
            data,
            bucket: S3BucketName,
            key: S3UploadKeyName,
            contentType: "image/jpg",
            expression: expression,
            completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
                if let error = task.error {
                    print("Error: %@",error.localizedDescription)
                }
                if let exception = task.exception {
                    print("Exception: %@",exception.description)
                }
                if let _ = task.result {
                    print("Upload Starting!")
                    
                    expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: NSProgress) in
                        dispatch_async(dispatch_get_main_queue(), {
                            print(Float(progress.fractionCompleted))
                        })
                    }
                }
                if task.completed {
                    print("UPLOAD COMPLETED")
                    
                    // Get currentUser, add new image and update currentUser
                    if let currentUser = self.appDel.rxTapglue.currentUser {
                        let userImage = Image(url: self.awsHost + S3UploadKeyName)
                        currentUser.images = ["profile": userImage]
                        print(currentUser.images)
                        print(S3UploadKeyName)
                        self.appDel.rxTapglue.updateCurrentUser(currentUser).subscribe({ (event) in
                            switch event {
                            case .Next(let usr):
                                print("Next")
                                print(usr.images!["profile"]!.url)
                            case .Error(let error):
                                self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                            case .Completed:
                                print("Do the action")
                                self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }).addDisposableTo(self.appDel.disposeBag)
                    }
                    
                    
                }
                if task.cancelled {
                    print("UPLOAD CANCELLED")
                }
                
                return nil
        }
    }
    
    func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}


