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
        
        println("Root View Did Load")
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title"))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1)
        self.delegate = self

        self.navigationController?.navigationBarHidden = true
        var pages = [EAIntroPage]()
        for id in 1...5 {
            let tempGuideViewController: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController\(id)") as UIViewController
            tempGuideViewController.view.frame = self.view.bounds
            let tempPage = EAIntroPage(customView: tempGuideViewController.view)
            tempPage.customView.frame = self.view.bounds
            pages.append(tempPage)
        }
        
        introView = EAIntroView(frame: self.view.bounds, andPages: pages)
        introView?.backgroundColor = UIColor.whiteColor()
        introView?.showInView(self.view, animateDuration: 0)
        introView?.delegate = self
        introView?.swipeToExit = false
        introView?.showSkipButtonOnlyOnLastPage = true
        introView?.skipButtonAlignment = EAViewAlignment.Center
        introView?.skipButtonY = 200
        introView?.skipButton.titleLabel?.font = UIFont.systemFontOfSize(23)
        introView?.skipButton.setTitleColor(UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0), forState: UIControlState.Normal)
        introView?.skipButton.setTitle("Get Started", forState: UIControlState.Normal)
        
//        let *pageControl = SMPageControl()
//        pageControl.pageIndicatorImage = [UIImage imageNamed:@"pageDot"];
//        pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"selectedPageDot"];
//        [pageControl sizeToFit];
//        intro.pageControl = (UIPageControl *)pageControl;
//        intro.pageControlY = 130.f
        
        let pageControl = SMPageControl()
        pageControl.pageIndicatorImage = UIImage(named: "indicator")
        pageControl.currentPageIndicatorImage = UIImage(named: "currentIndicator")
        pageControl.sizeToFit()
        introView?.setupPageControl(pageControl)
        introView?.pageControlY = 40.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("root view will appear")
    }
    
    // MARK: - EAIntroDelegate

    func introDidFinish(introView: EAIntroView!) {
        self.navigationController?.navigationBarHidden = false
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
}