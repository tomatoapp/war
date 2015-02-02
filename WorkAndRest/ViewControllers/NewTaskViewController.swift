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

class NewTaskViewController: BaseViewController, ItemDetailViewControllerDelegate {

    // MARK: - Properties
    
    @IBOutlet var editTaskTitleButton: UIButton!
    @IBOutlet var startNowButton: UIButton!
    @IBOutlet var startLaterButton: UIButton!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTaskTitleSegue" {
            let controller = segue.destinationViewController as ItemDetailViewController
            controller.delegate = self
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
    }
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!) {
        
    }
    
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!) {
        
    }
    
    
}
