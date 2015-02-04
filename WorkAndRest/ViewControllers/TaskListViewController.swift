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

class TaskListViewController: UITableViewController,ItemDetailViewControllerDelegate, NewTaskViewControllerDelegate, TaskListItemCellDelegate, TaskRunnerManagerDelegate {

    var allTasks = [Task]()
    //var runningTask: Task?
    var runningTaskRunner: TaskRunner?
    var handleType = HandleType.None
    var taskRunnerManager: TaskRunnerManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "TaskListItemCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        self.tableView.tableHeaderView = self.createHeaderView()
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
        
        self.loadAllTasks()
        self.tableView.reloadData()
        
        let line = UIImageView(image: UIImage(named: "line"))
        line.frame = CGRectMake(19.5, 140, 1, self.tableView.frame.size.height-140)
        //self.tableView.addSubview(line)
        self.view.insertSubview(line, atIndex: 0)
        
        self.taskRunnerManager = TaskRunnerManager()
        self.taskRunnerManager!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        
//        if runningTask == nil {
        if runningTaskRunner == nil {
            cell.reset()
        } else {
            println("runningTask: \(self.runningTaskRunner!.taskItem.taskId) + \(self.runningTaskRunner!.taskItem.title)")
            println("task: \(task.taskId) + \(task.title)")
            if task.taskId == self.runningTaskRunner!.taskItem.taskId {
                cell.start()
            } else {
                cell.disable()
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = allTasks[indexPath.row]
        let copyItem = item.copy() as Task
        //self.performSegueWithIdentifier("ShowItem", sender: copyItem)
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
//        if runningTask == nil  {
        if self.runningTaskRunner == nil  {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("identifier = \(segue.identifier)")
        
        if segue.identifier == "EditItem" {
            let controller = segue.destinationViewController as ItemDetailViewController
            controller.copyTaskItem = sender as Task?
            controller.delegate = self
        } else if segue.identifier == "ShowItem" {
            let controller = segue.destinationViewController as WorkWithItemViewController
            controller.taskItem = sender as Task?
        } else if segue.identifier == "NewTaskSegue" {
            let controller = segue.destinationViewController as NewTaskViewController
            controller.delegate = self
        }
    }
    
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishAddingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
        
    }
    
   
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!) {
        handleType = HandleType.AddOrEdit
        item.lastUpdateTime = NSDate()
        DBOperate.updateTask(item)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: item, repeats: false)
    }
    
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!) {
        println("Clicked the cancel button.")
    }
    
    // MARK: - NewTaskViewControllerDelegate
    
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!, runningNow runNow: Bool) {
        
        if DBOperate.insertTask(item) {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
            if runNow {
//                self.runningTask = item
                self.runningTaskRunner = TaskRunner(task: item)
            }
        }
    }
    
    // MARK: - TaskListItemCellDelegate
    
    func started(sender: TaskListItemCell!) {
//        if self.runningTask != nil { // some task is running, can not start another task!
//            return
//        }

        if self.runningTaskRunner != nil {
            return
        }
        self.handleType = HandleType.Start
        sender.taskItem?.lastUpdateTime = NSDate()
//        self.runningTask = sender.taskItem
        self.runningTaskRunner = sender.taskRunner
        DBOperate.updateTask(sender.taskItem!)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItemToTop:"), userInfo: sender.taskItem, repeats: false)
    }
    
    func completed(sender: TaskListItemCell!) {
//        self.runningTask = nil
        self.runningTaskRunner = nil
        self.reloadTableViewWithTimeInterval(0.5)
    }
    
    func breaked(sender: TaskListItemCell!) {
        
    }
    
    // MARK: - TaskRunnerManagerDelegate
    
    func taskRunnerMangerWillFreezeTask(taskManager: TaskRunnerManager!) -> TaskRunner {
        return self.runningTaskRunner!
    }
    
    func taskRunnerManger(taskRunnerManager: TaskRunnerManager!, didActiveFrozenTaskRunner taskRunner: TaskRunner!) {
//        self.runningTask = task
        self.runningTaskRunner = taskRunner
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
        let baseView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 150))
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 140))
        headerView.backgroundColor = UIColor.whiteColor()
        let button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.adjustsImageWhenHighlighted = false
        button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "start_button"), forState: .Normal)
        button.setImage(UIImage(named: "start_button_pressed"), forState: .Selected)
        button.setImage(UIImage(named: "start_button_pressed"), forState: .Highlighted)
        button.addTarget(self, action: Selector("newTaskButtonClick:"), forControlEvents: .TouchUpInside)
        
        headerView.addSubview(button)
        baseView.addSubview(headerView)
        button.mas_makeConstraints { make in
            make.width.equalTo()(240)
            make.height.equalTo()(74)
            make.centerX.equalTo()(headerView.mas_centerX)
            make.centerY.equalTo()(headerView.mas_centerY)
            return ()
        }
        return baseView
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
        self.performSegueWithIdentifier("NewTaskSegue", sender: nil)
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
}