//
//  KlusterInviteViewController.swift
//  Cluster
//
//  Created by Michael Fellows on 3/9/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit

class KlusterInviteViewController : UITableViewController {
    
    var users = [PFUser]()
    var usersToInvite = [PFUser]()
    var kluster: Kluster!
    let hud = BLMultiColorLoader.init(frame: CGRectMake(0, 0, 40.0, 40.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hack to remove cell separators when no data is present
        self.tableView.tableFooterView = UIView()
        
        // Update the nav bar
        self.navigationItem.title = "Invite Friends"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .Plain, target: self, action: "inviteDonePressed:")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Add the hud before fetching friends..
        // Add progress HUD
        self.hud.center = self.view.center
        self.hud.lineWidth = 2.0
        self.hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGrayColor()]
        self.view.addSubview(hud)
        
        self.hud.startAnimation()
        
        self.fetchFacebookFriends()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("KlusterInviteTableViewCell") as! KlusterInviteTableViewCell
        
        let user = self.users[indexPath.row]
        if let firstName = user.objectForKey("firstName") as? String, lastName = user.objectForKey("lastName") as? String {
            cell.profileNameLabel.text = "\(firstName) \(lastName)"
        }
        
        cell.profileImageView.image = nil
        cell.profileImageView.file = user.objectForKey("avatarThumbnail") as? PFFile
        cell.profileImageView.loadInBackground()
        
        // Format cell
        cell.selectionStyle = .None
        cell.profileImageView.layer.cornerRadius = 17.5
        cell.profileImageView.clipsToBounds = true
        
        // Invite button actions
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: "inviteButtonPressed:", forControlEvents: .TouchUpInside)
        
        
        if (self.usersToInvite.contains(user)) {
            cell.inviteButton.setTitle("Invited", forState: .Normal)
        } else {
            cell.inviteButton.setTitle("Invite", forState: .Normal)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // Mark - Selectors
    
    func inviteButtonPressed(sender: DesignableButton) {
        let index = sender.tag
        let user = self.users[index]
        print("\(user) selected...")
        
        if self.usersToInvite.contains(user) {
            if let index = self.usersToInvite.indexOf(user) {
                self.usersToInvite.removeAtIndex(index)
            }
        } else {
            // add friend
            self.usersToInvite.append(user)
        }
        
        self.updateTableState()
    }
    
    func inviteDonePressed(sender: UIBarButtonItem) {
        // TODO: Send invites...
        
        var userIds = [String]()
        for user in self.usersToInvite {
            if let userId = user.objectId {
                userIds.append(userId)
            }
        }
        
        // Disable the bar button item... 
        if let barButtonItem = self.navigationItem.rightBarButtonItem {
            barButtonItem.enabled = false
        }
        
        // Add hud - Already added to the view hierarchy
        self.hud.startAnimation()
        
        KlusterDataSource.inviteUsersToKluster(userIds, klusterId: self.kluster.id) { (object, error) -> Void in
            
            // Enable the bar button item...
            if let barButtonItem = self.navigationItem.rightBarButtonItem {
                barButtonItem.enabled = true
            }
            
            // Stop animating the hud..
            self.hud.stopAnimation()
            
            if error != nil {
                let alertController = UIAlertController.init(title: "Invite Error", message: "Something went wrong when inviting users to this Kluster. Please try again.", preferredStyle: .Alert)
                let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                if let navController = self.navigationController {
                    navController.popViewControllerAnimated(true)
                }
            }
        }
    }
        
    
    // Mark - Private
    
    private func updateTableState() {
        
        // Reload tableview data
        self.tableView.reloadData()
        
        // Determine the activation state of the invite button
        if let navItem = self.navigationItem.rightBarButtonItem {
            navItem.enabled = self.usersToInvite.count > 0
        }
    }
    
    private func fetchFacebookFriends() {
        // Fetch Facebook Friends
        let request = FBSDKGraphRequest.init(graphPath: "me/friends", parameters: nil, HTTPMethod: "GET")
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
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
                self.showRequestError(error)
            }
        }
    }
    
    private func showRequestError(error: NSError) {
        let alert = UIAlertController.init(title: "Error", message: "Unable to fetch facebook friends.", preferredStyle: .Alert)
        let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
