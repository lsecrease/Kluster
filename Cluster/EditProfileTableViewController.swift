//
//  EditProfileTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/14/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Spring
import Photos
import ParseUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    var user: PFUser! = PFUser.current()
    fileprivate var profilePic: UIImage!
    fileprivate var coverPic: UIImage!
    
    let numberOfRowsAtSection: [Int] = [5, 3]
    
    @IBAction func saveProfileInformationPressed(_ sender: AnyObject) {
        if (self.validAttributes()) {
            let firstName = self.firstNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let lastName = self.lastNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let ageString = self.ageTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let location = self.locationTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let biography = self.aboutMeTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            
            self.user.setObject(firstName!, forKey: "firstName")
            self.user.setObject(lastName!, forKey: "lastName")
            self.user.setObject(Int(ageString!)!, forKey: "age")
            self.user.setObject(location!, forKey: "location")
            self.user.setObject(biography!, forKey: "biography")
            self.user.saveEventually()
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController.init(title: "Save Error", message: "Please enter all your information before we can save your profile.", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.masksToBounds = true
        
        profileImageOverlay.layer.cornerRadius = profileImageOverlay.bounds.width / 2
        profileImageOverlay.layer.masksToBounds = true
        
        //For the Text View Handler
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileTableViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Change the keyboard type for the age text field
        self.ageTextField.keyboardType = .decimalPad

        // Update the profile with user information
        self.loadImages()
        self.updateTextFields()
    }
    
    fileprivate func loadImages() {
        self.profileImage.file = self.user.object(forKey: "avatar") as? PFFile
        self.profileImage.loadInBackground()
        
        // Set a placeholder image
        self.coverImage.image = UIImage(named: "fashion")
        self.coverImage.file = self.user.object(forKey: "coverImage") as? PFFile
        self.coverImage.loadInBackground()
    }
    
    // Sets the initial tableview textfield values
    fileprivate func updateTextFields() {
        self.firstNameTextField.text = self.user.object(forKey: "firstName") as? String
        self.lastNameTextField.text = self.user.object(forKey: "lastName") as? String
        
        if let age = self.user.object(forKey: "age") as? Int {
            self.ageTextField.text = "\(age)"
        }
        
        self.locationTextField.text = self.user.object(forKey: "location") as? String
        
        // Update the about me placeholder
        self.aboutMeTextView.placeholder = "Tell us about yourself..."
        self.aboutMeTextView.text = self.user.object(forKey: "biography") as? String
    }
    
    fileprivate func validAttributes() -> Bool {
        let firstName = self.firstNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lastName = self.lastNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let age = self.ageTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let location = self.locationTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let biography = self.aboutMeTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return firstName?.length > 0 && lastName?.length > 0 && age?.length > 0 && location?.length > 0 && biography?.length > 0
    }
    
    //MARK: Text View Handler
    
    func keyboardWillHide(_ notification: Notification) {
        self.aboutMeTextView.contentInset = UIEdgeInsets.zero
        self.aboutMeTextView.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        let userInfo = notification.userInfo ?? [:]
        self.aboutMeTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.aboutMeTextView.scrollIndicatorInsets = self.aboutMeTextView.contentInset
        
    }


    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }
        
        return rows
        
    }

    @IBAction func profileImageChange(_ sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.profileImageChange(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo or Video", comment: "ActionTitle"), secondaryTitle: NSLocalizedString("Use This One", comment: "ActionTitle"), handler: { (_) -> () in
                
                self.presentCamera()
                
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profilePic = images[0]
                        self.profileImage.image = self.profilePic
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .cancel))
            
            present(controller, animated: true, completion: nil)
            
        }
    }
    @IBAction func coverImageChange(_ sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.profileImageChange(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .authorized {
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
                        self.user.saveInBackground(block: { (success, error) -> Void in
                            if (error != nil) {
                                let alert = UIAlertController.init(title: "Error", message: "Unable to update cover image.", preferredStyle: .alert)
                                let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .cancel))
            
            present(controller, animated: true, completion: nil)
            
        }

    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func logOutButtonTapped(_ sender: AnyObject) {
        PFUser.logOut()
        self.goToLoginController()
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: DesignableButton) {
        
        print("Delete Account Button Tapped")
        let alert = UIAlertController.init(title: "Are You Sure?", message: "All of the Klusters you created will also be destoryed. This operation cannot be undone.", preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) -> Void in
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            KlusterDataSource.deleteUserAccount({ (object, error) -> Void in
                hud.removeFromSuperview()
                if (error != nil) {
                    self.showAccountDeleteError()
                } else {
                    self.goToLoginController()
                }
            })
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
   
    fileprivate func showAccountDeleteError() {
        let alert = UIAlertController.init(title: "Error", message: "Something went wrong when deleting your account.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func goToLoginController() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = loginVC
    }
}
