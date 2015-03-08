//
//  GuideViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 3/8/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, UIPageViewControllerDataSource {

    var guideViewControllers: Array<UIViewController>!
    var pageViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.redColor()
        
        let pageContentViewController: UIPageViewController = storyboard?.instantiateViewControllerWithIdentifier("pageViewController") as UIPageViewController
        
        pageContentViewController.dataSource = self
        
        self.addChildViewController(pageContentViewController)
        self.view.addSubview(pageContentViewController.view)
        pageContentViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
        let guideViewController1: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController1") as UIViewController
        let guideViewController2: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController2") as UIViewController
        let guideViewController3: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController3") as UIViewController
        let guideViewController4: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController4") as UIViewController
        let guideViewController5: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("guideViewController5") as UIViewController
        guideViewControllers = [guideViewController1, guideViewController2, guideViewController3, guideViewController4, guideViewController5]
        
        let viewController = self.guideViewControllers[0]
        let viewControllers = [viewController]
        pageContentViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - PageViewController DataSource
 
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = find(self.guideViewControllers, viewController)
        if index == 0 || index == NSNotFound {
            return nil
        }
        index! -= 1
        return self.guideViewControllers[index!]
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = find(self.guideViewControllers, viewController)
        if index == NSNotFound {
            return nil
        }
        index! += 1
        if index! >= self.guideViewControllers.count {
            return nil
        }
        return self.guideViewControllers[index!]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.guideViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    

}
