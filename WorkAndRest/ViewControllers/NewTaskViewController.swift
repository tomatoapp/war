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

class NewTaskViewController: BaseViewController, TaskTitleViewControllerDelegate, TaskTitleViewDelegate, StartViewControllerDelegate  {
    
    // MARK: - Properties
    
    @IBOutlet var startButton: UIButton!
//    @IBOutlet var startNowButton: UIButton!
//    @IBOutlet var startLaterButton: UIButton!
//    @IBOutlet var timeSelector: TimeSelectorView!
    @IBOutlet var taskTitleView: TaskTitleView!
//    @IBOutlet var completionCycleView: CompletionCycleView!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
//    var number = GlobalConstants.DEFAULT_NUMBER
    var startView: UIView?
    
    // MARK: - Lifecycle
    
    @IBAction func cancleButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.timeSelector.delegate = self
        self.taskTitleView.delegate = self
//        self.completionCycleView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController!.interactivePopGestureRecognizer.enabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController!.interactivePopGestureRecognizer.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTaskTitleSegue" {
            //            let controller = segue.destinationViewController as ItemDetailViewController
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! TaskTitleViewController
            controller.delegate = self
            controller.copyTaskItem = self.taskItem
        } else if segue.identifier == "StartSegue" {
            let controller = segue.destinationViewController as! StartViewController
            controller.delegate = self
        }
    }
    
    // MARK: - Events
    
    @IBAction func startButtonClick(sender: AnyObject) {
        /*
        if WARDevice.isiOS7() {
            self.startView = self.getStartView()
            let tap = UITapGestureRecognizer(target: self, action: "cancel:")
            self.startView!.addGestureRecognizer(tap)
            self.hideStartView(self.startView!, animated: false)
            self.showStartView(self.startView!, animated: true)
        } else {
            self.performSegueWithIdentifier("StartSegue", sender: nil)
        }
        */
        
        self.startViewController(nil, didSelectItem: StartType.Later)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        self.taskItem = item
        self.taskTitleView.setTitle(item.title)
        
        
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        self.taskItem = item
        self.taskTitleView.setTitle(item.title)
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
        
    }
    
    // MARK: - TimeSelectorViewDelegate
    
    /*
    func timeSelectorView(selectorView: TimeSelectorView!, didSelectTime minutes: Int) {
        self.minutes = minutes
    }
    
    */
    
    // MARK: - TaskTitleViewDelegate
    
    func taskTitleView(view: TaskTitleView!, didClickedEditTitleButton sender: UIButton!) {
        self.performSegueWithIdentifier("EditTaskTitleSegue", sender: nil)
    }
    
    // MARK: - StartViewControllerDelegate
    
    func startViewController(sender: StartViewController?, didSelectItem type: StartType) {
        switch type {
        case .Now, .Later:
            if self.taskItem == nil {
                self.taskItem = Task()
                self.taskItem!.title = NSLocalizedString("Task", comment: "")
            }
//            self.taskItem!.expect_times = self.number
            self.taskItem!.minutes = self.minutes
            self.delegate?.newTaskViewController(self, didFinishAddingTask: self.taskItem, runningNow: type == .Now)
            break
            
        case .Cancel:
            break
        }
    }
    
    // MARK: - CompletionCycleViewDelegate
    
    /*
    func completionCycleView(sender: CompletionCycleView, didSelectedNumber number: Int) {
        self.number = number
    }
    
    */
    /*
    
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
        let iconImageView = self.view.viewWithTag(TAG_ICON) as! UIImageView!
        let startTextLabel = self.view.viewWithTag(TAG_STARTTEXT) as! UILabel!
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
            make.width.mas_equalTo()(self.view.mas_width).offset()(-20)
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
    
    */
    override func updateViewConstraints() {
//        self.adapteDifferentScreenSize()
        super.updateViewConstraints()
    }
    
    // MARK: - Methods
    
    func getStartView() -> UIView {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        let bgView = UIView()
        bgView.backgroundColor = UIColor.clearColor()
        let toolBar = UIToolbar()
        toolBar.autoresizingMask = self.view.autoresizingMask
        bgView.insertSubview(toolBar, atIndex: 0)
        self.view.addSubview(bgView)
        
        let startNowButton = UIButton()
        let startLaterButton = UIButton()
        startNowButton.frame = CGRectMake(0, 0, 98, 99)
        startLaterButton.frame = CGRectMake(0, 0, 98, 99)
        startNowButton.setImage(UIImage(named: NSLocalizedString("Start Now", comment: "")), forState: UIControlState.Normal)
        startLaterButton.setImage(UIImage(named: NSLocalizedString("Start Later", comment: "")), forState: UIControlState.Normal)
        
        startNowButton.addTarget(self, action: "startNowButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        startLaterButton.addTarget(self, action: "startLaterButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        bgView.addSubview(startNowButton)
        bgView.addSubview(startLaterButton)
        
        startNowButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(bgView.mas_centerX)
            make.centerY.equalTo()(bgView.mas_centerY).offset()(-76.5)
            return ()
        }
        
        startLaterButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(bgView.mas_centerX)
            make.centerY.equalTo()(bgView.mas_centerY).offset()(88.5)
            return ()
        }
        
        return bgView
        
    }
    
    func updateView(view: UIView, newFrame: CGRect, withDuration duration: NSTimeInterval, animated: Bool) {
        if animated {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                view.frame = newFrame
            })
        } else {
            view.frame = newFrame
        }
    }
    
    func showStartView(view: UIView, animated: Bool) {
        let frame = self.view.frame
        self.updateView(view, newFrame: frame, withDuration: 0.1, animated: animated)
    }
    
    func hideStartView(view: UIView, animated: Bool) {
        var frame = self.view.frame
        frame.origin.y += frame.size.height
        self.updateView(view, newFrame: frame, withDuration: 0.3, animated: animated)
    }
    
    func cancel(sender: AnyClass?) {
        self.hideStartView(self.startView!, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func startNowButtonClicked(sender: UIButton!) {
        self.cancel(nil)
        self.startViewController(nil, didSelectItem: StartType.Now)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startLaterButtonClicked(sender: UIButton!) {
        self.cancel(nil)
        self.startViewController(nil, didSelectItem: StartType.Later)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}











