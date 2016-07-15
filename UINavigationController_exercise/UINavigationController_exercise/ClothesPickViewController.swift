//
//  ClothesPickViewController.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/14.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class ClothesPickViewController: UITableViewController {
    var clothes:[String] = [
        "Jacket",
        "Skirt",
        "Shirt",
        "Dress",
        "Blouses"
    ]
    var selectedClothes:String?{
        didSet{
            if let someClothes = selectedClothes{
                selectedClothesIndex = clothes.indexOf(someClothes)!
            }
        }
    }
    var selectedClothesIndex:Int?
   
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clothes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClothesCell", forIndexPath: indexPath)
        cell.textLabel?.text = clothes[indexPath.row]
        
        //Set a checkmark on the cell
        if indexPath.row == selectedClothesIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Deselect previous selected row
        if let index = selectedClothesIndex{
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        selectedClothes = clothes[indexPath.row]
        
        //Update the checkmark
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        
    }
    
    
   
}
