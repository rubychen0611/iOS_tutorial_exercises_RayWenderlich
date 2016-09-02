//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
    var json: [String: AnyObject]!
    do {
        json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
    } catch {
        print(error)
        XCPlaygroundPage.currentPage.finishExecution()
    }
    //初始化TopApps的一个实例
    guard let topApps = TopApps(json: json) else {
        print("Error initializing object")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    guard let firstItem = topApps.feed?.entries?.first else {
        print("No such item.")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    print(firstItem)
    XCPlaygroundPage.currentPage.finishExecution()
}
