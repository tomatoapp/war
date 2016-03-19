//
//  TaskListViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/29.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

enum HandleType: Int {
    case None, AddOrEdit, Start
}

let HEADER_HEIGHT: CGFloat = 125
//let TIP_TAG_CREATE_TASK: Int = 1001
//let TIP_TAG_START_TASK: Int = 1002

class TaskListViewController: BaseTableViewController,TaskTitleViewControllerDelegate, NewTaskViewControllerDelegate, TaskListItemCellDelegate, SWTableViewCellDelegate, TaskRunnerManagerDelegate, TaskListHeaderViewDelegate, TaskManagerDelegate, PFLogInViewControllerDelegate {
    
    @IBOutlet var createTaskButtonItem: UIBarButtonItem!
    var allTasks = [Task]()
    var taskRunner: TaskRunner!
    var handleType = HandleType.None
    var taskRunnerManager: TaskRunnerManager?
    var tableViewHeader: TableViewHeader?
    
    var taskManager = TaskManager.sharedInstance
    
    var firstCell: TaskListItemCell?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "TaskListItemCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 10))
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
        
        self.taskRunner = TaskRunner.sharedInstance
        self.taskManager.delegate = self
        
        self.taskRunnerManager = TaskRunnerManager.sharedInstance
        self.taskRunnerManager!.delegate = self
        
        let result = self.loadAllTasks()
        if result != nil {
            allTasks = self.sortTasks(result!)!
            self.tableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "introDidFinish", name: ROOTVIEWCONTROLLER_INTRO_DID_FINISH_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "firstTaskCreateSuccess", name: TASKMANAGER_FIRST_TASK_CREATE_SUCCESS_NOTIFICATION, object: nil)
        
        
        let loginViewController = LogInViewController()
        loginViewController.delegate = self
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Events
    
    @IBAction func createTaskButtonClick(sender: AnyObject) {
        self.createTask()
        
    }
    
    // MARK: - NotificationCenter
    
    func introDidFinish() {
        self.handleCreateTaskTip()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.registerUserNotificationSettings()
        })
    }
    
    func firstTaskCreateSuccess() {
        self.handleStartTaskTip()
    }
    
    func registerUserNotificationSettings() {
        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        application.registerForRemoteNotifications()
    }
    
    func headerHeight() -> CGFloat {
        if WARDevice.getPhoneType() == PhoneType.iPhone4 {
            return 90
        }
        return HEADER_HEIGHT
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let task = allTasks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! TaskListItemCell
        cell.custom_delegate = self
        cell.delegate = self
        if task.completed {
            cell.leftUtilityButtons = self.leftUtilityButtonsByTaskState(TaskState.Completed) as [AnyObject]
        } else {
            cell.leftUtilityButtons = self.leftUtilityButtonsByTaskState(TaskState.Normal) as [AnyObject]
        }
        cell.taskItem = (task.copy() as! Task)
        cell.refresh()
        
        
        cell.taskRunner = self.taskRunner
        
        switch self.taskRunner.state {
        case .UnReady:
            if task.completed {
                cell.reset(TaskState.Completed, animation: false)
            } else {
                cell.reset(TaskState.Normal, animation: false)
            }
            break
            
        case .Ready:
            if self.taskRunner.isSameTask(task) {
                self.taskRunner.delegate = cell
                cell.start()
            }
            break
            
        case .Running:
            if self.taskRunner.isSameTask(task) {
                self.taskRunner.delegate = cell
                cell.switchToRunningPoint()
                cell.switchViewToRunningState()
                if self.tableViewHeader == nil {
                    self.enableTableViewHeaderViewWithAnimate( self.tableViewHeader == nil ? true : false)
                }
                cell.taskItemBaseView.switchToBreakButton()
                
            } else {
                // Some other task is running now. so I need to disable you... I'm sorry... :(
                if task.completed {
                    cell.reset(TaskState.Completed, animation: true)
                } else {
                    cell.reset(TaskState.Normal, animation: true)
                    cell.disable(TaskState.Normal, animation: true)
                }
            }
            break
        }
        if indexPath.row == 0 {
            firstCell = cell
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = allTasks[indexPath.row]
            self.taskManager.removeTask(task)
            self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewTaskSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewTaskViewController
            controller.delegate = self
        }
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        handleType = HandleType.AddOrEdit
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: item, repeats: false)
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
    }
    
    // MARK: - NewTaskViewControllerDelegate
    
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!) {
        if self.taskManager.addTask(item) {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
        }
    }
    
    // MARK: - TaskListItemCellDelegate
    
    func ready(sender: TaskListItemCell!) {
        
        if self.taskRunner!.isRunning {
            return
        }
        self.taskRunner.setupTaskItem(sender.taskItem!)
        self.handleType = HandleType.Start
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: sender.taskItem, repeats: false)
        
        self.setupHeaderView()
        self.tableViewHeader?.updateTime(sender.taskItem!.getTimerMinutesString(), seconds: sender.taskItem!.getTimerSecondsString())
        self.enableTableViewHeaderViewWithAnimate(true)
    }
    
    func tick(sender: TaskListItemCell!, seconds: Int) {
        if self.tableViewHeader == nil {
            self.enableTableViewHeaderViewWithAnimate(true)
        }
        
        self.tableViewHeader!.updateTime(self.getTimerMinutesStringBySeconds(seconds), seconds: self.getTimerSecondsStringBySeconds(seconds))
    }
    
    func completed(sender: TaskListItemCell!) {
        self.reloadTableViewWithTimeInterval(0.5)
        self.disableTableViewHeaderView()
        
        self.taskManager.completeOneTimer(self.taskRunner.taskItem)
        
        self.handleSwipeCellRightTip()
    }
    
    func breaked(sender: TaskListItemCell!) {
        self.reloadTableViewWithTimeInterval(0.5)
        self.disableTableViewHeaderView()
        
        self.taskManager.breakOneTimer(self.taskRunner.taskItem)
    }
    
    func activated(sender: TaskListItemCell!) {
        let baseItem = allTasks.filter{ $0.taskId == sender.taskItem!.taskId }.first!
        baseItem.completed = false
        self.reloadTableViewWithTimeInterval(0.0)
    }
    
    func quickFinish(sender: TaskListItemCell) {
        self.taskRunner.taskItem = sender.taskItem
        self.taskManager.completeOneTimer(self.taskRunner.taskItem)
        self.reload()
    }
    
    
    
    // MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        
        cell.hideUtilityButtonsAnimated(true)
        let taskItem = (cell as! TaskListItemCell).taskItem!
        let task = allTasks.filter{ $0.taskId == taskItem.taskId }.first!
        switch index {
        case 0:
            if taskItem.completed {
                // Delete it from the database.
                //                DBOperate.deleteTask(taskItem)
                self.taskManager.removeTask(taskItem)
                
                // Remove it from the tableView.
                self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                
                // Save it to the database.
                self.taskManager.markDoneTask(task)
                
                // self.handleRevertTaskTipAtCell(cell as! TaskListItemCell)
                
                // Refresh the tableview.
                let indexPath = NSIndexPath(forRow: allTasks.indexOf(task)!, inSection: 0)
                let indexPaths = [indexPath]
                self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            break
            
        case 1:
            //            DBOperate.deleteTask(taskItem)
            self.taskManager.removeTask(taskItem)
            // Remove it from the tableView.
            self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
            break
            
        default:
            break
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        return !self.taskRunner.isRunning
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    // MARK: - TaskRunnerManagerDelegate
    
    func taskRunnerMangerWillFreezeTask(taskManager: TaskRunnerManager!) -> TaskRunner {
        return self.taskRunner!
    }
    
    func taskRunnerManger(taskRunnerManager: TaskRunnerManager!, didActiveFrozenTaskRunner taskRunner: TaskRunner!) {
        self.taskRunner = taskRunner
    }
    
    // MARK: - TaskListHeaderViewDelegate
    
    func taskListHeaderViewStartNewTask(sender: TaskListHeaderView) {
        // self.createTask()
    }
    
    // MARK: - TaskManagerDelegate
    
    func taskManger(taskManager: TaskManager, didActivatedATask task: Task!) {
        let target = allTasks.filter { $0.taskId == task.taskId }.first!
        target.completed = false
        
        allTasks = self.sortTasks(allTasks)!
        self.tableView.reloadData()
    }
    
    // MARK: - Methods
    
    func createTask() {
        if self.taskRunner.isRunning {
            print("There is a task is running, you can not create a new task.")
            return
        }
        self.performSegueWithIdentifier("NewTaskSegue", sender: nil)
    }
    
    func loadAllTasks() -> Array<Task>? {
        return self.taskManager.loadTaskList()
    }
    
    func sortTasks(list: Array<Task>) -> Array<Task>? {
        return list.sort { $0.lastUpdateTime.compare($1.lastUpdateTime) == NSComparisonResult.OrderedDescending }
    }
    
    let HEADERVIEW_OFFSET: CGFloat = 8
    let LINE_HEIGHT: CGFloat = 0.5
    
    func insertItem(val: NSTimer) {
        let item = val.userInfo as! Task
        self.tableView.beginUpdates()
        allTasks.insert(item, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let indexPaths = [indexPath]
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
    
    func insertItem(item: Task!, withRowAnimation animation: UITableViewRowAnimation) {
        self.tableView.beginUpdates()
        allTasks.insert(item, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let indexPaths = [indexPath]
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        self.tableView.endUpdates()
    }
    
    func deleteItem(item: Task!, withRowAnimation animation: UITableViewRowAnimation) {
        
        self.tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: allTasks.indexOf(item)!, inSection: 0)
        let indexPaths = [indexPath]
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        allTasks.removeAtIndex(allTasks.indexOf(item)!)
        self.tableView.endUpdates()
    }
    
    func moveItemToTop(val: NSTimer) {
        let copyItem = val.userInfo as! Task
        let result = allTasks.filter{ $0.taskId == copyItem.taskId }
        if result.count <= 0 { // Can not found it, maybe deleted it just now.
            return
        }
        let baseItem = result.first!
        if allTasks.indexOf(baseItem) == 0 { // if this item is already in the top, then return
            baseItem.title = copyItem.title
            self.tableView.reloadData()
            return
        }
        self.deleteItem(baseItem, withRowAnimation: UITableViewRowAnimation.Top)
        self.insertItem(baseItem, withRowAnimation: UITableViewRowAnimation.Bottom)
        baseItem.title = copyItem.title
        
        self.scrollToTop()
        if handleType == HandleType.AddOrEdit {
            self.reloadTableViewWithTimeInterval(0.5)
        } else if handleType == HandleType.Start {
            self.reloadTableViewWithTimeInterval(1.0)
        }
    }
    
    func scrollToTop() {
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }
    
    func reloadTableViewWithTimeInterval(ti: NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: Selector("reload"), userInfo: nil, repeats: false)
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    func freezeTaskManager(taskRunner: TaskRunner!) {
        self.taskRunnerManager!.freezeTaskManager(taskRunner)
    }
    
    func activeFrozenTaskManager() {
        self.taskRunnerManager!.activeFrozenTaskManager()
    }
    
    func getTimerMinutesStringBySeconds(seconds: Int) -> String {
        return String(format: "%02d", seconds % 3600 / 60)
    }
    
    func getTimerSecondsStringBySeconds(seconds: Int) -> String {
        return String(format: "%02d", seconds % 3600 % 60)
    }
    
    func leftUtilityButtonsByTaskState(state: TaskState) -> NSMutableArray {
        let leftUtilityButtons = NSMutableArray()
        if state == TaskState.Normal {
            leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "swipe_item_markdone"), selectedIcon: UIImage(named: "swipe_item_markdone_press"))
        }
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "swipe_item_delete"), selectedIcon: UIImage(named: "swipe_item_delete_press"))
        
        return leftUtilityButtons
    }
    
    let headerAnimateDuration: NSTimeInterval = 0.3
    func disableTableViewHeaderView() {
        let tempTableViewHeader: TableViewHeader = self.tableViewHeader?.copy() as! TableViewHeader
        self.view.addSubview(tempTableViewHeader)
        tempTableViewHeader.moveCenterContentView()
        UIView.animateWithDuration(headerAnimateDuration, animations: { () -> Void in
            
            tempTableViewHeader.moveOutContentView()
            self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 10))
            
            
            }) { (finished) -> Void in
                //self.headerView = nil
                tempTableViewHeader.removeFromSuperview()
        }
    }
    
    func enableTableViewHeaderViewWithAnimate(animate: Bool) {
        print("func enableTableViewHeaderViewWithAnimate(\(animate))")
        if self.tableViewHeader == nil {
            self.setupHeaderView()
        }
        self.tableViewHeader?.moveOutContentView()
        
        UIView.animateWithDuration(animate ? headerAnimateDuration : 0.0, animations: { () -> Void in
            self.tableView.tableHeaderView = self.tableViewHeader
            self.tableViewHeader?.moveCenterContentView()
            }) { (finished) -> Void in
        }
    }
    
    func setupHeaderView() {
        self.tableViewHeader = TableViewHeader(frame: CGRectMake(0, 0, self.view.frame.width, 100))
    }
    
    func createSampleTask() -> Task {
        let sampleTask = Task()
        sampleTask.taskId = 0
        sampleTask.title = NSLocalizedString("Task Sample", comment: "")
        sampleTask.minutes = 25
        sampleTask.completed = false
        sampleTask.expect_times = 3
        sampleTask.finished_times = 0
        return sampleTask
    }
    
    // MARK: - CMPopTipViewDelegate
    //    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
    //        if popTipView.tag == TIP_TAG_CREATE_TASK {
    //            self.createTask()
    //        }
    //    }
    
    // MARK: - Tip
    
    func getTipViewbyMessage(message: String) -> CMPopTipView {
        let tipView = CMPopTipView(message: message)
        tipView.backgroundColor = UIColor(red: 57/255, green: 187/255, blue: 79/255, alpha: 1.0)
        tipView.textColor = UIColor.whiteColor()
        tipView.borderWidth = 0
        tipView.dismissTapAnywhere = true
        tipView.hasShadow = false
        tipView.hasGradientBackground = false
        return tipView
    }
    
    func getTipViewByTitle(title: String, andMessage message: String) -> CMPopTipView {
        let tipView = CMPopTipView(title: title, message: message)
        tipView.backgroundColor = UIColor(red: 57/255, green: 187/255, blue: 79/255, alpha: 1.0)
        tipView.textColor = UIColor.whiteColor()
        tipView.borderWidth = 0
        tipView.dismissTapAnywhere = true
        tipView.hasShadow = false
        tipView.hasGradientBackground = false
        return tipView
    }
    
    /**
     The + Button (Create Task)
     */
    func handleCreateTaskTip() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_HAS_SETUP_SAMPLE_TASK) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                let createTaskTip = self.getTipViewbyMessage(NSLocalizedString("Let's Create a new task", comment: ""))
                createTaskTip.dismissTapAnywhere = true
                //                createTaskTip.tag = TIP_TAG_CREATE_TASK
                createTaskTip.presentPointingAtBarButtonItem(self.createTaskButtonItem, animated: true)
            })
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_HAS_SETUP_SAMPLE_TASK)
        }
    }
    
    /**
     The > Button on the cell (Start Button)
     */
    func handleStartTaskTip() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_HAS_SHOW_START_TASK_GUIDE) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                let startTaskTip = self.getTipViewbyMessage(NSLocalizedString("Ready to start task", comment: ""))
                startTaskTip.dismissTapAnywhere = true
                startTaskTip.presentPointingAtView(self.firstCell?.startButton(), inView: self.view, animated: true)
            })
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_HAS_SHOW_START_TASK_GUIDE)
        }
    }
    
    /*
    /**
    The revert button on a finished task
    */
    func handleRevertTaskTipAtCell(cell: TaskListItemCell) {
    if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_hasShownMarkDoneTutorial) {
    self.markDoneTip = self.getTipViewByTitle(NSLocalizedString("MarkDoneAlertTitle", comment: ""), andMessage: NSLocalizedString("MarkDoneAlertMsg", comment: ""))
    self.markDoneTip?.presentPointingAtView(cell.startButton(), inView: self.view, animated: true)
    
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_hasShownMarkDoneTutorial)
    }
    
    }
    */
    
    func handleSwipeCellRightTip() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_HAS_SHOW_SWIPE_CELL_RIGHT_GUIDE) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.6 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                let swipeTip = self.getTipViewbyMessage(NSLocalizedString("Try to swipe this task to the right", comment: ""))
                swipeTip.presentPointingAtView(self.firstCell?.taskItemBaseView, inView: self.view, animated: true)
            })
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_HAS_SHOW_SWIPE_CELL_RIGHT_GUIDE)
        }
    }
    
}