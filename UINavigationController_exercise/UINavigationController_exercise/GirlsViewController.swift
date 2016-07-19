//
//  GirlsViewController.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/13.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class GirlsViewController: UITableViewController {
    
    //Create an array
    var girls:[Girl] = girlsData
    
   
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView)
        -> Int {
        
                return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return girls.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GirlsCell", forIndexPath: indexPath)
        let girl = girls[indexPath.row]
        cell.textLabel?.text = girl.name
        cell.detailTextLabel?.text = girl.clothes
        return cell
    }
    
    //Mark Unwind Segues
    @IBAction func cancelToGirlsViewController(segue:UIStoryboardSegue){
        
    }
    @IBAction func saveToGirlsViewController(segue:UIStoryboardSegue){
        if let clothesViewController = segue.sourceViewController as? ClothesViewController {
            //add the new girl to the girls array
            if let girl = clothesViewController.girl {
                girls.append(girl)
            }
            //update the tableView
            let indexPath = NSIndexPath(forRow: girls.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
        
    }
    

    
}
