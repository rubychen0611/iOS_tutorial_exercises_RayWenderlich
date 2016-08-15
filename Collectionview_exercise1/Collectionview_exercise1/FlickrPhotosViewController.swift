//
//  FlickrPhotosViewController.swift
//  Collectionview_exercise1
//
//  Created by Magenta Qin on 16/8/12.
//  Copyright © 2016年 Magenta Qin. All rights reserved.
//

import UIKit


class FlickrPhotosViewController: UICollectionViewController {
    @IBOutlet weak var textField: UITextField!
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
    
    func photoForIndexPath(indexPath:NSIndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //添加数据源方法
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return searches.count
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrCell", forIndexPath: indexPath)
//        cell.backgroundColor = UIColor.blackColor()
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrCell", forIndexPath: indexPath) as! FlickrPhotoCell
        let photo = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.blackColor()
        cell.imageView.image = photo.thumbnail
        return cell
    }
}

extension FlickrPhotosViewController : UITextFieldDelegate {
    
    //当用户按下Return键的时候调用这个方法
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
       //添加一个activityIndicatorView
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        //当搜索完成后，调用闭包，返回搜索到的结果及错误情况
        flickr.searchFlickrForTerm(textField.text!) { (results, error) in
            activityIndicator.removeFromSuperview()
           
            //如果有错误出现，记录错误
            if error != nil {
                print("Error searching:\(error)")
            }
            
            //如果没有错误，就记录结果，并将results添加到searches数组，更新collectionview。
            if results != nil {
                print("Found \(results!.searchResults.count) photos matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                 self.collectionView?.reloadData()
            }
        }
        //textField没有文字时，取消textField的第一响应，收起键盘
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flickrPhoto = photoForIndexPath(indexPath)
        
        if var size = flickrPhoto.thumbnail?.size {
            size.width += 10
            size.height += 10
            return size
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}