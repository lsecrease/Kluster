//
//  MyKlusterViewController.swift
//  Cluster
//
//  Created by Lawrence Olivier on 12/1/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class MyKlusterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiss(sender: UIButton) {
      
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension MyKlusterViewController : UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "My Kluster Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyKlusterTableViewCell
        
        
        //Cell Elements
        cell.klusterRoleLabel.text = "Creator"
        cell.klusterNameLabel.text = "Houston Night Out"
        cell.numberOfMembersLabel.text = "7 Members"
        cell.klusterImage.image = UIImage(named: "2.jpg")
        
        return cell
    }
    
}
