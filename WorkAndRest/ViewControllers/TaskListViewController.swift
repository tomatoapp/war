//
//  TaskListViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/29.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController, ItemDetailViewControllerDelegate {

    var allTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = self.createHeaderView()
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
        
        self.loadAllTasks()
        self.tableView.reloadData()
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
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as CustomCell
        let task = allTasks[indexPath.row]
        cell.titleLabel.text = task.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("EditItem", sender: allTasks[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = allTasks[indexPath.row]
            DBOperate.deleteTask(task)
            let indexPaths = [indexPath]
            self.deleteItem(task, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    // MARK: - Private Methods
    func loadAllTasks() {
        var result = DBOperate.loadAllTasks()
        allTasks = result!.sorted { $0.taskId < $1.taskId }
    }
    
    func createHeaderView() ->UIView {
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 130))
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
        button.mas_makeConstraints { make in
            make.width.equalTo()(240)
            make.height.equalTo()(74)
            make.centerX.equalTo()(headerView.mas_centerX)
            make.centerY.equalTo()(headerView.mas_centerY)
            return ()
        }
        return headerView
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("identifier = \(segue.identifier)")
        
        if segue.identifier == "EditItem" {
            let navigationController: UINavigationController = segue.destinationViewController as UINavigationController
            let controller: ItemDetailViewController = navigationController.topViewController as ItemDetailViewController
            controller.itemToEdit = sender as Task?
            controller.delegate = self
        } else if segue.identifier == "ShowItem" {
            println("UNDONE!!!!")
        }
    }
    
    
    // MARK: - ItemDetailViewControllerDelegate
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishAddingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("insertItem:"), userInfo: item, repeats: false)
        DBOperate.insertTask(item)
    }
    
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("moveItem:"), userInfo: item, repeats: false)
        DBOperate.updateTask(item)
    }
    
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!) {
        println("Clicked the cancel button.")
    }
    
    // MARK: - Private Methods
    
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
    
    func moveItem(val: NSTimer) {
        let item = val.userInfo as Task
        self.deleteItem(item, withRowAnimation: UITableViewRowAnimation.Left)
        self.insertItem(item, withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func newTaskButtonClick(sender: UIButton) {
        self.performSegueWithIdentifier("EditItem", sender: nil)
    }
}