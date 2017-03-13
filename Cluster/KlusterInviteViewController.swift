//
//  KlusterInviteViewController.swift
//  Cluster
//
//  Created by Michael Fellows on 3/9/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit
import Spring

class KlusterInviteViewController : UITableViewController {
    
    var users = [PFUser]()
    var usersToInvite = [PFUser]()
    var kluster: Kluster!
    let hud = BLMultiColorLoader.init(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hack to remove cell separators when no data is present
        self.tableView.tableFooterView = UIView()
        
        // Update the nav bar
        self.navigationItem.title = "Invite Friends"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(KlusterInviteViewController.inviteDonePressed(_:)))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Add the hud before fetching friends..
        // Add progress HUD
        self.hud.center = self.view.center
        self.hud.lineWidth = 2.0
        self.hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGray]
        self.view.addSubview(hud)
        
        self.hud.startAnimation()
        
        self.fetchFacebookFriends()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KlusterInviteTableViewCell") as! KlusterInviteTableViewCell
        
        let user = self.users[indexPath.row]
        if let firstName = user.object(forKey: "firstName") as? String, let lastName = user.object(forKey: "lastName") as? String {
            cell.profileNameLabel.text = "\(firstName) \(lastName)"
        }
        
        cell.profileImageView.image = nil
        cell.profileImageView.file = user.object(forKey: "avatarThumbnail") as? PFFile
        cell.profileImageView.loadInBackground()
        
        // Format cell
        cell.selectionStyle = .none
        cell.profileImageView.layer.cornerRadius = 17.5
        cell.profileImageView.clipsToBounds = true
        
        // Invite button actions
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: #selector(KlusterInviteViewController.inviteButtonPressed(_:)), for: .touchUpInside)
        
        
        if (self.usersToInvite.contains(user)) {
            cell.inviteButton.setTitle("Invited", for: UIControlState())
        } else {
            cell.inviteButton.setTitle("Invite", for: UIControlState())
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // Mark - Selectors
    
    func inviteButtonPressed(_ sender: DesignableButton) {
        let index = sender.tag
        let user = self.users[index]
        print("\(user) selected...")
        
        if self.usersToInvite.contains(user) {
            if let index = self.usersToInvite.index(of: user) {
                self.usersToInvite.remove(at: index)
            }
        } else {
            // add friend
            self.usersToInvite.append(user)
        }
        
        self.updateTableState()
    }
    
    func inviteDonePressed(_ sender: UIBarButtonItem) {
        // TODO: Send invites...
        
        var userIds = [String]()
        for user in self.usersToInvite {
            if let userId = user.objectId {
                userIds.append(userId)
            }
        }
        
        // Disable the bar button item... 
        if let barButtonItem = self.navigationItem.rightBarButtonItem {
            barButtonItem.isEnabled = false
        }
        
        // Add hud - Already added to the view hierarchy
        self.hud.startAnimation()
        
        KlusterDataSource.inviteUsersToKluster(userIds, klusterId: self.kluster.id) { (object, error) -> Void in
            
            // Enable the bar button item...
            if let barButtonItem = self.navigationItem.rightBarButtonItem {
                barButtonItem.isEnabled = true
            }
            
            // Stop animating the hud..
            self.hud.stopAnimation()
            
            if error != nil {
                let alertController = UIAlertController.init(title: "Invite Error", message: "Something went wrong when inviting users to this Kluster. Please try again.", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            }
        }
    }
        
    
    // Mark - Private
    
    fileprivate func updateTableState() {
        
        // Reload tableview data
        self.tableView.reloadData()
        
        // Determine the activation state of the invite button
        if let navItem = self.navigationItem.rightBarButtonItem {
            navItem.isEnabled = self.usersToInvite.count > 0
        }
    }
    
    fileprivate func fetchFacebookFriends() {
        // Fetch Facebook Friends
        let request = FBSDKGraphRequest.init(graphPath: "me/friends", parameters: nil, httpMethod: "GET")
        request?.start { (connection, result, error) -> Void in
            
            if let result = result as? NSDictionary {
                
                var facebookUserIDs = [String]()
                
                if let friends = result["data"] as? [AnyObject] {
                    for friend in friends {
                        if let friend = friend as? [String: AnyObject] {
                            if let id = friend["id"] as? String {
                                facebookUserIDs.append(id)
                            }
                        }
                    }
                }
                
                // We have data
                print("Facebook IDs: \(facebookUserIDs)")
                
                KlusterDataSource.fetchUsersWithFacebookIds(facebookUserIDs, kluster: self.kluster, completion: { (objects, error) -> Void in
                    
                    // Remove the hud
                    self.hud.stopAnimation()
                    
                    if let objects = objects as? [PFUser] {
                        self.users = objects
                        self.tableView.reloadData()
                    }
                })
            } else {
                // Remove the hud
                self.hud.stopAnimation()
            }
            
            if let error = error {
                // Remove the hud
                self.hud.stopAnimation()
                
                //  Error fetching friends...
                self.showRequestError(error as NSError)
            }
        }
    }
    
    fileprivate func showRequestError(_ error: NSError) {
        let alert = UIAlertController.init(title: "Error", message: "Unable to fetch facebook friends.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
