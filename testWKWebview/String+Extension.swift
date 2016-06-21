//
//  NSString+Extending.swift
//  testWKWebview
//
//  Created by 朱晨 on 16/6/13.
//  Copyright © 2016年 朱晨. All rights reserved.
//

import Foundation
import UIKit


extension String{
    func caculateFileSize() -> UInt64 {
        var size : UInt64 = 0
        let manager = NSFileManager.defaultManager()
        let exist = manager.fileExistsAtPath(self)
        
        guard exist else{
            return size
        }
        if let enumerater = manager.enumeratorAtPath(self){
            for subPath in enumerater {
                let fullPath = self + "/" + (subPath as! String)
                var isDoc : ObjCBool = false
                if manager.fileExistsAtPath(fullPath, isDirectory: &isDoc) {
                    if !isDoc {
                        do{
                            if let attr : NSDictionary = try manager.attributesOfItemAtPath(fullPath) {
                                size += attr.fileSize()
                            }
                            
                        }catch(let error){
                            print(error)
                        }
                    }
                }
                
            }
        }
        return size / (1024 * 1024)
    }
}