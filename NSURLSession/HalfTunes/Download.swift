//
//  Download.swift
//  HalfTunes
//
//  Created by Magenta Qin on 16/8/25.
//  Copyright © 2016年 Ken Toh. All rights reserved.
//

import UIKit

class Download: NSObject {
    var url: String
    var isDownLoading = false
    var progress: Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    //当你暂停下载时，resumeData存储已经下载好的数据
    var resumeData: NSData?
    
    init(url:String) {
        self.url = url
    }
}
