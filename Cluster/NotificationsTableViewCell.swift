//
//  NotificationsTableViewCell.swift
//  Cluster
//
//  Created by Lawrence Olivier on 11/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var invitationTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var acceptButton: DesignableButton!
    @IBOutlet weak var declineButton: DesignableButton!
   
    
    
    
    
    @IBAction func acceptButtonClicked(sender: DesignableButton) {
        
        print("Accept Button Clicked")
        
        
        //Animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }
    
    @IBAction func declineButtonClicked(sender: DesignableButton) {
        
         print("Decline Button Clicked")
        
        
        //Animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }

}
