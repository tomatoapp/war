//
//  SettingViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: BaseTableViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var lightswitchControl: UISwitch!
    @IBOutlet var dataLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var suggestionsLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    
    var  secondsValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.switchControl.on = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.kBOOL_SECOND_SOUND)!.boolValue
        self.lightswitchControl.on = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.kBOOL_KEEP_LIGHT)!.boolValue
        secondsValue = Int(NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.intValue)
        self.dataLabel.text = String(format: "00:%02d:00", secondsValue)
        self.slider.value = Float(secondsValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - AlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if MFMailComposeViewController.canSendMail() {
                var mailComposeViewController = MFMailComposeViewController()
                mailComposeViewController.mailComposeDelegate = self
                mailComposeViewController.setToRecipients(["work-rest@outlook.com"])
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
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 24.0
        }
        return 14.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 { //suggestions
            self.showSendEmailAlert()
        } else if indexPath.section == 1 && indexPath.row == 1 { //rate
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id868078759")!)
        }
    }
    
    // MARK: - Private Methods
    
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
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        self.secondsValue = Int((sender as UISlider).value)
        self.dataLabel.text = String(format: "00:%02d:00", self.secondsValue)
        NSUserDefaults.standardUserDefaults().setValue(self.secondsValue, forKey: GlobalConstants.k_SECONDS)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func secondSoundSwitchChanged(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(Int(self.switchControl.on), forKey: GlobalConstants.kBOOL_SECOND_SOUND)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func keepScreenLightSwitchChanged(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(Int(self.lightswitchControl.on), forKey: GlobalConstants.kBOOL_KEEP_LIGHT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
