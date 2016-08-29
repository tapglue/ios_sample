//
//  PostVC.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 17/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import UIKit
import Tapglue
import WSTagsField
import AWSS3

class PostVC: UIViewController, UINavigationControllerDelegate {
    
    let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate

    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postUIBarButton: UIBarButtonItem!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var postText: String?
    
    var tagArr: [String] = []
    
    var postBeginEditing = false
    var tempPost: Post!
    
    @IBOutlet weak var wsTagsFieldView: UIView!
    
    let tagsField = WSTagsField()
    
    var selectedImageUrl: NSURL!
    var localFileName: String?
    
    var imageURL = NSURL()
    
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    var latestUUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable postUIBarButton
        postUIBarButton.enabled = false

        postTextField.becomeFirstResponder()
        
        addWSTagsField()
        
        if let profileImages = appDel.rxTapglue.currentUser?.images {
            self.userImageView.kf_setImageWithURL(NSURL(string: profileImages["profile"]!.url!)!)
        }
        
        // Prepare edit old post
        if postBeginEditing {
            postTextField.text = tempPost.attachments![0].contents!["en"]
            switch tempPost.visibility!.rawValue {
                case 10:
                    visibilitySegmentedControl.selectedSegmentIndex = 0
                case 20:
                    visibilitySegmentedControl.selectedSegmentIndex = 1
                case 30:
                    visibilitySegmentedControl.selectedSegmentIndex = 2
            default: print("More then expected switches")
            }
            
            if let tags = tempPost.tags {
                tagsField.addTags(tags)
            }
            
        }
        
        // Listener
        imagePicker.delegate = self
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        print("camera pressed")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        
        if postText?.characters.count > 2 {
            
            if tagsField.tags.count != 0 {
                for tag in tagsField.tags {
                    tagArr.append(tag.text)
                    print(tagArr.count)
                }
            }
            
            if postBeginEditing {
                let attachment = Attachment(contents: ["en":postText!], name: "status", type: .Text)
                tempPost.tags = tagArr
                tempPost.attachments = [attachment]
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        tempPost.visibility = Visibility.Private
                    case 1:
                        tempPost.visibility = Visibility.Connections
                    case 2:
                        tempPost.visibility = Visibility.Public
                    default: "More options then expected"
                }
                
                // Update edited post
                appDel.rxTapglue.updatePost(tempPost.id!, post: tempPost).subscribe({ (event) in
                    switch event {
                    case .Next(let post):
                        print(post)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        break
                    }
                }).addDisposableTo(self.appDel.disposeBag)

            } else {
                var attachments: [Attachment] = []
                if postImageView.image != nil {
                    let postImageURL = "public/" + latestUUID! + ".jpeg"
                    attachments.append(Attachment(contents: ["en":postText!], name: "status", type: .Text))
                    attachments.append(Attachment(contents: ["en":postImageURL], name: "image", type: .URL))
                } else {
                    attachments.append(Attachment(contents: ["en":postText!], name: "status", type: .Text))
                }
                
                let post = Post(visibility: .Connections, attachments: attachments)
                post.tags = tagArr
                
                switch visibilitySegmentedControl.selectedSegmentIndex {
                    case 0:
                        post.visibility = Visibility.Private
                    case 1:
                        post.visibility = Visibility.Connections
                    case 2:
                        post.visibility = Visibility.Public
                    default: "More options then expected"
                }
                
                // Create new post
                appDel.rxTapglue.createPost(post).subscribe({ (event) in
                    switch event {
                    case .Next(let post):
                        print(post)
                    case .Error(let error):
                        self.appDel.printOutErrorMessageAndCode(error as? TapglueError)
                    case .Completed:
                        break
                    }
                }).addDisposableTo(self.appDel.disposeBag)
            }

            resignKeyboardAndDismissVC()
        } else {
            showAlert()
        }
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        resignKeyboardAndDismissVC()
    }
 
    func resignKeyboardAndDismissVC(){
        postTextField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Post Error", message: "You can not post empty or less then two characters of text.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    func addWSTagsField() {
        tagsField.placeholder = "Add hashtags to your post"
        tagsField.font = UIFont(name:"HelveticaNeue-Light", size: 14.0)
        tagsField.tintColor = UIColor(red:0.18, green:0.28, blue:0.3, alpha:1.0)
        tagsField.textColor = .whiteColor()
        tagsField.selectedColor = .lightGrayColor()
        tagsField.selectedTextColor = .whiteColor()
        tagsField.spaceBetweenTags = 4.0
        tagsField.padding.left = 0
        tagsField.padding.top = wsTagsFieldView.frame.height/8
        tagsField.frame = CGRect(x: 0, y: 0, width: wsTagsFieldView.frame.width, height: wsTagsFieldView.frame.height)
        
        wsTagsFieldView.addSubview(tagsField)
    }
}

extension PostVC: UITextFieldDelegate {
    // Mark: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let textFieldText = textField.text
        
        postText = textFieldText!
                
        print(postText)
        
        textField.resignFirstResponder()
        
        return false
    }
    // If textField has more then 3 characters enable posUIBarbutton
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location >= 3 {
            postUIBarButton.enabled = true
            postText = textField.text
        } else {
            postUIBarButton.enabled = false
        }
        
        // Keep it true
        return true
    }
}

extension PostVC: UIImagePickerControllerDelegate {
    
    // MARK: - UIImagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // If you like to change the aspect programmatically
            // myImageView.contentMode = .ScaleAspectFit
            postImageView.image = pickedImage
            
            cameraButton.setImage(nil, forState: .Normal)
            
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
            let size = CGSizeApplyAffineTransform(originalImg.size, CGAffineTransformMakeScale(0.4, 0.4))
            let resizedImg = scaleImageToSize(originalImg, size: size)
            
            let data = UIImageJPEGRepresentation(resizedImg, 0.6)
            data!.writeToFile(localPath, atomically: true)
            
            let imageData = NSData(contentsOfFile: localPath)!
            imageURL = NSURL(fileURLWithPath: localPath)
            
            uploadData(imageData)
            
            picker.dismissViewControllerAnimated(true, completion: nil)
            
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

