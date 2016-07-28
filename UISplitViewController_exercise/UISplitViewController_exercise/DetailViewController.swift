//
//  DetailViewController.swift
//  UISplitViewController_exercise
//
//  Created by Magenta Qin on 16/7/27.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    

    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var heartLabel: UILabel!
    
    var heart:Heart!{
        didSet(newHeart){
            self.refreshUI()
        }
    }
    func refreshUI(){
        heartLabel?.text = heart.name
        heartImage?.image = UIImage(named: heart.name)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
    // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailViewController:selectionDelegate {
    func selectHeart(newHeart: Heart) {
        heart = newHeart
    }
}
