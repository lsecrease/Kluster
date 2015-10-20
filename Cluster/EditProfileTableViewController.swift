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

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageOverlay: UIVisualEffectView!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    private var profilePic: UIImage!
    private var coverPic: UIImage!
    
    let numberOfRowsAtSection: [Int] = [4, 2]
    
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
        
        
    }
    
    //MARK: Text View Handler
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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

    @IBAction func deleteAccountButtonTapped(sender: DesignableButton) {
        
        println("Delete Account Button Tapped")
    }
   
}