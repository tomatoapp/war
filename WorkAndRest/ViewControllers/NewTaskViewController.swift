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
    
    @IBOutlet var startNowButton: UIButton!
    @IBOutlet var startLaterButton: UIButton!
    @IBOutlet var timeSelector: TimeSelectorView!
    @IBOutlet var taskTitleView: TaskTitleView!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    
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
            let controller = segue.destinationViewController as ItemDetailViewController
            controller.delegate = self
            controller.copyTaskItem = self.taskItem
        }
    }
    
    // MARK: - Events
    
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
}
