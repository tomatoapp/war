//
//  BaseTranslucentViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 7/23/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

enum TransitionMode {
    case None
    case FromButtom
    case FromTop
    case FromLeft
    case FromRight
}

class BaseTranslucentViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning{

    var blurView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if WARDevice.isiOS7() {
            self.transitioningDelegate = self
        }
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addBlurView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlurView() {
        blurView = self.initBlurView()
        self.view.insertSubview(self.blurView, atIndex: 0)
        let tap = UITapGestureRecognizer(target: self, action: Selector("blurViewTap:"))
        blurView!.addGestureRecognizer(tap)
        
    }
    
    func initBlurView() -> UIView! {
        var blurView: UIView?
        if #available(iOS 8.0, *) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView?.translatesAutoresizingMaskIntoConstraints = false
        } else {
            // Fallback on earlier versions
            blurView = UIToolbar()
        }
        blurView!.frame = self.view.frame
        return blurView
    }

//    func getBlurEffectStyleByMode(mode: TransitionMode) -> UIBlurEffectStyle {
//        switch mode {
//        case .FromButtom:
//            return UIBlurEffectStyle.
//        }
//    }
    func blurViewTap(sender: UITapGestureRecognizer!) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        if self.delegate != nil {
//            self.delegate!.startViewController(self, didSelectItem: .Cancel)
//        }
    }

    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    let TRANSITION_DURATION = 0.3
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TRANSITION_DURATION
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containterView = transitionContext.containerView()
        
        let presentedView = presentedController!.view
        let presentingView = presentingController!.view
        
        if presentingController == self {
            
            containterView!.addSubview(presentingView)
            
            presentingView.frame = presentedView.frame
            self.view.frame.origin.y += self.view.frame.height
            
            UIView.animateWithDuration(TRANSITION_DURATION, animations: { () in
                self.view.frame.origin.y -= self.view.frame.height
                self.view.transform = CGAffineTransformIdentity
                }, completion: { finished in
                    transitionContext.completeTransition(true)
                    self.view.setNeedsDisplay()
            })
            
        } else {
            presentingView.frame = containterView!.frame
            
            UIView.animateWithDuration(TRANSITION_DURATION, animations: { () in
                self.view.frame.origin.y += self.view.frame.height
                }, completion: { finished in
                    presentingView.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic
                    transitionContext.completeTransition(true)
            })
        }
        //self.executeAnimationWithTransitionMode(self.transitionMode, presentingController: presentingController!, containterView: containterView, presentedView: presentedView, presentingView: presentingView, transitionContext: transitionContext)
    }
    
    var transitionMode: TransitionMode = TransitionMode.None
    func setTransitionMode(mode: TransitionMode) {
        self.transitionMode = mode
    }
    
    func executeAnimationWithTransitionMode(mode: TransitionMode, presentingController: UIViewController, containterView: UIView, presentedView: UIView, presentingView: UIView, transitionContext:UIViewControllerContextTransitioning) {
        
        var offset: CGFloat = 0.0
        switch mode {
        case .FromButtom:
            offset = self.view.frame.height
        case .FromLeft:
            offset = self.view.frame.width
        case .FromRight:
            offset = -self.view.frame.width
        case .FromTop:
            offset = -self.view.frame.height
        case .None:
            offset = 0
        }
        
        if presentingController == self {
            containterView.addSubview(presentingView)
            presentingView.frame = presentedView.frame
            
            let completion: CompletionBlock = { finished -> Void in
                transitionContext.completeTransition(true)
                self.view.setNeedsDisplay()
            }
        
            switch mode {
            case .FromButtom, .FromTop:
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    self.view.frame.origin.y += offset
                    self.view.transform = CGAffineTransformIdentity
                }, completion: completion)
                
            case .FromLeft, .FromRight, .None:
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    self.view.frame.origin.x += offset
                }, completion: completion)
            }
            
        } else {
            
            let dismissCompletion: CompletionBlock = { finished -> Void in
                presentingView.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic
                transitionContext.completeTransition(true)
            }
            presentingView.frame = containterView.frame

            switch mode {
            case .FromButtom, .FromTop:
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    self.view.frame.origin.y -= offset
                    self.view.transform = CGAffineTransformIdentity
                    }, completion: dismissCompletion)
                
            case .FromLeft, .FromRight, .None:
                self.view.frame.origin.x -= offset
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    }, completion: dismissCompletion)
            }

        }
        
    }
    
    typealias CompletionBlock = (Bool)-> Void
    func noneTransitionAnimation(presentedView: UIView, presentingView: UIView) {
        UIView.animateWithDuration(0.0, animations: { () -> Void in
        })
    }
    
    func topToButtomTransitionAnimation(presentedView: UIView, presentingView: UIView) {
        
    }
    
    func buttomToTopTransitionAnimation(presentedView: UIView, presentingView: UIView, completion: CompletionBlock) {
        presentingView.frame = presentedView.frame
        self.view.frame.origin.y += self.view.frame.height
        
        UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
            self.view.frame.origin.y -= self.view.frame.height
            self.view.transform =  CGAffineTransformIdentity
        }, completion: completion)
    }
    
    func leftToRightTransitionAnimation(presentedView: UIView, presentingView: UIView) {
        
    }
    
    func rightToLeftTransitionAnimation(containerView: UIView, presentingView: UIView) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
