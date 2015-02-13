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

class TaskListViewController: UITableViewController,TaskTitleViewControllerDelegate, NewTaskViewControllerDelegate, TaskListItemCellDelegate, TaskRunnerManagerDelegate, TaskListHeaderViewDelegate {
    
    var allTasks = [Task]()
    var taskRunner: TaskRunner!
    var handleType = HandleType.None
    var taskRunnerManager: TaskRunnerManager?
    var headerView: TaskListHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "TaskListItemCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        self.tableView.tableHeaderView = self.createHeaderView()
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
        
        self.loadAllTasks()
        self.tableView.reloadData()
        
        let line = UIImageView(image: UIImage(named: "line"))
        line.frame = CGRectMake(19.5, CGFloat(self.headerHeight()), 1, self.tableView.frame.size.height)
        self.view.insertSubview(line, atIndex: 0)
        
        self.taskRunnerManager = TaskRunnerManager()
        self.taskRunnerManager!.delegate = self
        
        self.taskRunner = TaskRunner()
        self.headerView.delegate = self
    }
    
    
    func headerHeight() -> Int {
        if WARDevice.getPhoneType() == PhoneType.iPhone4 {
            return 90
        }
        return 130
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.refreshHeaderView()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as TaskListItemCell
        cell.delegate = self
        let task = allTasks[indexPath.row]
        cell.taskItem = (task.copy() as Task)
        cell.refresh()
        
        
        cell.taskRunner = self.taskRunner
        
        switch self.taskRunner.state {
        case .UnReady:
            cell.reset(animation: false)
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
                
                if cell.taskItem!.minutes * 10 - 2 >= self.taskRunner.seconds {
                    cell.taskItemBaseView.switchToBreakButton()
                }
                
            } else {
                cell.disable()
            }
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = allTasks[indexPath.row]
        let copyItem = item.copy() as Task
        self.performSegueWithIdentifier("ShowItemDetailsSegue", sender: copyItem)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = allTasks[indexPath.row]
            DBOperate.deleteTask(task)
            let indexPaths = [indexPath]
            self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let item = allTasks[indexPath.row]
        if self.taskRunner.isRunning {
            return UITableViewCellEditingStyle.None
        }
        return UITableViewCellEditingStyle.Delete
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("identifier = \(segue.identifier)")
        
        if segue.identifier == "EditItem" {
            let controller = segue.destinationViewController as TaskTitleViewController
            controller.copyTaskItem = sender as Task?
            controller.delegate = self
        } else if segue.identifier == "ShowItem" {
            let controller = segue.destinationViewController as WorkWithItemViewController
            controller.taskItem = sender as Task?
        } else if segue.identifier == "NewTaskSegue" {
            let controller = segue.destinationViewController as NewTaskViewController
            controller.delegate = self
        } else if segue.identifier == "ShowItemDetailsSegue" {
            
            let controller = segue.destinationViewController as TaskDetailsViewController
            let selectedTask = sender as Task!
            controller.taskItem = selectedTask
            self.taskRunner.delegate = controller
            controller.taskRunner = self.taskRunner
        }
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
        
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        handleType = HandleType.AddOrEdit
        item.lastUpdateTime = NSDate()
        DBOperate.updateTask(item)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: item, repeats: false)
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
        println("Clicked the cancel button.")
    }
    
    // MARK: - NewTaskViewControllerDelegate
    
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!, runningNow runNow: Bool) {
        
        if DBOperate.insertTask(item) {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
            if runNow {
                self.taskRunner.setupTaskItem(item)
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
        sender.taskItem?.lastUpdateTime = NSDate()
        DBOperate.updateTask(sender.taskItem!)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: sender.taskItem, repeats: false)
    }
    
    func tick(sender: TaskListItemCell!, seconds: Int) {
        self.headerView.updateTime(self.getTimerMinutesStringBySeconds(seconds), seconds: self.getTimerSecondsStringBySeconds(seconds))
        
        if sender.taskItem!.minutes * 10 - 2 == seconds {
            self.headerView.flipToTimerViewSide()
            sender.taskItemBaseView.switchToBreakButton()
        }
        
    }
    
    func completed(sender: TaskListItemCell!) {
        self.recordWork(true)
        self.reloadTableViewWithTimeInterval(0.5)
        self.headerView.flipToStartViewSide()
        
    }
    
    func breaked(sender: TaskListItemCell!) {
        println("breaked")
        self.recordWork(false)
        self.reloadTableViewWithTimeInterval(0.0)
        self.headerView.flipToStartViewSide()
    }
    
    func activated(sender: TaskListItemCell!) {
        var baseItem = allTasks.filter{ $0.taskId == sender.taskItem!.taskId }.first!
        baseItem.completed = false
        self.reloadTableViewWithTimeInterval(0.0)
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
        self.performSegueWithIdentifier("NewTaskSegue", sender: nil)
    }
    
    // MARK: - Methods
    
    func loadAllTasks() {
        var result = DBOperate.loadAllTasks()
        for item in result! {
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.defaultTimeZone()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeStr = formatter.stringFromDate(item.lastUpdateTime)
            println(item.taskId.description + " " + item.title + " " + timeStr)
        }
        allTasks = result!.sorted { $0.lastUpdateTime.compare($1.lastUpdateTime) == NSComparisonResult.OrderedDescending }
    }
    
    func createHeaderView() ->UIView {
        let baseView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, CGFloat(self.headerHeight())))
        baseView.backgroundColor = UIColor.whiteColor()
        headerView = TaskListHeaderView(frame: CGRectMake(0, 0, baseView.frame.size.width, 86))
        baseView.addSubview(headerView)
        
        headerView.mas_makeConstraints { make in
            make.width.equalTo()(baseView.frame.size.width)
            make.height.equalTo()(86)
            make.centerX.equalTo()(baseView.mas_centerX)
            make.centerY.equalTo()(baseView.mas_centerY)
            return ()
        }
        headerView.delegate = self
        return baseView
    }
    
    func refreshHeaderView() {
        if self.taskRunner.taskItem == nil && self.headerView.isInTimersViewSide(){
            self.headerView.flipToStartViewSide()
            return
        }
        
        if self.taskRunner.taskItem == nil {
            return
        }
        
        self.headerView.updateTime(self.getTimerMinutesStringBySeconds(self.taskRunner.seconds), seconds: self.getTimerSecondsStringBySeconds(self.taskRunner.seconds))
        if self.taskRunner.taskItem.minutes * 10 - 2 >= self.taskRunner.seconds && !self.headerView.isInTimersViewSide() {
            self.headerView.flipToTimerViewSide()
        }
    }
    
    func insertItem(val: NSTimer) {
        println("\(val.userInfo)")
        let item = val.userInfo as Task
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
        let copyItem = val.userInfo as Task
        var baseItem = allTasks.filter{ $0.taskId == copyItem.taskId }.first!
        if find(allTasks, baseItem) == 0 { // if this item is already in the top, then return
            baseItem.title = copyItem.title
            self.tableView.reloadData()
            return
        }
        self.deleteItem(baseItem, withRowAnimation: UITableViewRowAnimation.Left)
        self.insertItem(baseItem, withRowAnimation: UITableViewRowAnimation.Left)
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
    
    func recordWork(isFinished: Bool) {
        let work = Work()
        work.taskId = self.taskRunner!.taskItem.taskId
        work.isFinished = isFinished
        DBOperate.insertWork(work)
    }
    
    func getTimerMinutesStringBySeconds(seconds: Int) -> String {
        return String(format: "%02d", seconds % 3600 / 60)
    }
    
    func getTimerSecondsStringBySeconds(seconds: Int) -> String {
        return String(format: "%02d", seconds % 3600 % 60)
    }
}