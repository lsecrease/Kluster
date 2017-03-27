 //
//  MembersTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/21/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

// MARK: MembersTableViewController
 
class MembersTableViewController: UITableViewController {
    
    var kluster: Kluster!
    var users = [PFUser]()

    var parentNavigationController : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Members"
        
        self.tableView.tableFooterView = UIView()

        let hud = BLMultiColorLoader.init(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
        hud.center = self.view.center
        hud.lineWidth = 2.0
        hud.colorArray = [UIColor.klusterPurpleColor(), UIColor.lightGray]
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersTableViewCell", for: indexPath) as! MembersTableViewCell
        let user = self.users[indexPath.row]
        cell.user = user
        
        cell.avatarImageView.image = nil
        cell.avatarImageView.tag = indexPath.row
        cell.avatarImageView.isUserInteractionEnabled = true
        cell.avatarImageView.file = user.object(forKey: "avatarThumbnail") as? PFFile
        cell.avatarImageView.loadInBackground()
        
        // Add a tap recognizer to the cell
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(MembersTableViewController.avatarTapped(_:)))
        cell.avatarImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }
    
    // MARK: - Selector
    
    func avatarTapped(_ sender: UITapGestureRecognizer) {
        let user = self.users[sender.view!.tag]
        // message.user
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.user = user
        self.present(profileViewController, animated: true, completion: nil)
    }

}
