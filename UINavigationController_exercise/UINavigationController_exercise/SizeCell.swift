//
//  SizeCell.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/15.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class SizeCell: UITableViewCell {

    @IBOutlet weak var sizeLabel: UILabel!
   
    @IBOutlet weak var sizeImage: UIImageView!
    
    var size: Size!{
        didSet{
            sizeLabel.text = size.pickSize
            sizeImage.image = imageForSize(size.pickSize)
        }

    }
    
    func imageForSize(pickSize:String) -> UIImage? {
        let imageName = "Size_pickSize"
        return UIImage(named: imageName)
    }
    
    
}
