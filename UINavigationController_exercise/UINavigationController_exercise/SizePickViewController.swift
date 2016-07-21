//
//  SizePickViewController.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/15.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class SizePickViewController: UITableViewController {
        
    var sizes = [
      Size(pickSize: "XS"),
      Size(pickSize: "S"),
      Size(pickSize: "XL"),
      Size(pickSize: "XXL")
    ]
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return sizes.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SizeCell", forIndexPath: indexPath) as! SizeCell
        let size = sizes[indexPath.row] as Size
        cell.size = size
        return cell
    }
    
}
