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
    
    @IBAction func share(sender:AnyObject) {
        if searches.isEmpty {
            return
        }
        if !selectedPhotos.isEmpty {
            var imageArray = [UIImage]()
            for photo in self.selectedPhotos {
                imageArray.append(photo.thumbnail!)
            }
            let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
            let shareButton = self.navigationItem.rightBarButtonItems!.first as UIBarButtonItem!
            shareScreen.modalPresentationStyle = .Popover
            shareScreen.popoverPresentationController?.permittedArrowDirections = .Any
            shareScreen.popoverPresentationController?.barButtonItem = shareButton
            self.presentViewController(shareScreen, animated: true, completion: nil)
        }
        sharing = !sharing
    }
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
    private var selectedPhotos = [FlickrPhoto]()
    private let shareTextLabel = UILabel()
    
    //记录被选中的cell
    var largePhotoIndexPath : NSIndexPath? {
        didSet{
            var indexPaths = [NSIndexPath]()
            if largePhotoIndexPath != nil {
                indexPaths.append(largePhotoIndexPath!)
            }
            if oldValue != nil {
                indexPaths.append(oldValue!)
            }
            
            collectionView?.performBatchUpdates({ 
                self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
                return
                }, completion: { (completed) in
                    if self.largePhotoIndexPath != nil {
                        self.collectionView?.scrollToItemAtIndexPath(self.largePhotoIndexPath!, atScrollPosition: .CenteredVertically, animated: true)
                    }
            })
        }
    }
    
    //记录分享状态
    var sharing : Bool = false {
        didSet {
            //清空所有已经存在的selection，并把selectedPhotos数组清空
            collectionView?.allowsMultipleSelection = sharing
            collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
            selectedPhotos.removeAll(keepCapacity: false)
            if sharing && largePhotoIndexPath != nil {
                largePhotoIndexPath = nil
            }
            
            let shareButton = self.navigationItem.rightBarButtonItems!.first as UIBarButtonItem!
            if sharing {
                updateSharedPhotoCount()
                let sharingDetailItem = UIBarButtonItem(customView: shareTextLabel)
                navigationItem.setRightBarButtonItems([shareButton,sharingDetailItem], animated: true)
            } else {
                navigationItem.setRightBarButtonItems([shareButton], animated: true)
            }
        }
    }
    
    
    
    func photoForIndexPath(indexPath:NSIndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    func updateSharedPhotoCount(){
        shareTextLabel.textColor = themeColor
        shareTextLabel.text = "\(selectedPhotos.count) photos selected"
        shareTextLabel.sizeToFit()
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
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FlickrPhotoHeaderView", forIndexPath: indexPath) as! FlickrPhotoHeaderView
            headerView.label.text = searches[indexPath.section].searchTerm
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    //添加UICollectionViewDelegate方法
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if sharing {
            return true
        }
        if largePhotoIndexPath == indexPath {
            largePhotoIndexPath = nil
        } else {
            largePhotoIndexPath = indexPath
        }
        return false
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if sharing {
            let photo = photoForIndexPath(indexPath)
            selectedPhotos.append(photo)
            updateSharedPhotoCount()
        }
    }
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if sharing {
            let selectedPhoto = self.photoForIndexPath(indexPath)
            if let foundIndex = self.selectedPhotos.indexOf(selectedPhoto){
                selectedPhotos.removeAtIndex(foundIndex)
                updateSharedPhotoCount()
            }
        }
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
        
        //New code
        if indexPath == largePhotoIndexPath {
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.bottom)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }
        
        //Previous code
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