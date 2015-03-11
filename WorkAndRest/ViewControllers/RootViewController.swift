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

        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_firstLaunch) {
            self.showIntroView()
        }
    }
    
    func hideIconWithAnimation() {
        let imageView = UIImageView(image: UIImage(named: "launch page icon"))
        imageView.frame = CGRectMake((self.view.frame.width-151)/2, self.view.frame.size.height/2 - 170 - 33, 151, 142)

        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        
//        imageView.alpha = 1.0
//        UIView.animateWithDuration(0.7,
//            delay: 0.0,
//            options: UIViewAnimationOptions.CurveEaseOut,
//            animations: { () -> Void in
//                imageView.alpha = 0.0
//                imageView.transform = CGAffineTransformMakeScale(1.7, 1.7)
//                imageView.center = CGPointMake(imageView.center.x, imageView.center.y + 40)
//                
//            }) { (finished) -> Void in
//                imageView.removeFromSuperview()
//        }
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
        
        let guides = WARConfig.loadGuideItems()
        
        let page1 = EAIntroPage()
        page1.title = NSLocalizedString("guide1Title", comment: "")
        page1.titleFont = UIFont.systemFontOfSize(24)
        page1.titlePositionY = self.view.frame.size.height/2 + 180 + 20
        page1.titleColor = UIColor.blackColor()
        
        page1.desc = NSLocalizedString("guide1SubTitle", comment: "")
        page1.descColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
        page1.descFont = UIFont.systemFontOfSize(15)
        page1.descPositionY = self.view.frame.size.height/2 + 150 + 20
        
        page1.titleIconView = UIImageView(image: UIImage(named: "guide1Image"))
//        page1.titleIconView.sizeToFit()
        page1.titleIconView.frame = CGRectMake(0, 0, self.view.frame.size.width-6, self.view.frame.size.width)
        page1.titleIconView.contentMode = UIViewContentMode.ScaleAspectFit
        page1.titleIconPositionY = self.view.frame.size.height/2 - 100 - 30
        pages.append(page1)
        
        let page2 = EAIntroPage()
        page2.title = NSLocalizedString("guide2Title", comment: "")
        page2.titleFont = UIFont.systemFontOfSize(24)
        page2.titlePositionY = self.view.frame.size.height/2 + 180 + 20
        page2.titleColor = UIColor.blackColor()
        
        page2.desc = NSLocalizedString("guide2SubTitle", comment: "")
        page2.descColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
        page2.descFont = UIFont.systemFontOfSize(15)
        page2.descPositionY = self.view.frame.size.height/2 + 150 + 20
        
        page2.titleIconView = UIImageView(image: UIImage(named: "guide2Image"))
//        page2.titleIconView.sizeToFit()
        page2.titleIconView.frame = CGRectMake(0, 0, self.view.frame.size.width-6, self.view.frame.size.width)
        page2.titleIconView.contentMode = UIViewContentMode.ScaleAspectFit
        page2.titleIconPositionY = self.view.frame.size.height/2 - 100 - 30
        pages.append(page2)
        
        let page3 = EAIntroPage()
        page3.title = NSLocalizedString("guide3Title", comment: "")
        page3.titleFont = UIFont.systemFontOfSize(24)
        page3.titlePositionY = self.view.frame.size.height/2 + 180 + 20
        page3.titleColor = UIColor.blackColor()
        
        page3.desc = NSLocalizedString("guide3SubTitle", comment: "")
        page3.descColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
        page3.descFont = UIFont.systemFontOfSize(15)
        page3.descPositionY = self.view.frame.size.height/2 + 150 + 20
        
        page3.titleIconView = UIImageView(image: UIImage(named: "guide3Image"))
//        page3.titleIconView.sizeToFit()
        page3.titleIconView.frame = CGRectMake(0, 0, self.view.frame.size.width-6, self.view.frame.size.width-100)
        page3.titleIconView.contentMode = UIViewContentMode.ScaleAspectFit
        page3.titleIconPositionY = self.view.frame.size.height/2 - 50 - 30
        pages.append(page3)

        
        let page4 = EAIntroPage()
//        page3.title = NSLocalizedString("guide3Title", comment: "")
//        page3.titleFont = UIFont.systemFontOfSize(24)
//        page3.titlePositionY = self.view.frame.size.height/2 + 180
//        page3.titleColor = UIColor.blackColor()
//        
//        page3.desc = NSLocalizedString("guide3SubTitle", comment: "")
//        page3.descColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
//        page3.descFont = UIFont.systemFontOfSize(15)
//        page3.descPositionY = self.view.frame.size.height/2 + 130
//        
        page4.titleIconView = UIImageView(image: UIImage(named: "guide4Image"))
        page4.titleIconView.sizeToFit()
//        page4.titleIconView.frame = CGRectMake(0, 0, self.view.frame.size.width-6, page1.titleIconView.frame.height)
        page4.titleIconView.contentMode = UIViewContentMode.ScaleAspectFit
        page4.titleIconPositionY = self.view.frame.size.height/2 - 170
        pages.append(page4)

        
        
        
        
        introView = EAIntroView(frame: self.view.bounds, andPages: pages)
        introView?.backgroundColor = UIColor.whiteColor()
        introView?.delegate = self
        introView?.swipeToExit = false
        introView?.showSkipButtonOnlyOnLastPage = true
        introView?.skipButtonAlignment = EAViewAlignment.Center
        introView?.skipButtonY = 200
        introView?.skipButton.titleLabel?.font = UIFont.systemFontOfSize(23)
        introView?.skipButton.setTitleColor(UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0), forState: UIControlState.Normal)
//        introView?.skipButton.setTitle("Get Started", forState: UIControlState.Normal)
        introView?.skipButton.setTitle(NSLocalizedString("Get Started", comment: ""), forState: UIControlState.Normal)
        
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