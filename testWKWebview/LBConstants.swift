//
//  LBConstants.swift
//  Select
//
//  Created by XieLibin on 9/6/15.
//  Copyright (c) 2015 XieLibin. All rights reserved.
//

import Foundation
import UIKit

enum DeviceWHModel {
    case P4
    case P5
    case P6
    case P6P
    case Default
}

enum DeviceWidthModel {
    case Screen320
    case Screen375
    case Screen414
    
    static func deviceModel() -> DeviceWidthModel {
        let width = UIScreen.mainScreen().bounds.width
        if width < 350 {
            return .Screen320
        } else if width < 400 {
            return .Screen375
        } else {
            return .Screen414
        }
    }
}

struct DeviceConstant {
    static let screenSize = UIScreen.mainScreen().bounds.size
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    
    static let deviceWitdhModel : DeviceWidthModel = DeviceWidthModel.deviceModel()
    static var deviceWHModel : DeviceWHModel {
        var model : DeviceWHModel  = .Default
        
        if screenHeight < 500.0 {
            model = .P4
        } else if screenHeight < 600.0 {
            model = .P5
        } else if screenHeight < 700.0 {
            model = .P6
        } else if screenHeight < 800.0 {
            model = .P6P
        } else {
            model = .Default
        }
        
        return model
    }
}