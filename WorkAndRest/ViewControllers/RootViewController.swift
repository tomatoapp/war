//
//  RootViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/27.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title"))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        
        //self.tabBarController!.delegate = self
        self.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // self.animationSwitch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func animationSwitch() {
        let fromView = self.selectedViewController!.view
        let controllerIndex = find(self.viewControllers! as Array, self.selectedViewController!) == 0 ? 1 : 0
        let toView = self.viewControllers![controllerIndex].view as UIView!
        
        let viewSize = fromView.frame
        let scrollRight = controllerIndex > self.selectedIndex
        
        fromView.superview!.addSubview(toView!)
        
        let width = UIScreen.mainScreen().bounds.size.width
        toView.frame = CGRectMake(scrollRight ? width : -width, viewSize.origin.y, width, viewSize.height)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            fromView.frame = CGRectMake(scrollRight ? -width : width, viewSize.origin.y, width, viewSize.height)
        }) { (finished) -> Void in
            if finished {
                fromView.removeFromSuperview()
                self.selectedIndex = controllerIndex
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let fromView = tabBarController.selectedViewController?.view
        let toView = viewController.view
        
        if fromView == toView {
            return false
        }
        let fromIndex = find(tabBarController.viewControllers! as Array, tabBarController.selectedViewController!)
        let toIndex = find(tabBarController.viewControllers! as Array, viewController)
        
        UIView.transitionFromView(fromView!,
            toView: toView,
            duration: 0.2,
            options: UIViewAnimationOptions.TransitionCrossDissolve)
            { (finished) -> Void in
                if finished {
                    tabBarController.selectedIndex = toIndex!
                }
        }
        return true
    }
    
}