//
//  ProfileViewController.swift
//  Cluster
//
//  Created by lsecrease on 9/22/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Photos

class ProfileViewController: UIViewController {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var ageLabel: UILabel!
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load profile info
        let user = PFUser.currentUser()
        self.profileImageView.file = user!.objectForKey("avatar") as? PFFile
        self.profileImageView.loadInBackground()
        
        let firstName = user?.objectForKey("firstName") as! String
        let lastName = user?.objectForKey("lastName") as! String
        self.nameLabel.text = firstName + " " + lastName
        
        //Side Menu
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        scroller.contentInset = UIEdgeInsetsMake(0, 0, 400, 0)
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2
        self.profileImageView.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = editButton.bounds.width / 2
        editButton.layer.masksToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = 400
        self.scroller.contentSize.width = 0
    }

    @IBAction func klusterNowButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
 
    @IBAction func addPhotoClicked(sender: DesignableButton) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.addPhotoClicked(sender)
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
                        let image = images[0]
                        let imageData = UIImagePNGRepresentation(image!)
                        let file = PFFile.init(name: "avatar.png", data: imageData!)
                        self.profileImageView.image = image
                        let user = PFUser.currentUser()
                        user?.setObject(file!, forKey: "avatar")
                        user?.saveInBackgroundWithBlock({ (save: Bool, error: NSError?) -> Void in
                            if ((error) != nil) {
                                print("We have an error...")
                            }
                        })
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .Cancel))
            
            presentViewController(controller, animated: true, completion: nil)
            
        }

        
    }
    
    func presentCamera() {
        
    }
}
