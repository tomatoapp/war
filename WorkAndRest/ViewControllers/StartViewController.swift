//
//  StartViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/7.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    var blurView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBlurView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    func addBlurView() {
        blurView = self.initBlurView()
        //self.view.addSubview(blurView!)
        self.view.insertSubview(self.blurView!, atIndex: 0)
        let tap = UITapGestureRecognizer(target: self, action: Selector("blurViewClick:"))
        blurView!.addGestureRecognizer(tap)
        self.blurView!.frame = self.view.frame

    }
    
    func initBlurView() -> UIView! {
        var blurView: UIView?
        
        if let theClass: AnyClass = NSClassFromString("UIBlurEffect") {
            // iOS 8
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
        } else {
            // iOS 7
            blurView = UIToolbar()
        }
        blurView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        return blurView
    }
    
    func blurViewClick(sender: UITapGestureRecognizer!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}