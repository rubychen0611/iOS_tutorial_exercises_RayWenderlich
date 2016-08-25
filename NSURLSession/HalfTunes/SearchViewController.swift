//
//  SearchViewController.swift
//  HalfTunes
//
//  Created by Ken Toh on 13/7/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MediaPlayer

//URL和Download之间的映射
var activeDownloads = [String:Download]()


class SearchViewController: UIViewController {

  //创建一个NSURLSession实例，并对它进行初始化
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  //声明变量dataTask，以便向iTunes Search web service发出HTTP GET请求
  var dataTask: NSURLSessionDataTask?

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!

  var searchResults = [Track]()
  
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(SearchViewController.dismissKeyboard))
    return recognizer
  }()
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Handling Search Results
  
  // This helper method helps parse response JSON NSData into an array of Track objects.
  func updateSearchResults(data: NSData?) {
    searchResults.removeAll()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        
        // Get the results array
        if let array: AnyObject = response["results"] {
          for trackDictonary in array as! [AnyObject] {
            if let trackDictonary = trackDictonary as? [String: AnyObject], previewUrl = trackDictonary["previewUrl"] as? String {
              // Parse the search result
              let name = trackDictonary["trackName"] as? String
              let artist = trackDictonary["artistName"] as? String
              searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl))
            } else {
              print("Not a dictionary")
            }
          }
        } else {
          print("Results key not found in dictionary")
        }
      } else {
        print("JSON Error")
      }
    } catch let error as NSError {
      print("Error parsing results: \(error.localizedDescription)")
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPointZero, animated: false)
    }
  }
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  // MARK: Download methods
  
  // Called when the Download button for a track is tapped
  func startDownload(track: Track) {
    if let urlString = track.previewUrl, url = NSURL(string:urlString){
        let download = Download(url: urlString)
        download.downloadTask = downloadsSession.downloadTaskWithURL(url)
        download.downloadTask!.resume()
        download.isDownLoading = true
        activeDownloads[download.url] = download
    }
  }
  
  //暂停下载
  func pauseDownload(track: Track) {
    if let urlString = track.previewUrl,download = activeDownloads[urlString]{
        if download.isDownLoading {
            download.downloadTask?.cancelByProducingResumeData({ (data) in
                if data != nil {
                    download.resumeData = data
                }
            })
            download.isDownLoading = false
        }
    }
  }
    
  //取消下载
  func cancelDownload(track: Track) {
    if let urlString = track.previewUrl, download = activeDownloads[urlString]{
        download.downloadTask?.cancel()
        activeDownloads[urlString] = nil
    }
  }
  
  //继续下载
    func resumeDownload(track: Track) {
    if let urlString = track.previewUrl, download = activeDownloads[urlString]{
        //检查是否暂停过。如果暂停过，就在resume data的基础上，继续下载；否则，就重新创建一个download task
        if let resumeData = download.resumeData {
            download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
            download.downloadTask!.resume()
            download.isDownLoading = true
        } else if let url = NSURL(string: download.url) {
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            download.isDownLoading = true
        }
    }
  }
  
   // This method attempts to play the local file (if it exists) when the cell is tapped
  func playDownload(track: Track) {
    if let urlString = track.previewUrl, url = localFilePathForUrl(urlString) {
      let moviePlayer:MPMoviePlayerViewController! = MPMoviePlayerViewController(contentURL: url)
      presentMoviePlayerViewControllerAnimated(moviePlayer)
    }
  }
  
  // MARK: Download helper methods
  
  // This method generates a permanent local file path to save a track to by appending
  // the lastPathComponent of the URL (i.e. the file name and extension of the file)
  // to the path of the app’s Documents directory.
  func localFilePathForUrl(previewUrl: String) -> NSURL? {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    if let url = NSURL(string: previewUrl), lastPathComponent = url.lastPathComponent {
        let fullPath = documentsPath.stringByAppendingPathComponent(lastPathComponent)
        return NSURL(fileURLWithPath:fullPath)
    }
    return nil
  }
  
  // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
  func localFileExistsForTrack(track: Track) -> Bool {
    if let urlString = track.previewUrl, localUrl = localFilePathForUrl(urlString) {
      var isDir : ObjCBool = false
      if let path = localUrl.path {
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
      }
    }
    return false
  }
    //计算歌曲的index
    func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for(index,track) in searchResults.enumerate() {
                if url == track.previewUrl! {
                    return index
                }
            }
        }
        return nil
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    // Dimiss the keyboard
    dismissKeyboard()
    if !searchBar.text!.isEmpty {
        //检查data task是否已经初始化
        if dataTask != nil {
            dataTask?.cancel()
        }
        //让network activity indicator显示在状态栏上，告诉用户正在进行网络请求
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //确保传给url的字符串被正确转义
        let expectedCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let searchTerm = searchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)!
        
        //把被转义的字符串作为GET参数添加到iTunes Search API url里
        let url = NSURL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
        
        //初始化dataTask来应对HTTP GET请求
        dataTask = defaultSession.dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            
            //当task完成时，触发UI在主线程进行更新，并隐藏activity indicator
            dispatch_async(dispatch_get_main_queue(), { 
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            
            //如果HTTP请求成功，调用updateSearchResults()方法，将response JSON NSData解析为歌曲，并更新table view
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateSearchResults(data)
                }
            }
        })
        //data task默认是处于suspended状态的，需手动调用resume()方法，开始请求
       dataTask?.resume()
    }
  }
    
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
    
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }
    
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}

// MARK: TrackCellDelegate

extension SearchViewController: TrackCellDelegate {
  func pauseTapped(cell: TrackCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let track = searchResults[indexPath.row]
      pauseDownload(track)
      tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
    }
  }
  
  func resumeTapped(cell: TrackCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let track = searchResults[indexPath.row]
      resumeDownload(track)
      tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
    }
  }
  
  func cancelTapped(cell: TrackCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let track = searchResults[indexPath.row]
      cancelDownload(track)
      tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
    }
  }
  
  func downloadTapped(cell: TrackCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let track = searchResults[indexPath.row]
      startDownload(track)
      tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
    }
  }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as!TrackCell
    // Delegate cell button tap events to this view controller
    cell.delegate = self
    
    let track = searchResults[indexPath.row]
    
    // Configure title and artist labels
    cell.titleLabel.text = track.name
    cell.artistLabel.text = track.artist

    
    //downloaded存储已经下载到本地的文件
    let downloaded = localFileExistsForTrack(track)
    
    var showDownloadControls = false
    //如果歌曲正在下载，就将showDownloadControls设置为true
    if let download = activeDownloads[track.previewUrl!]{
        showDownloadControls = true
        
        cell.progressView.progress = download.progress
        cell.progressLabel.text = (download.isDownLoading) ? "Downloading..." : "Paused"
        
        //pauseButton在“Pause”和“Resume”之间切换。
        let title = (download.isDownLoading) ? "Pause" : "Resume"
        cell.pauseButton.setTitle(title, forState: .Normal)
    }
    //如果文件没有在下载时，就隐藏progressView和progressLabel
    cell.progressView.hidden = !showDownloadControls
    cell.progressLabel.hidden = !showDownloadControls
   
    //cell的selectionStyle相应地做出改变
    cell.selectionStyle = downloaded ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
    
    //如果文件下载完成或正在下载，隐藏downloadButton
    cell.downloadButton.hidden = downloaded || showDownloadControls
    
    //只有在下载时，这两个button才会出现
    cell.pauseButton.hidden = !showDownloadControls
    cell.cancelButton.hidden = !showDownloadControls
    
    return cell
  }
}

// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let track = searchResults[indexPath.row]
    if localFileExistsForTrack(track) {
      playDownload(track)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

//MARK: NSURLSessionDownloadDelegate
extension SearchViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        //将请求路径保存到永久本地路径中。
        if let originalURL = downloadTask.originalRequest?.URL?.absoluteString, destinationURL = localFilePathForUrl(originalURL) {
            print(destinationURL)
            
            //在开始复制前，清理临时文件位置上的item
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(destinationURL)
            } catch {
                
            }
            //将下载好的文件从临时文件位置复制到目的地文件路径
            do {
                try fileManager.copyItemAtURL(location, toURL: destinationURL)
            } catch let error as NSError {
                print("Could't copy file to disk: \(error.localizedDescription)")
            }
        }
        
        //将activeDownloads数组里相应的download移除
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            activeDownloads[url] = nil
            
            //更新table view
            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex,inSection: 0)], withRowAnimation: .None)
                })
            }
        }
    }
   //查看下载进度
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        //找到正在下载的download
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl]{
            
            //计算下载进度
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            
            //计算下载文件大小。NSByteCountFormatter能将字节值转换为可读字符串
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            
            //更新cell
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0))as? TrackCell {
                dispatch_async(dispatch_get_main_queue(), { 
                    trackCell.progressView.progress = download.progress
                    trackCell.progressLabel.text = String(format: "%.1f%% of %@", download.progress * 100, totalSize)
                })
            
            }
            
        }
    }
}
