//
//  MessageTableViewCell.swift
//  Cluster
//
//  Created by Michael Fellows on 10/28/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit
import ParseUI

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}
