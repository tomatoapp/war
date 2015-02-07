//
//  NewTaskViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/29.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit



protocol NewTaskViewControllerDelegate {
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!, runningNow run: Bool)
    //func newTaskViewControllerDidCancel(controller: ItemDetailViewController!)
}

class NewTaskViewController: BaseViewController, ItemDetailViewControllerDelegate, TimeSelectorViewDelegate, TaskTitleViewDelegate {

    // MARK: - Properties
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var startNowButton: UIButton!
    @IBOutlet var startLaterButton: UIButton!
    @IBOutlet var timeSelector: TimeSelectorView!
    @IBOutlet var taskTitleView: TaskTitleView!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    var blurView: UIView?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
        self.timeSelector.delegate = self
        self.taskTitleView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTaskTitleSegue" {
//            let controller = segue.destinationViewController as ItemDetailViewController
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as ItemDetailViewController
            controller.delegate = self
            controller.copyTaskItem = self.taskItem
        }
    }
    
    // MARK: - Events
    
    @IBAction func startButtonClick(sender: AnyObject) {
        //self.addBlurView()
    }
    
    @IBAction func startNowClick(sender: AnyObject) {
        if self.taskItem == nil {
            return
        }
        self.taskItem!.minutes = self.minutes
        if self.delegate != nil {
            self.delegate!.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: true)
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func startLaterClick(sender: AnyObject) {
        if self.taskItem == nil {
            return
        }
        self.taskItem!.minutes = self.minutes
        if self.delegate != nil {
            self.delegate!.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: false)
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishAddingTask item: Task!) {
        self.taskItem = item
        self.taskTitleView.setTitle(item.title)
        
        
    }
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!) {
        self.taskItem = item
        self.taskTitleView.setTitle(item.title)
    }
    
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!) {
        
    }
    
    // MARK: - TimeSelectorViewDelegate
    
    func timeSelectorView(selectorView: TimeSelectorView!, didSelectTime minutes: Int) {
        self.minutes = minutes
        
    }
    
    // MARK: - TaskTitleViewDelegate
    
    func taskTitleView(view: TaskTitleView!, didClickedEditTitleButton sender: UIButton!) {
        self.performSegueWithIdentifier("EditTaskTitleSegue", sender: nil)
    }
    
    func addBlurView() {
        blurView = self.initBlurView()
        self.view.addSubview(blurView!)
        let tap = UITapGestureRecognizer(target: self, action: Selector("blurViewClick:"))
        blurView!.addGestureRecognizer(tap)
        blurView!.frame = CGRectMake(0, self.view.frame.size.height*2, self.view.frame.size.width, self.view.frame.size.height)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.blurView!.frame = self.view.frame
        }) { (finished) -> Void in
            if finished {
                self.navigationController!.navigationBarHidden = true
            }
        }
    }
    
    func blurViewClick(sender: UITapGestureRecognizer!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.blurView!.frame = CGRectMake(0, self.view.frame.size.height*2, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                if finished {
                    self.navigationController!.navigationBarHidden = false
                }
        }
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
}
