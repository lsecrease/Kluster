//
//  EditProfileTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/14/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Photos

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var coverImage: PFImageView!
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var profileImageOverlay: UIVisualEffectView!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var logOutButton: DesignableButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var user: PFUser! = PFUser.currentUser()
    private var profilePic: UIImage!
    private var coverPic: UIImage!
    
    let numberOfRowsAtSection: [Int] = [5, 3]
    
    @IBAction func saveProfileInformationPressed(sender: AnyObject) {
        if (self.validAttributes()) {
            let firstName = self.firstNameTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let lastName = self.lastNameTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let ageString = self.ageTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let location = self.locationTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let biography = self.aboutMeTextView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            
            self.user.setObject(firstName!, forKey: "firstName")
            self.user.setObject(lastName!, forKey: "lastName")
            self.user.setObject(Int(ageString!)!, forKey: "age")
            self.user.setObject(location!, forKey: "location")
            self.user.setObject(biography!, forKey: "biography")
            self.user.saveEventually()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController.init(title: "Save Error", message: "Please enter all your information before we can save your profile.", preferredStyle: .Alert)
            let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.masksToBounds = true
        
        profileImageOverlay.layer.cornerRadius = profileImageOverlay.bounds.width / 2
        profileImageOverlay.layer.masksToBounds = true
        
        //For the Text View Handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        // Change the keyboard type for the age text field
        self.ageTextField.keyboardType = .DecimalPad

        // Update the profile with user information
        self.loadImages()
        self.updateTextFields()
    }
    
    private func loadImages() {
        self.profileImage.file = self.user.objectForKey("avatar") as? PFFile
        self.profileImage.loadInBackground()
        
        // Set a placeholder image
        self.coverImage.image = UIImage(named: "fashion")
        self.coverImage.file = self.user.objectForKey("coverImage") as? PFFile
        self.coverImage.loadInBackground()
    }
    
    // Sets the initial tableview textfield values
    private func updateTextFields() {
        self.firstNameTextField.text = self.user.objectForKey("firstName") as? String
        self.lastNameTextField.text = self.user.objectForKey("lastName") as? String
        
        if let age = self.user.objectForKey("age") as? Int {
            self.ageTextField.text = "\(age)"
        }
        
        self.locationTextField.text = self.user.objectForKey("location") as? String
        
        // Update the about me placeholder
        self.aboutMeTextView.placeholder = "Tell us about yourself..."
        self.aboutMeTextView.text = self.user.objectForKey("biography") as? String
    }
    
    private func validAttributes() -> Bool {
        let firstName = self.firstNameTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let lastName = self.lastNameTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let age = self.ageTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let location = self.locationTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let biography = self.aboutMeTextView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        return firstName?.length > 0 && lastName?.length > 0 && age?.length > 0 && location?.length > 0 && biography?.length > 0
    }
    
    //MARK: Text View Handler
    
    func keyboardWillHide(notification: NSNotification) {
        self.aboutMeTextView.contentInset = UIEdgeInsetsZero
        self.aboutMeTextView.scrollIndicatorInsets = UIEdgeInsetsZero
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        self.aboutMeTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.aboutMeTextView.scrollIndicatorInsets = self.aboutMeTextView.contentInset
        
    }


    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }
        
        return rows
        
    }

    @IBAction func profileImageChange(sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileImageChange(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .Authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo or Video", comment: "ActionTitle"), secondaryTitle: NSLocalizedString("Use This One", comment: "ActionTitle"), handler: { (_) -> () in
                
                self.presentCamera()
                
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profilePic = images[0]
                        self.profileImage.image = self.profilePic
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .Cancel))
            
            presentViewController(controller, animated: true, completion: nil)
            
        }
    }
    @IBAction func coverImageChange(sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileImageChange(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .Authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo or Video", comment: "ActionTitle"), secondaryTitle: NSLocalizedString("Use This One", comment: "ActionTitle"), handler: { (_) -> () in
                
                self.presentCamera()
                
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.coverPic = images[0]
                        self.coverImage.image = self.coverPic
                        
                        let imageData = UIImagePNGRepresentation(self.coverPic)
                        let file = PFFile.init(name: "cover.png", data: imageData!)
                        self.user.setObject(file!, forKey: "coverImage")
                        self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if (error != nil) {
                                let alert = UIAlertController.init(title: "Error", message: "Unable to update cover image.", preferredStyle: .Alert)
                                let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
                                alert.addAction(okAction)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        })
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .Cancel))
            
            presentViewController(controller, animated: true, completion: nil)
            
        }

    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func logOutButtonTapped(sender: AnyObject) {
        PFUser.logOut()
        self.goToLoginController()
    }
    
    @IBAction func deleteAccountButtonTapped(sender: DesignableButton) {
        
        print("Delete Account Button Tapped")
        let alert = UIAlertController.init(title: "Are You Sure?", message: "All of the Klusters you created will also be destoryed. This operation cannot be undone.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction.init(title: "Delete", style: .Destructive) { (action) -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            KlusterDataSource.deleteUserAccount({ (object, error) -> Void in
                hud.removeFromSuperview()
                if (error != nil) {
                    self.showAccountDeleteError()
                } else {
                    self.goToLoginController()
                }
            })
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
   
    private func showAccountDeleteError() {
        let alert = UIAlertController.init(title: "Error", message: "Something went wrong when deleting your account.", preferredStyle: .Alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .Default) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func goToLoginController() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginVC
    }
}
