//
//  File.swift
//  testWKWebview
//
//  Created by 朱晨 on 16/6/7.
//  Copyright © 2016年 朱晨. All rights reserved.
//

import Foundation

enum FruitType {
    case Apple
    case Origin
    case Blanana
}

public class PrintClass : NSObject{
   
//   var fruitName : FruitType = .Apple
   public func printMethod(content : String)  {
        print(content)
        print("实验成功")
    }
}

