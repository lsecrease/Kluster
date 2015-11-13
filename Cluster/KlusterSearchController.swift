//
//  KlusterSearchController.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class KlusterSearchController: UITableViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.navigationItem.title = "Search For Klusters"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Dismiss", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissPressed:")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell")
        let k = self.searchResults[indexPath.row] as PFObject!
        cell?.textLabel?.text = k.objectForKey("name") as? String
        cell?.detailTextLabel?.text = k.objectForKey("plans")as? String
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString?.length > 0 {
            KlusterDataSource.searchForKlusterWithString(searchString!) { (results, error) -> Void in
                self.searchResults = results as! Array
                self.tableView.reloadData()
            }
        }

    }
    
    func dismissPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}