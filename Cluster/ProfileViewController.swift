//
//  ProfileViewController.swift
//  Cluster
//
//  Created by lsecrease on 9/22/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = editButton.bounds.width / 2
        editButton.layer.masksToBounds = true
    }

 
}
