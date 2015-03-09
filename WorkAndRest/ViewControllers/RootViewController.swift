//
//  RootViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/27.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController, UITabBarControllerDelegate, EAIntroDelegate {
    
    var introView: EAIntroView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title"))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        self.delegate = self

        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_firstLaunch) {
            self.showIntroView()
        }
    }
    
    func hideIconWithAnimation() {
        let imageView = UIImageView(image: UIImage(named: "launch page icon"))
//        imageView.frame = CGRectMake((self.view.frame.width-151)/2, 148, 151, 142)
        
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        
        imageView.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            //-self.navigationController!.navigationBar.frame.height\
            make.centerY.mas_equalTo()(self.view.mas_centerY).offset()(-79)
            make.width.mas_equalTo()(151)
            make.height.mas_equalTo()(142)
            return ()
        }
        
        imageView.alpha = 1.0
        UIView.animateWithDuration(0.6,
            delay: 0.25,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                imageView.alpha = 0.0
                imageView.transform = CGAffineTransformMakeScale(1.7, 1.7)
                imageView.center = CGPointMake(imageView.center.x, imageView.center.y + 40)
                
            }) { (finished) -> Void in
                imageView.removeFromSuperview()
        }
    }
    
    // MARK: - EAIntroDelegate

    func introDidFinish(introView: EAIntroView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.hideIconWithAnimation()
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
            duration: 0.1,
            options: UIViewAnimationOptions.TransitionCrossDissolve)
            { (finished) -> Void in
                if finished {
                    tabBarController.selectedIndex = toIndex!
                }
        }
        return true
    }
    
    // MARK: - Methods
    
    func showIntroView() {
        self.navigationController?.navigationBarHidden = true
        var pages = [EAIntroPage]()
        for id in 2...5 {
            let tempGuideViewController: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController\(id)") as UIViewController
            tempGuideViewController.view.frame = self.view.bounds
            let tempPage = EAIntroPage(customView: tempGuideViewController.view)
            tempPage.customView.frame = self.view.bounds
            pages.append(tempPage)
        }
        
        introView = EAIntroView(frame: self.view.bounds, andPages: pages)
        introView?.backgroundColor = UIColor.whiteColor()
        introView?.delegate = self
        introView?.swipeToExit = false
        introView?.showSkipButtonOnlyOnLastPage = true
        introView?.skipButtonAlignment = EAViewAlignment.Center
        introView?.skipButtonY = 200
        introView?.skipButton.titleLabel?.font = UIFont.systemFontOfSize(23)
        introView?.skipButton.setTitleColor(UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0), forState: UIControlState.Normal)
        introView?.skipButton.setTitle("Get Started", forState: UIControlState.Normal)
        introView?.swipeToExit = false
        
        let pageControl = SMPageControl()
        pageControl.pageIndicatorImage = UIImage(named: "baseIndicator")
        pageControl.currentPageIndicatorImage = UIImage(named: "currentIndicator")
        pageControl.sizeToFit()
        introView?.setupPageControl(pageControl)
        introView?.pageControlY = 40.0
        
        introView?.showInView(self.view, animateDuration: 0)

    }
    
}