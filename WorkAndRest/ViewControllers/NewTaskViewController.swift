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
    func newTaskViewController(controller: NewTaskViewController!, didFinishAddingTask item: Task!)
}

class NewTaskViewController: BaseViewController, UITextFieldDelegate, CMPopTipViewDelegate  {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var startButton: UIButton!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    var startView: UIView?
    
    var popTipView: CMPopTipView?
    
    @IBOutlet weak var titleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.delegate = self
        self.titleTextField.placeholder = NSLocalizedString("edit_task_title", comment: "")
        self.titleTextField.text = NSLocalizedString("Task", comment: "")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_HAS_SHOW_EDIT_TITLE_GUIDE) {
            self.showPopTipView()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_HAS_SHOW_EDIT_TITLE_GUIDE)
        }
    }
    
    // MARK: - Events
    
    @IBAction func cancleButtonClicked(sender: AnyObject) {
        self.hideKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startButtonClick(sender: AnyObject) {
        self.taskItem = Task()
        if self.titleTextField.text != nil && !self.titleTextField.text!.isEmpty {
            self.taskItem?.title = self.titleTextField.text!
        } else {
            self.taskItem?.title = NSLocalizedString("Task", comment: "")
        }
        self.taskItem!.minutes = self.minutes
        self.delegate?.newTaskViewController(self, didFinishAddingTask: self.taskItem)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text!).characters.count > GlobalConstants.TITLE_MAXLENGTH {
            return false
        }
        return true
    }
    
    // MARK: - CMPopTipViewDelegate
    
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        self.titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Methods
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showPopTipView() {
        if self.popTipView == nil {
            self.popTipView = CMPopTipView(message: NSLocalizedString("Tap here to edit title", comment: ""))
        }
        self.popTipView?.backgroundColor = UIColor(red: 57/255, green: 187/255, blue: 79/255, alpha: 1.0)
        self.popTipView?.textColor = UIColor.whiteColor()
        self.popTipView?.borderWidth = 0
        self.popTipView?.dismissTapAnywhere = true
        self.popTipView?.hasShadow = false
        self.popTipView?.hasGradientBackground = false
        self.popTipView?.presentPointingAtView(self.titleTextField, inView: self.view, animated: true)
        self.popTipView?.delegate = self
    }
}
