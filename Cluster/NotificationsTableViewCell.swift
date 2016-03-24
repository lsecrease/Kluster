//
//  NotificationsTableViewCell.swift
//  Cluster
//
//  Created by Lawrence Olivier on 11/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol NotificationsTableViewCellDelgate {
    func didPressAcceptButton(cell: NotificationsTableViewCell)
    func didPressDeclineButton(cell: NotificationsTableViewCell)
}

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var invitationTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var acceptButton: DesignableButton!
    @IBOutlet weak var declineButton: DesignableButton!
   
    var delegate: NotificationsTableViewCellDelgate?
    
    @IBAction func acceptButtonClicked(sender: DesignableButton) {
        
        print("Accept Button Clicked")
        self.delegate?.didPressAcceptButton(self)
        
        
        //Animation
        self.animate(sender)
    }
    
    @IBAction func declineButtonClicked(sender: DesignableButton) {
        
         print("Decline Button Clicked")
        self.delegate?.didPressDeclineButton(self)
        
        //Animation
        self.animate(sender)
    }
    
    private func animate(sender: DesignableButton?) {
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
