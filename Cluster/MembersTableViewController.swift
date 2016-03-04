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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        KlusterDataSource.fetchMembersForKluster(kluster, completion: { (objects, error) -> Void in
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
