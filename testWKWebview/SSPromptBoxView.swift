//
//  SSPromptBoxView.swift
//  Select
//
//  Created by XieLibin on 10/12/15.
//  Copyright © 2015 XieLibin. All rights reserved.
//

import UIKit
import SnapKit

func showPromtMessage(content : String, State state : PromptBoxState = .BoxBottom) {

    
    dispatch_async(dispatch_get_main_queue()) { 
        guard let window = UIApplication.sharedApplication().keyWindow else {
                        return
        }
        SSPromptBoxView.showPromptMessage(content, container: window, State: state)
    }
    
}

enum PromptBoxState {
    case BoxBottom, BoxMiddle, BoxTop
    
    func stateBottomOffest() -> CGFloat {
        switch self {
        case .BoxBottom:
            return 0
        case .BoxMiddle:
            return -256
        case .BoxTop:
            return 0
        }
    }
}

class SSPromptBoxView: UIView {
    
    class func showPromptMessage(message : String, container : UIView, State state : PromptBoxState = .BoxBottom) -> SSPromptBoxView {
        let subviews = container.subviews
        for sub in subviews {
            if sub is SSPromptBoxView {
                sub.removeFromSuperview()
            }
        }
        
        let promptBox = SSPromptBoxView(message: message, State: state)
        container.addSubview(promptBox)
        container.bringSubviewToFront(promptBox)
        
        return promptBox
    }
    
    let messageLabel = UILabel()
    private var state = PromptBoxState.BoxBottom
        
    convenience init(message : String, State state : PromptBoxState = .BoxBottom) {
        self.init()
        self.state = state
        
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFontOfSize(15)
        messageLabel.textColor = UIColor.whiteColor()
        addSubview(messageLabel)
        messageLabel.text = message
        
        messageLabel.snp_makeConstraints {[weak self] (make) -> Void in
            guard let strong = self else{
              return
            }
            make.center.equalTo(strong)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.layer.cornerRadius = 5
        
        self.alpha = 0.4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = superview {
            
            let size = messageLabel.sizeThatFits(CGSizeMake(DeviceConstant.screenWidth - 50, 100))
            
            let offest = state.stateBottomOffest()
            self.snp_makeConstraints(closure: { (make) -> Void in
                make.centerX.equalTo(superview)
                make.bottom.equalTo(superview).offset(offest)
                
                make.height.equalTo(size.height + 24)
//                make.width.lessThanOrEqualTo(size.width)
                make.width.greaterThanOrEqualTo(size.width + 20)
  
            })
            layoutIfNeeded()
            
            self.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(superview).offset(offest-60)
            })
            UIView.animateWithDuration(0.75, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.layoutIfNeeded()
                self.alpha = 1.0
                }, completion: { (complete : Bool) -> Void in
                    

                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [weak self] in
                    guard let strong = self else {
                        return
                    }
                    strong.removeFromSuperview()
                   })

            })
        }
    }
}
