//
//  ClothesViewController.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/13.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class ClothesViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var clothesDetailLabel: UILabel!
    
    @IBOutlet weak var sizeDetailLabel: UILabel!

    var girl:Girl?
    var clothes:String? = "Trousers"{
        didSet{
            clothesDetailLabel?.text = clothes
        }
    }
    var size:String? = "M"{
        didSet{
            sizeDetailLabel?.text = size
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        nameTextField.becomeFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveToGirlsViewController"{
            girl = Girl(name: nameTextField.text, clothes: clothes)
        }
        if segue.identifier == "toClothesPick" {
            if let clothesPickViewController = segue.destinationViewController as? ClothesPickViewController {
                clothesPickViewController.selectedClothes = clothes
            }
        }
    }
    
    //Unwind segue
    @IBAction func unwindWithSelectedClothes(segue:UIStoryboardSegue){
        if let clothesPickViewController = segue.sourceViewController as? ClothesPickViewController,selectedClothes = clothesPickViewController.selectedClothes {
            clothes = selectedClothes
        }
    }
    @IBAction func cancelToClothesViewController(segue:UIStoryboardSegue){
        
    }
    
   }
