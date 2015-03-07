//
//  SettingsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/16.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import MessageUI

let SubTitleSectionHeight: CGFloat = 50
class SettingsViewController: BaseTableViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, ProductsManagerDelegate {

    @IBOutlet var badgeAppIconSwitch: UISwitch!
    @IBOutlet var currentVersionButton: UIButton!
    var versionType = ApplicationStateManager.sharedInstance.versionType()
    var popTipView: CMPopTipView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.badgeAppIconSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_BADGEAPPICON)
        ProductsManager.sharedInstance.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.refreshThePaymentItem(self.versionType)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func badgeAppIconSwitchValueChanged(sender: AnyObject) {
        let isShowBadgeAppIcon = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setBool(isShowBadgeAppIcon, forKey: GlobalConstants.kBOOL_BADGEAPPICON)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func versionTypeButtonClicked(sender: AnyObject) {
        if self.versionType == .Free {
            self.showPopTipView()
        }
    }
    
    func showPopTipView() {
        if self.popTipView == nil {
            self.popTipView = CMPopTipView(message: "Tomato! is free for a 7 day trial, If you like it then you can purchase Pro version.")
        }
        self.popTipView?.dismissAnimated(false)
        self.popTipView?.presentPointingAtView(self.currentVersionButton, inView: self.view, animated: true)
    }
    
    // MARK: - Navigation

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        if section == 1 {
            return SubTitleSectionHeight
        }
        return 15
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if section != 1 {
            return nil
        }
        
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, SubTitleSectionHeight))
        view.backgroundColor = UIColor.clearColor()
        let label = UILabel(frame: CGRectMake(16, -3, view.frame.size.width - 32, SubTitleSectionHeight))
        label.numberOfLines = 2
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        label.text = "Show the incomplete task count badge on the app icon."
        label.sizeToFit()
        view.addSubview(label)
        return view
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        if indexPath.section == 1 {
//            return
//        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            self.showPopTipView()
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            // go premium
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            isInpaymentTransactionProcess = true
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                target: self,
                selector: Selector("hideHUBWhenTheAlertIsShowed"),
                userInfo: nil,
                repeats: true)
            ProductsManager.sharedInstance.purchasePro()
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            // restore purchase
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            ProductsManager.sharedInstance.restore()
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            self.showSendEmailAlert()
        }
        
        
        if indexPath.section == 2 && indexPath.row == 0 {
            // about
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            // rate
            UIApplication.sharedApplication().openURL(NSURL(string: GlobalConstants.APPSTORE_URL)!)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && self.versionType == .Pro && (indexPath.row == 1 || indexPath.row == 2) {
            return 0.0
        }
        return 44.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && self.versionType == .Pro && (indexPath.row == 1 || indexPath.row == 2) {
            cell.hidden = true
        }
        
        if indexPath.section == 1 && self.versionType == .Pro && indexPath.row == 0 {
            if cell.respondsToSelector(Selector("setLayoutMargins:")) {
                cell.layoutMargins = UIEdgeInsetsZero
            }
            if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins")) {
                cell.preservesSuperviewLayoutMargins = false
            }
            cell.separatorInset = UIEdgeInsetsZero
        }
    }
    
    // MARK: - AlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if MFMailComposeViewController.canSendMail() {
                var mailComposeViewController = MFMailComposeViewController()
                mailComposeViewController.mailComposeDelegate = self
                mailComposeViewController.setToRecipients([GlobalConstants.EMAIL_ADDRESS])
                mailComposeViewController.setSubject(NSLocalizedString("Suggestions", comment: ""))
                mailComposeViewController.setMessageBody("", isHTML: false)
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultSent.value:
            self.showThanksAlert()
            break
            
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSendEmailAlert() {
        let alert = UIAlertView(title: NSLocalizedString("Send an email to the developers?", comment: ""),
            message: NSLocalizedString("Send email message", comment: ""),
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
            otherButtonTitles: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    func showThanksAlert() {
        let alert = UIAlertView(title: "",
            message: NSLocalizedString("Thanks for your help", comment: ""),
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    // MARK: - ProductsManagerDelegate
    
    func productsManager(productsManager: ProductsManager, paymentTransactionState state: SKPaymentTransactionState) {
        switch state {
            
        case SKPaymentTransactionState.Purchasing:
            println("ProductsManagerDelegate - Purchasing")
            
            //MBProgressHUD.hideHUDForView(self.view, animated: true)
            break
            
        case SKPaymentTransactionState.Purchased:
            println("ProductsManagerDelegate - Purchased")
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            isInpaymentTransactionProcess = false
            break
            
        case SKPaymentTransactionState.Restored:
            println("ProductsManagerDelegate - Restored")
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            isInpaymentTransactionProcess = false
            break
            
        case SKPaymentTransactionState.Failed:
            println("ProductsManagerDelegate - Failed")
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            isInpaymentTransactionProcess = false
            break
            
        default:
            break
        }
        self.versionType = ApplicationStateManager.sharedInstance.versionType()
        self.tableView.reloadData()
        self.refreshThePaymentItem(self.versionType)
    }
    
    func refreshThePaymentItem(versionType: VersionType) {
        switch versionType {
        case .Free:
            self.currentVersionButton.setTitle("Free", forState: .Normal)
            break
            
        case .Pro:
            self.currentVersionButton.setTitle("Pro", forState: .Normal)
            break
        }
    }
    
    var timer: NSTimer!
    var isInpaymentTransactionProcess = false
    
//    func hideHUDWhileShowedTheAlertView() {
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
//            target: self,
//            selector: Selector("hideHUBWhenTheAlertIsShowed"),
//            userInfo: nil,
//            repeats: true)
//    }
    
    func hideHUBWhenTheAlertIsShowed() {
        println("hideHUBWhenTheAlertIsShowed")
        if !isInpaymentTransactionProcess {
            self.timer.invalidate()
        }
        for window in UIApplication.sharedApplication().windows {
            for subView in window.subviews {
                println(subView)
                
                if subView.isKindOfClass(UIAlertView) {
                    println("subView.isKindOfClass(UIAlertView) -> true")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    // Stop the timer
                    self.timer.invalidate()
                    // Start a new timer to check whether the alert is dismissed.
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                        target: self,
                        selector: Selector("showHUBWhenTheAlertIsDismissed"),
                        userInfo: nil,
                        repeats: true)
                }
            }
        }
    }
    
    func showHUBWhenTheAlertIsDismissed() {
        println("showHUBWhenTheAlertIsDismissed")
        if !isInpaymentTransactionProcess {
            self.timer.invalidate()
        }
        
        var isFindedTheAlertView = false
        for window in UIApplication.sharedApplication().windows {
            for subView in window.subviews {
                if subView.isKindOfClass(UIAlertView) {
                    isFindedTheAlertView = true
                    self.timer.invalidate()
                }
            }
        }
        if !isFindedTheAlertView {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
    }
}































