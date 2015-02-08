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

class StartViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var delegate: StartViewControllerDelegate?
    
    var blurView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addBlurView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if WARDevice.isiOS7() {
            self.transitioningDelegate = self
        }
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
        self.view.insertSubview(self.blurView, atIndex: 0)
        let tap = UITapGestureRecognizer(target: self, action: Selector("blurViewTap:"))
        blurView!.addGestureRecognizer(tap)
        
    }
    
    func initBlurView() -> UIView! {
        var blurView: UIView?
        if let theClass: AnyClass = NSClassFromString("UIBlurEffect") { // iOS 8
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        } else { // iOS 7
            blurView = UIToolbar()
        }
        blurView!.frame = self.view.frame
        return blurView
    }
    
    func blurViewTap(sender: UITapGestureRecognizer!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if self.delegate != nil {
            self.delegate!.startViewController(self, didSelectItem: .Cancel)
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containterView = transitionContext.containerView()
        
        let presentedView = presentedController!.view
        let presentingView = presentingController!.view
        
        if presentingController == self {
            
            containterView.addSubview(presentingView)
            
            presentingView.frame = presentedView.frame
            self.view.frame.origin.y += self.view.frame.height
            
            UIView.animateWithDuration(0.3, animations: { () in
                self.view.frame.origin.y -= self.view.frame.height
                self.view.transform = CGAffineTransformIdentity
                }, completion: { finished in
                    transitionContext.completeTransition(true)
                    self.view.setNeedsDisplay()
            })
            
        } else {
            presentingView.frame = containterView.frame
            
            UIView.animateWithDuration(0.3, animations: { () in
                self.view.frame.origin.y += self.view.frame.height
                }, completion: { finished in
                    presentingView.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic
                    transitionContext.completeTransition(true)
            })
        }
    }
    

}