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

class NewTaskViewController: BaseViewController, ItemDetailViewControllerDelegate, TimeSelectorViewDelegate {

    // MARK: - Properties
    
    @IBOutlet var editTaskTitleButton: UIButton!
    @IBOutlet var startNowButton: UIButton!
    @IBOutlet var startLaterButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeSelector: TimeSelectorView!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSelector.delegate = self
        self.titleLabel.hidden = true
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
        if self.delegate != nil {
            self.delegate!.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: true)
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func startLaterClick(sender: AnyObject) {
        if self.taskItem == nil {
            return
        }
        if self.delegate != nil {
            self.delegate!.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: false)
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishAddingTask item: Task!) {
        self.taskItem = item
        if !item.title.isEmpty {
            self.editTaskTitleButton.setImage(UIImage(named: "edit_task_title_empty"), forState: UIControlState.Normal)
            self.titleLabel.text = item.title
            self.titleLabel.hidden = false
        }
        
    }
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!) {
        self.taskItem = item
        if item.title.isEmpty {
            self.editTaskTitleButton.setImage(UIImage(named: "edit_task_title"), forState: UIControlState.Normal)
            self.titleLabel.text = item.title
            self.titleLabel.hidden = true
        } else {
            self.editTaskTitleButton.setImage(UIImage(named: "edit_task_title_empty"), forState: UIControlState.Normal)
            self.titleLabel.text = item.title
            self.titleLabel.hidden = false
        }
    }
    
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!) {
        
    }
    
    // MARK: - TimeSelectorViewDelegate
    func timeSelectorView(selectorView: TimeSelectorView!, didSelectTime minutes: Int) {
        self.minutes = minutes
    }
}
