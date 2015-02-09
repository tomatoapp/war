//
//  TaskTitleViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskTitleViewControllerDelegate {
    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!)
    
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!)
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!)
}

class TaskTitleViewController: BaseTableViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    var delegate: TaskTitleViewControllerDelegate! = nil
    @IBOutlet var textField: UITextField!
    var copyTaskItem: Task!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.copyTaskItem != nil {
            self.title = NSLocalizedString("Edit Task", comment: "")
            self.textField.text = copyTaskItem!.title
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !self.textField.isFirstResponder() {
            self.textField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.textField.isFirstResponder() {
            self.textField.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Events
    
    @IBAction func cancel(sender: AnyObject?) {
        if (self.delegate != nil) {
            self.delegate.addTaskViewControllerDidCancel(self)
        }
//        self.navigationController!.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        
        if self.textField.text.isEmpty {
            self.cancel(nil)
            return
        }
        
        if copyTaskItem == nil {
            let newItem = Task()
            newItem.title = self.textField.text
            self.delegate.addTaskViewController(self, didFinishAddingTask: newItem)
        } else {
            if copyTaskItem.title == self.textField.text {
                self.cancel(nil)
                return;
            }
            copyTaskItem!.title = self.textField.text
            self.delegate.addTaskViewController(self, didFinishEditingTask: copyTaskItem)
        }
//        self.navigationController!.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 24.0
        }
        return 14.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.done(textField)
        return true
    }

}
