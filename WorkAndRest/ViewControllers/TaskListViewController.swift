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

class TaskListViewController: BaseTableViewController,TaskTitleViewControllerDelegate, NewTaskViewControllerDelegate, TaskListItemCellDelegate, SWTableViewCellDelegate, TaskRunnerManagerDelegate, TaskListHeaderViewDelegate, TaskManagerDelegate {
    
    var allTasks = [Task]()
    var taskRunner: TaskRunner!
    var handleType = HandleType.None
    var taskRunnerManager: TaskRunnerManager?
    var headerView: TaskListHeaderView?
    var tableViewHeader: TableViewHeader?
    
    var taskManager = TaskManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "TaskListItemCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 10))
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
        
        self.taskRunnerManager = TaskRunnerManager.sharedInstance
        self.taskRunnerManager!.delegate = self
        
        self.taskRunner = TaskRunner.sharedInstance
        //self.headerView.delegate = self
        
        self.taskManager.delegate = self
        
        let result = self.loadAllTasks()
        if result == nil {
            return
        }
        allTasks = self.sortTasks(result!)!
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.taskRunner.isRunning {
            let task = allTasks.filter { $0.taskId == self.taskRunner.runningTaskID() }.first!
            task.lastUpdateTime = self.taskRunner.taskItem.lastUpdateTime
        }
        allTasks = self.sortTasks(allTasks)!
        self.tableView.reloadData()
        //self.refreshHeaderView()
    }
    
    
    func headerHeight() -> CGFloat {
        if WARDevice.getPhoneType() == PhoneType.iPhone4 {
            return 90
        }
        return HEADER_HEIGHT
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createTaskButtonClick(sender: AnyObject) {
        self.createTask()
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
        cell.taskEventDelegate = self
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
            if self.taskRunner.readyTaskID() == task.taskId {
                self.taskRunner.delegate = cell
                cell.start()
            }
            break
            
        case .Running:
            if self.taskRunner.runningTaskID() == task.taskId {
                self.taskRunner.delegate = cell
                cell.switchToRunningPoint()
                cell.switchViewToRunningState()
                self.enableTableViewHeaderViewWithAnimate( self.headerView == nil ? true : false)

                if cell.taskItem!.minutes * 60 - 2 >= self.taskRunner.seconds {
                    cell.taskItemBaseView.switchToBreakButton()
//                    self.headerView.flipToTimerViewSide()
                }
                
            } else {
                // Some other task is running now. so I need to disable you... I'm sorry... :(
                if task.completed {
                    //                    cell.taskItemBaseView.refreshViewByState(TaskState.Completed, animation: true)
                    //cell.disable(TaskState.Completed, animation: true)
                    cell.reset(TaskState.Completed, animation: true)
                } else {
                    cell.reset(TaskState.Normal, animation: true)
                    cell.disable(TaskState.Normal, animation: true)
                }
            }
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = allTasks[indexPath.row]
        let copyItem = item.copy() as! Task
        self.performSegueWithIdentifier("ShowItemDetailsSegue", sender: copyItem)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = allTasks[indexPath.row]
            //            DBOperate.deleteTask(task)
            self.taskManager.removeTask(task)
            let indexPaths = [indexPath]
            self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EditItem" {
            let controller = segue.destinationViewController as! TaskTitleViewController
            controller.copyTaskItem = sender as! Task?
            controller.delegate = self
        } else if segue.identifier == "NewTaskSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewTaskViewController
            controller.delegate = self
        } else if segue.identifier == "ShowItemDetailsSegue" {
            
            let controller = segue.destinationViewController as! TaskDetailsViewController
            let selectedTask = sender as! Task!
            controller.taskItem = selectedTask
            //self.taskRunner.delegate = controller
            controller.taskRunner = self.taskRunner
        }
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
        
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        handleType = HandleType.AddOrEdit
        //        item.lastUpdateTime = NSDate()
        //        DBOperate.updateTask(item)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: item, repeats: false)
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
    }
    
    // MARK: - NewTaskViewControllerDelegate
    
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!, runningNow runNow: Bool) {
        
        
        //        for _ in 1...100 {
        //             DBOperate.insertTask(item)
        //        }
        
        //        if DBOperate.insertTask(item) {
        if self.taskManager.addTask(item) {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
            if runNow {
                self.taskRunner.setupTaskItem(item)
                self.refreshHeaderView()
                self.reloadTableViewWithTimeInterval(1.0)
            }
        }
    }
    
    // MARK: - TaskListItemCellDelegate
    
    func readyToStart(sender: TaskListItemCell!) {
        if self.taskRunner!.isRunning {
            return
        }
        self.taskRunner.setupTaskItem(sender.taskItem!)
        self.handleType = HandleType.Start
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: sender.taskItem, repeats: false)
        
//        self.tableView.tableHeaderView = self.createHeaderView()
        self.enableTableViewHeaderViewWithAnimate(true)
    }
    
    func tick(sender: TaskListItemCell!, seconds: Int) {
        if self.headerView == nil {
            self.enableTableViewHeaderViewWithAnimate(true)
        }

        self.headerView!.updateTime(self.getTimerMinutesStringBySeconds(seconds), seconds: self.getTimerSecondsStringBySeconds(seconds))
        self.tableViewHeader!.updateTime(self.getTimerMinutesStringBySeconds(seconds), seconds: self.getTimerSecondsStringBySeconds(seconds))
        
        if sender.taskItem!.minutes * 60 - 2 == seconds {
//            self.headerView.flipToTimerViewSide()
            // self.tableView.tableHeaderView = self.createHeaderView()
            sender.taskItemBaseView.switchToBreakButton()
        }
        
    }
    
    func completed(sender: TaskListItemCell!) {
        //        self.recordWork(true)
        self.reloadTableViewWithTimeInterval(0.5)
//        self.headerView.flipToStartViewSide()
        //self.tableView.tableHeaderView = nil
        self.disableTableViewHeaderView()
        
        self.taskManager.completeOneTimer(self.taskRunner.taskItem)
    }
    
    func breaked(sender: TaskListItemCell!) {
        self.reloadTableViewWithTimeInterval(0.5)
//         self.headerView.flipToStartViewSide()
        // self.tableView.tableHeaderView = nil
        self.disableTableViewHeaderView()
        
        self.taskManager.breakOneTimer(self.taskRunner.taskItem)
    }
    
    func activated(sender: TaskListItemCell!) {
        var baseItem = allTasks.filter{ $0.taskId == sender.taskItem!.taskId }.first!
        baseItem.completed = false
        self.reloadTableViewWithTimeInterval(0.0)
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
                //                task.completed = true
                //                DBOperate.updateTask(task)
                self.taskManager.markDoneTask(task)
                
                if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_hasShownMarkDoneTutorial) {
                        self.showTutorial()
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_hasShownMarkDoneTutorial)
                }
                
                // Refresh the tableview.
                let indexPath = NSIndexPath(forRow: find(allTasks, task)!, inSection: 0)
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
    
    func showTutorial() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            let alert = UIAlertView()
            alert.title = NSLocalizedString("MarkDoneAlertTitle", comment: "")
            alert.message = NSLocalizedString("MarkDoneAlertMsg", comment: "")
            alert.addButtonWithTitle(NSLocalizedString("MarkDoneAlertButton", comment: ""))
            alert.show()
            return
        })
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
            println("There is a task is running, you can not create a new task.")
            return
        }
        self.performSegueWithIdentifier("NewTaskSegue", sender: nil)
    }
    
    func loadAllTasks() -> Array<Task>? {
        return self.taskManager.loadTaskList()
    }
    
    func sortTasks(list: Array<Task>) -> Array<Task>? {
        return list.sorted { $0.lastUpdateTime.compare($1.lastUpdateTime) == NSComparisonResult.OrderedDescending }
    }
    
    let HEADERVIEW_OFFSET: CGFloat = 8
    let LINE_HEIGHT: CGFloat = 0.5
    
    func createHeaderView() -> UIView {
        let baseView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.headerHeight() + HEADERVIEW_OFFSET))
        //baseView.backgroundColor = UIColor.whiteColor()
        headerView = TaskListHeaderView(frame: CGRectMake(0, 0, baseView.frame.size.width, self.headerHeight()))
        baseView.addSubview(headerView!)
        
        headerView!.mas_makeConstraints { make in
            make.width.equalTo()(baseView.frame.size.width)
            make.height.equalTo()(self.headerHeight())
            //            make.centerX.equalTo()(baseView.mas_centerX)
            make.top.equalTo()(baseView.mas_top)
            //            make.centerY.equalTo()(baseView.mas_centerY)
            return ()
        }
        headerView!.delegate = self
        
        let line = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, LINE_HEIGHT))
        line.backgroundColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 0.8)
        baseView.addSubview(line)
        line.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(baseView.mas_bottom).offset()(-self.HEADERVIEW_OFFSET)
            make.width.equalTo()(baseView.frame.size.width)
            make.height.equalTo()(self.LINE_HEIGHT)
            return ()
        }
        return baseView
    }
    
    func refreshHeaderView() {
        
        if self.headerView == nil {
            return
        }
        
        //self.enableTableViewHeaderView()
        
        if self.taskRunner.taskItem == nil && self.headerView!.isInTimersViewSide(){

//             self.headerView.flipToStartViewSide()
            // self.tableView.tableHeaderView = nil
            //self.disableTableViewHeaderView()
            return
        }
        
        if self.taskRunner.taskItem == nil {
            return
        }
        
//        if self.tableView.tableHeaderView == nil {
//            self.tableView.tableHeaderView = self.createHeaderView()
//            self.tableView.reloadData()
//        }
        
        self.headerView!.updateTime(self.getTimerMinutesStringBySeconds(self.taskRunner.seconds), seconds: self.getTimerSecondsStringBySeconds(self.taskRunner.seconds))
        if self.taskRunner.taskItem.minutes * 10 - 2 >= self.taskRunner.seconds && !self.headerView!.isInTimersViewSide() {
            self.headerView!.flipToTimerViewSide()
        }
    }
    
    func insertItem(val: NSTimer) {
        let item = val.userInfo as! Task
        self.tableView.beginUpdates()
        allTasks.insert(item, atIndex: 0)
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        var indexPaths = [indexPath]
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
    
    func insertItem(item: Task!, withRowAnimation animation: UITableViewRowAnimation) {
        self.tableView.beginUpdates()
        allTasks.insert(item, atIndex: 0)
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        var indexPaths = [indexPath]
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        self.tableView.endUpdates()
    }
    
    func deleteItem(item: Task!, withRowAnimation animation: UITableViewRowAnimation) {
        
        self.tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: find(allTasks, item)!, inSection: 0)
        let indexPaths = [indexPath]
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        allTasks.removeAtIndex(find(allTasks, item)!)
        self.tableView.endUpdates()
    }
    
    func moveItemToTop(val: NSTimer) {
        let copyItem = val.userInfo as! Task
        let result = allTasks.filter{ $0.taskId == copyItem.taskId }
        if result.count <= 0 { // Can not found it, maybe deleted it just now.
            return
        }
        var baseItem = result.first!
        if find(allTasks, baseItem) == 0 { // if this item is already in the top, then return
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
    
    func newTaskButtonClick(sender: UIButton) {
        //self.performSegueWithIdentifier("NewTaskSegue", sender: nil)
        
        
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
        var leftUtilityButtons = NSMutableArray()
        if state == TaskState.Normal {
            leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "swipe_item_markdone"), selectedIcon: UIImage(named: "swipe_item_markdone_press"))
        }
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "swipe_item_delete"), selectedIcon: UIImage(named: "swipe_item_delete_press"))
        
        return leftUtilityButtons
    }
    
    func disableTableViewHeaderView() {
        println("func disableTableViewHeaderView()")
        let tempTableViewHeader: TableViewHeader = self.tableViewHeader?.copy() as! TableViewHeader
        self.view.addSubview(tempTableViewHeader)
        tempTableViewHeader.moveCenterContentView()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            tempTableViewHeader.moveOutContentView()
            self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 10))

            
        }) { (finished) -> Void in
            self.headerView = nil
            tempTableViewHeader.removeFromSuperview()
        }
    }
    
    func enableTableViewHeaderViewWithAnimate(animate: Bool) {
        println("func enableTableViewHeaderViewWithAnimate(\(animate))")
        if self.headerView == nil {
            self.setupHeaderView()
        }
        self.headerView!.moveOutContentView()
        self.tableViewHeader?.moveOutContentView()
        
        UIView.animateWithDuration(animate ? 0.5 : 0.0, animations: { () -> Void in
            self.tableView.tableHeaderView = self.tableViewHeader
            self.tableViewHeader?.moveCenterContentView()
            
            }) { (finished) -> Void in
        }
    }
    
    func setupHeaderView() {
        self.createHeaderView()
        self.tableViewHeader = TableViewHeader(frame: CGRectMake(0, 0, self.view.frame.width, 100))
    }
}