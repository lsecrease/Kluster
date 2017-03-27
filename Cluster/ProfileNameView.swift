//
//  ProfileNameView.swift
//  Cluster
//
//  Created by Michael Fellows on 3/2/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation
import Spring
import ParseUI


// MARK: - ProfileNameView

class ProfileNameView : UIView {
    
    // MARK: Variables and constants
    
    var avatarImageView: PFImageView = PFImageView()
    var nameLabel: UILabel = UILabel()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .clear
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 17) //UIFont(name: "BondoluoPeek", size: 18)
        self.nameLabel.textColor = .white
        
        self.addSubview(self.avatarImageView)
        self.addSubview(self.nameLabel)
        
        let views = ["avatarImageView" : self.avatarImageView,
                           "nameLabel" : self.nameLabel] as [String : Any]
        
        let spacing = 5.0
        let height = Double.init(self.frame.size.height)
        let imageDiameter =  height - (2 * spacing)
        let metrics = ["imageDiameter": imageDiameter as AnyObject, "spacing": spacing as AnyObject] as [String : AnyObject]
        
        // Set the corner radius of the avatar view
        self.avatarImageView.layer.cornerRadius = CGFloat(imageDiameter / 2.0)
        
        let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[avatarImageView(==imageDiameter)]-(spacing)-[nameLabel]-(spacing)-|",
                                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                                         metrics:metrics, views: views)
        
        let avatarY = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[avatarImageView(==imageDiameter)]-(spacing)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        let labelY = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[nameLabel]-(spacing)-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        self.addConstraints(hConstraint)
        self.addConstraints(avatarY)
        self.addConstraints(labelY)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: UI
    
    func layoutForUser(_ user: PFUser?) {
        if let user = user {
            self.nameLabel.text = user.object(forKey: "firstName") as? String
            self.avatarImageView.file = user.object(forKey: "avatarThumbnail") as? PFFile
            self.avatarImageView.loadInBackground()
        }
    }
}
