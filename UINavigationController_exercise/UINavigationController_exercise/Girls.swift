//
//  Girls.swift
//  UINavigationController_exercise
//
//  Created by Magenta Qin on 16/7/13.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

struct Girl {
    var name:String?
    var clothes:String?
    
    
    init(name:String?,clothes:String?){
        self.name = name
        self.clothes = clothes
    }
}
struct Size {
    var pickSize:String
    init(pickSize:String){
        self.pickSize = pickSize
    }
}
