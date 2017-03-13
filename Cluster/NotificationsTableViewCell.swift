//
//  NotificationsTableViewCell.swift
//  Cluster
//
//  Created by Lawrence Olivier on 11/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit
import Spring
import ParseUI

protocol NotificationsTableViewCellDelgate {
    func didPressAcceptButton(_ cell: NotificationsTableViewCell)
    func didPressDeclineButton(_ cell: NotificationsTableViewCell)
}

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var invitationTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var acceptButton: DesignableButton!
    @IBOutlet weak var declineButton: DesignableButton!
   
    var delegate: NotificationsTableViewCellDelgate?
    
    @IBAction func acceptButtonClicked(_ sender: DesignableButton) {
        
        print("Accept Button Clicked")
        self.delegate?.didPressAcceptButton(self)
        
        
        //Animation
        self.animate(sender)
    }
    
    @IBAction func declineButtonClicked(_ sender: DesignableButton) {
        
         print("Decline Button Clicked")
        self.delegate?.didPressDeclineButton(self)
        
        //Animation
        self.animate(sender)
    }
    
    fileprivate func animate(_ sender: DesignableButton?) {
        if let sender = sender {
            sender.animation = "pop"
            sender.curve = "spring"
            sender.duration = 1.5
            sender.damping = 0.1
            sender.velocity = 0.2
            sender.animate()
        }
    }

}
