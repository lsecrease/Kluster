//
//  ProfileViewController.swift
//  Cluster
//
//  Created by lsecrease on 9/22/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Photos
import Spring
import ParseUI

class ProfileViewController: UIViewController {

    var user: PFUser! = PFUser.current()
    
    @IBOutlet weak var coverImage: PFImageView!
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let editProfileController = storyboard.instantiateViewController(withIdentifier: "EditProfileTableViewController")
        self.present(editProfileController, animated: true, completion: nil)
    }
    
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroller.contentInset = UIEdgeInsetsMake(0, 0, 400, 0)
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2
        self.profileImageView.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = editButton.bounds.width / 2
        editButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadProfileInfo()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = 400
        self.scroller.contentSize.width = 0
    }

    @IBAction func klusterNowButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func addPhotoClicked(_ sender: DesignableButton) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.addPhotoClicked(sender)
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
                        let image = images[0]
                        let imageData = UIImagePNGRepresentation(image!)
                        let file = PFFile.init(name: "avatar.png", data: imageData!)
                        self.profileImageView.image = image
                        let user = PFUser.current()
                        user?.setObject(file!, forKey: "avatar")
                        user?.saveInBackground(block: { (save: Bool, error: Error?) -> Void in
                            if (error != nil) {
                                print("We have an error...")
                            }
                        })
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .cancel))
            
            present(controller, animated: true, completion: nil)
            
        }

        
    }
    
    func presentCamera() {

    }
    
    fileprivate func loadProfileInfo() {
        // Load profile info
        self.profileImageView.file = self.user.object(forKey: "avatar") as? PFFile
        self.profileImageView.loadInBackground()
        
        self.coverImage.file = self.user.object(forKey: "coverImage") as? PFFile
        self.coverImage.loadInBackground()
        
        let firstName = self.user.object(forKey: "firstName") as! String
        let lastName = self.user.object(forKey: "lastName") as! String
        self.nameLabel.text = firstName + " " + lastName
        
        if let location = self.user.object(forKey: "location") as? String {
            self.locationLabel.text = location
        } else {
            self.locationLabel.text = "🌎"
        }
        
        if let age = self.user.object(forKey: "age") as? Int {
            self.ageLabel.text = "\(age) yrs"
        } else {
            self.ageLabel.text = "🤔"
        }

        if let bio = self.user.object(forKey: "biography") as? String {
            self.biographyLabel.text = bio
        } else {
            self.biographyLabel.text = self.randomBiographyString()
        }
    }
    
    fileprivate func randomBiographyString() -> String {
        let firstName = self.user.object(forKey: "firstName") as! String
        return "Surely \(firstName) is clever, but they haven't shared anything with us."
    }
}
