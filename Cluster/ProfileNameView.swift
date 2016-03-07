//
//  ProfileNameView.swift
//  Cluster
//
//  Created by Michael Fellows on 3/2/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class ProfileNameView : UIView {
    
    var avatarImageView: PFImageView = PFImageView()
    var nameLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .clearColor()
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.nameLabel.font = UIFont.systemFontOfSize(17) //UIFont(name: "BondoluoPeek", size: 18)
        self.nameLabel.textColor = .whiteColor()
        
        self.addSubview(self.avatarImageView)
        self.addSubview(self.nameLabel)
        
        let views = ["avatarImageView" : self.avatarImageView,
                           "nameLabel" : self.nameLabel]
        
        let spacing = 5.0
        let height = Double.init(self.frame.size.height)
        let imageDiameter =  height - (2 * spacing)
        let metrics = ["imageDiameter": imageDiameter, "spacing": spacing] as [String : AnyObject]
        
        // Set the corner radius of the avatar view
        self.avatarImageView.layer.cornerRadius = CGFloat(imageDiameter / 2.0)
        
        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[avatarImageView(==imageDiameter)]-(spacing)-[nameLabel]-(spacing)-|",
                                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                                         metrics:metrics, views: views)
        
        let avatarY = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[avatarImageView(==imageDiameter)]-(spacing)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        let labelY = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[nameLabel]-(spacing)-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        self.addConstraints(hConstraint)
        self.addConstraints(avatarY)
        self.addConstraints(labelY)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layoutForUser(user: PFUser!) {
        self.nameLabel.text = user.objectForKey("firstName") as? String
        self.avatarImageView.file = user.objectForKey("avatarThumbnail") as? PFFile
        self.avatarImageView.loadInBackground()
    }
}
