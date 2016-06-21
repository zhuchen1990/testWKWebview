//
//  MineTableViewController.swift
//  testWKWebview
//
//  Created by 朱晨 on 16/6/13.
//  Copyright © 2016年 朱晨. All rights reserved.
//

import UIKit
import WebKit
class MineTableViewController: UITableViewController {
    
    var size : UInt64 = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        showCacheSize()
        
        let homePath = NSHomeDirectory()
        let files = NSFileManager.defaultManager().subpathsAtPath(homePath)
        for item in files!{
            print("-----\(item)")
        
        }
        

//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell == nil  {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = "清除存储空间"
        cell!.accessoryType = .DisclosureIndicator
    
        cell!.detailTextLabel?.text = String(size) + "M"
        // Configure the cell...

        return cell!
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cleanCaches()
            showCacheSize()
            showPromtMessage("Clean Success！")
        }
        
    }

}

extension MineTableViewController{
    func showCacheSize() {
        dispatch_async(dispatch_get_main_queue()) {[weak self] in
            guard let strong = self else{
                return
            }
            strong.size = strong.caculateCacheSize()
            
            strong.tableView.reloadData()
        }
    }
    
    
    func cleanCaches() -> Void {
        
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{})
        }else{
            
            if let docPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first{
                if let bundleId = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String{
                    let webkitFolderInCaches = docPath + "/Caches/" + bundleId + "/Webkit"
                    do{
                        
                        try NSFileManager.defaultManager().removeItemAtPath(webkitFolderInCaches)
                        
                    }catch(let error){
                        
                        print(error)
                    }
                    NSURLCache.sharedURLCache().removeAllCachedResponses()
                }
            }
        }
        
    }
    
    func caculateCacheSize() -> UInt64{
        
        var docSize: UInt64 = 0
        if let docPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first{
            if let bundleId = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String{
                let webkitFolderInCaches = docPath + "/Caches/" + bundleId + "/Webkit"
//                print(webkitFolderInCaches)
                docSize = webkitFolderInCaches.caculateFileSize()
            }
            
        }
        return docSize
    }
}
