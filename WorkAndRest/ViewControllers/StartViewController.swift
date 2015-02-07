//
//  StartViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/7.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

enum StartType {
    case Now, Later, Cancel
}
protocol StartViewControllerDelegate {
    func startViewController(sender: StartViewController, didSelectItem item: StartType)
}

class StartViewController: UIViewController {
    
    var delegate: StartViewControllerDelegate?
    
    var blurView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBlurView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    @IBAction func startNowButtonClick(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.startViewController(self, didSelectItem: .Now)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startLaterButtonClick(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.startViewController(self, didSelectItem: .Later)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
        if self.delegate != nil {
            self.delegate!.startViewController(self, didSelectItem: .Cancel)
        }
    }
}