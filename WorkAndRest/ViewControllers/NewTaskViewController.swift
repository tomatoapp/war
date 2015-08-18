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

class NewTaskViewController: BaseViewController, UITextFieldDelegate  {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var startButton: UIButton!
    
    var taskItem: Task?
    var delegate: NewTaskViewControllerDelegate?
    var minutes = GlobalConstants.DEFAULT_MINUTES
    var startView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapRecognizer)
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
    
    // MARK: - Methods
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
}











