//
//  MembersTableViewCell.swift
//  Cluster
//
//  Created by Michael Fellows on 10/28/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit
import ParseUI

class MembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: PFImageView!
    
    var user: PFUser! {
        didSet {
            updateUI()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.avatarImageView.contentMode = .scaleAspectFill
    }
    
    fileprivate func updateUI() {
        let firstName = self.user.object(forKey: "firstName") as! String
        let lastName = self.user.object(forKey: "lastName") as! String
        self.nameLabel.text = firstName + " " + lastName
        self.ageLabel.text = "Age coming soon"
    }
}
