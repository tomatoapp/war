//
//  NewTaskViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/29.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

let TIMER_HEIGHT = 63

protocol NewTaskViewControllerDelegate {
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!, runningNow run: Bool)
    //func newTaskViewControllerDidCancel(controller: ItemDetailViewController!)
}

class NewTaskViewController: BaseViewController, TaskTitleViewControllerDelegate, TimeSelectorViewDelegate, TaskTitleViewDelegate, StartViewControllerDelegate, CompletionCycleViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var startNowButton: UIButton!
    @IBOutlet var startLaterButton: UIButton!
    @IBOutlet var timeSelector: TimeSelectorView!
    @IBOutlet var taskTitleView: TaskTitleView!
    @IBOutlet var completionCycleView: CompletionCycleView!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    var number = GlobalConstants.DEFAULT_NUMBER
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSelector.delegate = self
        self.taskTitleView.delegate = self
        self.completionCycleView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.interactivePopGestureRecognizer.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTaskTitleSegue" {
            //            let controller = segue.destinationViewController as ItemDetailViewController
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as TaskTitleViewController
            controller.delegate = self
            controller.copyTaskItem = self.taskItem
        } else if segue.identifier == "StartSegue" {
            let controller = segue.destinationViewController as StartViewController
            controller.delegate = self
        }
    }
    
    // MARK: - Events
    
    @IBAction func startButtonClick(sender: AnyObject) {
        self.performSegueWithIdentifier("StartSegue", sender: nil)
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        self.taskItem?.title = item.title
        self.taskTitleView.setTitle(item.title)
        
        
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        self.taskItem?.title = item.title
        self.taskTitleView.setTitle(item.title)
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
        
    }
    
    // MARK: - TimeSelectorViewDelegate
    
    func timeSelectorView(selectorView: TimeSelectorView!, didSelectTime minutes: Int) {
        self.minutes = minutes
    }
    
    // MARK: - TaskTitleViewDelegate
    
    func taskTitleView(view: TaskTitleView!, didClickedEditTitleButton sender: UIButton!) {
        self.performSegueWithIdentifier("EditTaskTitleSegue", sender: nil)
    }
    
    // MARK: - StartViewControllerDelegate
    
    func startViewController(sender: StartViewController, didSelectItem type: StartType) {
        switch type {
        case .Now, .Later:
            if self.taskItem == nil {
                self.taskItem = Task()
                self.taskItem!.title = NSLocalizedString("Task", comment: "")
                self.taskItem!.expect_times = self.number
            }
            self.taskItem!.minutes = self.minutes
            self.delegate?.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: type == .Now)
            self.navigationController!.popViewControllerAnimated(false)

            break
            
        case .Cancel:
            break
        }
    }
    
    // MARK: - CompletionCycleViewDelegate
    
    func completionCycleView(sender: CompletionCycleView, didSelectedNumber number: Int) {
        self.number = number
    }
    
    let TAG_ICON = 1001
    let TAG_STARTTEXT = 1002
    let TAG_TIMESELECTOR = 1003
    let TAG_TASKTITLE = 1004
    let TAG_COMPLETIONCIRCLE = 1005
    let TAG_STARTBUTTON = 1006
    
    func adapteDifferentScreenSize() {
        
        switch WARDevice.getPhoneType() {
        case .iPhone4:
            self.adapte_iPhone4()
            break
            
        case .iPhone6, .iPhone6Plus:
            self.adapte_iPhone6()
            break
            
        default:
            break
        }
    }
    
    func adapte_iPhone4() {
        let iconImageView = self.view.viewWithTag(TAG_ICON) as UIImageView!
        let startTextLabel = self.view.viewWithTag(TAG_STARTTEXT) as UILabel!
        let timeSelectorView = self.view.viewWithTag(TAG_TIMESELECTOR)
        let completionCirleView = self.view.viewWithTag(TAG_COMPLETIONCIRCLE)
        let taskTitleView = self.view.viewWithTag(TAG_TASKTITLE)
        let startButton = self.view.viewWithTag(TAG_STARTBUTTON)
        
        iconImageView!.removeFromSuperview()
        self.view.addSubview(iconImageView!)
        iconImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(10)
            return ()
        }
        
        startTextLabel.removeFromSuperview()
        self.view.addSubview(startTextLabel)
        startTextLabel.font = UIFont.systemFontOfSize(17)
        startTextLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(iconImageView!.mas_bottom).offset()(0)
            make.height.mas_equalTo()(18)
            make.width.mas_equalTo()(123)
            return ()
        }
        
        timeSelectorView!.removeFromSuperview()
        self.view.addSubview(timeSelectorView!)
        timeSelectorView!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(startTextLabel!.mas_bottom).offset()(15)
            make.height.mas_equalTo()(TIMER_HEIGHT)
            make.width.mas_equalTo()(self.view.mas_width)
            
            return ()
        }
        
        taskTitleView!.removeFromSuperview()
        self.view.addSubview(taskTitleView!)
        taskTitleView!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(timeSelectorView!.mas_bottom).offset()(25)
            make.height.mas_equalTo()(50)
            make.width.mas_equalTo()(self.view.mas_width)
            return ()
        }
        
        completionCirleView!.removeFromSuperview()
        self.view.addSubview(completionCirleView!)
        completionCirleView!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(taskTitleView!.mas_bottom).offset()(-10)
            make.height.mas_equalTo()(80)
            make.width.mas_equalTo()(self.view.mas_width)
            return ()
        }
        
        startButton!.removeFromSuperview()
        self.view.addSubview(startButton!)
        startButton!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.bottom.mas_equalTo()(self.view.mas_bottom).offset()(-10)
            make.height.mas_equalTo()(47)
            make.width.mas_equalTo()(self.view.mas_width).offset()(-20)
            return ()
        }
    }
    
    func adapte_iPhone6() {
        let startTextLabel = self.view.viewWithTag(TAG_STARTTEXT)
        let timeSelectorView = self.view.viewWithTag(TAG_TIMESELECTOR)
        let completionCirleView = self.view.viewWithTag(TAG_COMPLETIONCIRCLE)
        let taskTitleView = self.view.viewWithTag(TAG_TASKTITLE)
        let startButton = self.view.viewWithTag(TAG_STARTBUTTON)
        
        timeSelectorView!.removeFromSuperview()
        self.view.addSubview(timeSelectorView!)
        timeSelectorView?.mas_makeConstraints({ (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(startTextLabel!.mas_bottom).offset()(50)
            make.height.mas_equalTo()(TIMER_HEIGHT)
            make.width.mas_equalTo()(self.view.mas_width)
            return ()
        })
        
        
        taskTitleView!.removeFromSuperview()
        self.view.addSubview(taskTitleView!)
        taskTitleView!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(timeSelectorView!.mas_bottom).offset()(20)
            make.height.mas_equalTo()(TIMER_HEIGHT)
            make.width.mas_equalTo()(self.view.mas_width)
            return ()
        }
        
        completionCirleView!.removeFromSuperview()
        self.view.addSubview(completionCirleView!)
        completionCirleView!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.top.mas_equalTo()(taskTitleView!.mas_bottom).offset()(20)
            make.height.mas_equalTo()(80)
            make.width.mas_equalTo()(self.view.mas_width).offset()(-70)
            return ()
        }
        
        startButton!.removeFromSuperview()
        self.view.addSubview(startButton!)
        startButton!.mas_makeConstraints { (make) -> Void in
            make.centerX.mas_equalTo()(self.view.mas_centerX)
            make.bottom.mas_equalTo()(self.view.mas_bottom).offset()(-50)
            make.height.mas_equalTo()(47)
            make.width.mas_equalTo()(self.view.mas_width).offset()(-20)
            return ()
        }
    }
    
    override func updateViewConstraints() {
        self.adapteDifferentScreenSize()
        super.updateViewConstraints()
    }
}
