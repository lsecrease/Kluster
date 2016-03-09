 //
//  MembersTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/21/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class MembersTableViewController: UITableViewController {
    
    var kluster: Kluster!
    var users = [PFUser]()

    var parentNavigationController : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Members"
        
        self.tableView.tableFooterView = UIView()

        let hud = BLMultiColorLoader.init(frame: CGRectMake(0, 0, 40.0, 40.0))
        hud.center = self.view.center
        hud.lineWidth = 2.0
        hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGrayColor()]
        self.view.addSubview(hud)
        hud.startAnimation()
        
        KlusterDataSource.fetchMembersForKluster(kluster, completion: { (objects, error) -> Void in
            hud.stopAnimation()
            if (error != nil) {
                print("Error: %@", error)
            } else {
                self.users = objects as! [PFUser]
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MembersTableViewCell", forIndexPath: indexPath) as! MembersTableViewCell
        let user = self.users[indexPath.row]
        cell.user = user
        
        cell.avatarImageView.image = nil
        cell.avatarImageView.tag = indexPath.row
        cell.avatarImageView.userInteractionEnabled = true
        cell.avatarImageView.file = user.objectForKey("avatarThumbnail") as? PFFile
        cell.avatarImageView.loadInBackground()
        
        // Add a tap recognizer to the cell
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "avatarTapped:")
        cell.avatarImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }
    
    // MARK: - Selector
    
    func avatarTapped(sender: UITapGestureRecognizer) {
        let user = self.users[sender.view!.tag]
        // message.user
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileViewController.user = user
        self.presentViewController(profileViewController, animated: true, completion: nil)
    }

}
