//
//  NotificationsViewController.swift
//  Cluster
//
//  Created by Lawrence Olivier on 11/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let hud = BLMultiColorLoader.init(frame: CGRectMake(0, 0, 40.0, 40.0))
    var invites = [Invite]()
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        // Hack to not show table cell separators when there's no data
        self.tableView.tableFooterView = UIView()

        // Add the progress hud before fetching invites
        self.hud.center = self.view.center
        self.hud.lineWidth = 2.0
        self.hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGrayColor()]
        self.view.addSubview(self.hud)
        
        self.fetchInvites()
    }
    
    private func fetchInvites() {
        
        // Add hud
        self.hud.startAnimation()
        
        KlusterDataSource.fetchInvites { (object, error) -> Void in
            
            // Remove hud
            self.hud.stopAnimation()
            
            if error != nil {
                self.showNetworkError()
            } else {
                
                // Initialize invites
                var i = [Invite]()
                if let object = object as? [PFObject] {
                    for o in object {
                        let invite = Invite.init(object: o)
                        i.append(invite)
                    }
                }
                
                // Reload data
                self.invites = i
                self.tableView.reloadData()
            }
        }
    }
    
    private func showNetworkError() {
        let alertController = UIAlertController.init(title: "Error", message: "Unable to fetch invites.", preferredStyle: .Alert)
        let alertAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invites.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Notification"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NotificationsTableViewCell
        
        let invite = self.invites[indexPath.row]
        cell.delegate = self
        
        cell.selectionStyle = .None
        
        cell.dateLabel.text = invite.dateString
        cell.userNameLabel.text = invite.userName
        cell.invitationTypeLabel.text = invite.klusterInviteString()
        
        // Update the profile image
        cell.profileImageView.clipsToBounds = true
        cell.profileImageView.layer.cornerRadius = 17.5
        
        cell.profileImageView.image = nil
        cell.profileImageView.file = invite.avatarFile
        cell.profileImageView.loadInBackground()
        
        return cell
    }
}

extension NotificationsViewController: NotificationsTableViewCellDelgate {
    func didPressAcceptButton(cell: NotificationsTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let invite = self.invites[indexPath.row]
            
            // Accept the invite...
            
            KlusterDataSource.acceptInvitation(invite.kluster?.id, invitationId: invite.objectId,
                completion: { (object, error) -> Void in
                    if let object = object {
                        print("\(object)")
                    } else {
                        print("Error joining Kluster.")
                    }
            })
            
            // Remove from the table
            self.invites.removeAtIndex(indexPath.row)
            
            // Reload data
            self.tableView.reloadData()
        }
    }
    
    func didPressDeclineButton(cell: NotificationsTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let invite = self.invites[indexPath.row]
            
            // Accept the invite...
            KlusterDataSource.declineKlusterInvitation(invite.objectId, completion: { (object, error) -> Void in
                if let object = object {
                    print("\(object)")
                } else {
                    print("Error declining Kluster invite.")
                }
            })
            
            // Remove from the table
            self.invites.removeAtIndex(indexPath.row)
            
            // Reload data
            self.tableView.reloadData()
        }
    }
}

extension NotificationsViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        let text = "Join me on Kluster!"
        if let url = NSURL.init(string: "http://kluster.com") {
            let shareActivity = UIActivityViewController.init(activityItems: [text, url], applicationActivities: nil)
            self.presentViewController(shareActivity, animated: true, completion: nil)
        }

    }
}

extension NotificationsViewController : DZNEmptyDataSetSource {
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You don't have any notifications."
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(17.0),
            NSParagraphStyleAttributeName : paragraph]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Womp womp..."
        let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(19.0),
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let text = "Invite Friends"
        let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(19.0),
            NSForegroundColorAttributeName: UIColor.orangeColor()]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func spaceHeightForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return 20.0
    }
}
