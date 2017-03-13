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
    
    let hud = BLMultiColorLoader.init(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    var invites = [Invite]()
    
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
        self.hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGray]
        self.view.addSubview(self.hud)
        
        self.fetchInvites()
    }
    
    fileprivate func fetchInvites() {
        
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
    
    fileprivate func showNetworkError() {
        let alertController = UIAlertController.init(title: "Error", message: "Unable to fetch invites.", preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Notification"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationsTableViewCell
        
        let invite = self.invites[indexPath.row]
        cell.delegate = self
        
        cell.selectionStyle = .none
        
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
    func didPressAcceptButton(_ cell: NotificationsTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
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
            self.invites.remove(at: indexPath.row)
            
            // Reload data
            self.tableView.reloadData()
        }
    }
    
    func didPressDeclineButton(_ cell: NotificationsTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
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
            self.invites.remove(at: indexPath.row)
            
            // Reload data
            self.tableView.reloadData()
        }
    }
}

extension NotificationsViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        let text = "Join me on Kluster!"
        if let url = URL.init(string: "http://kluster.com") {
            let shareActivity = UIActivityViewController.init(activityItems: [text, url], applicationActivities: nil)
            self.present(shareActivity, animated: true, completion: nil)
        }

    }
}

extension NotificationsViewController : DZNEmptyDataSetSource {
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You don't have any notifications."
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 17.0),
            NSParagraphStyleAttributeName : paragraph]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Womp womp..."
        let attributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 19.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = "Invite Friends"
        let attributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 19.0),
            NSForegroundColorAttributeName: UIColor.orange]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20.0
    }
}
