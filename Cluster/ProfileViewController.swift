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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scroller: UIScrollView!
    
    private var profilePic: UIImage!
    
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        scroller.contentInset = UIEdgeInsetsMake(0, 0, 400, 0)
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = editButton.bounds.width / 2
        editButton.layer.masksToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = 400
        self.scroller.contentSize.width = 0
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
                        self.profilePic = images[0]
                        self.profileImage.image = self.profilePic
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .Cancel))
            
            presentViewController(controller, animated: true, completion: nil)
            
        }

        
    }
    
    func presentCamera() {
        
    }
}
