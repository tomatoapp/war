//
//  HelpViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/15.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class HelpViewController: BaseTableViewController {


    var TOP_MARGIN: CGFloat = 10.0
    var BOTTOM_MARGIN: CGFloat = 10.0
    var LEFT_MARGIN: CGFloat = 15.0
    var RIGHT_MARGIN: CGFloat = 15.0
    
    var SCREEN_WIDTH: CGFloat = 0.0
    var SCREEN_HEIGHT: CGFloat = 0.0
    
    var TABLEVIEW_HEADER_HEIGHT: CGFloat = 85.0
    var TABLEVIEW_FOOTER_HEIGHT: CGFloat = 0.0
    
    var FIRST_SECTION_HEADER_HEIGHT: CGFloat = 0
    var SECOND_SECTION_HEADER_HEIGHT: CGFloat = 30
    
    var CELL_HEIGHT: CGFloat = 0 //44.0
    var ABOUT_TEXT_CELL_HEIGHT: CGFloat = 0.0
    var aboutCellHeight = 0
    var aboutView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SCREEN_WIDTH = self.view.frame.size.width
        SCREEN_HEIGHT = self.view.frame.size.height
        self.aboutView = self.createAboutView()
        ABOUT_TEXT_CELL_HEIGHT = self.aboutView!.frame.size.height
        
        TABLEVIEW_FOOTER_HEIGHT =
            SCREEN_HEIGHT
            - TABLEVIEW_HEADER_HEIGHT
            - FIRST_SECTION_HEADER_HEIGHT
            - CELL_HEIGHT
            - SECOND_SECTION_HEADER_HEIGHT
            - ABOUT_TEXT_CELL_HEIGHT
            - self.navigationController!.navigationBar.frame.height
            - UIApplication.sharedApplication().statusBarFrame.size.height
        
        if WARDevice.getPhoneType() == PhoneType.iPhone4 {
            self.tableView.scrollEnabled = true
            TABLEVIEW_FOOTER_HEIGHT = 150
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableHeaderView = self.creatHeaderView()
        self.tableView.tableFooterView = self.createFooterView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECOND_SECTION_HEADER_HEIGHT
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return ABOUT_TEXT_CELL_HEIGHT
        }
        return CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.addSubview(self.aboutView!)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 {
//            let label = UILabel(frame: CGRectMake(10, 7, 200, 20))
//            label.text  = "ABOUT"
//            label.textColor = UIColor.grayColor()
//            label.font = UIFont.systemFontOfSize(13)
//            view.addSubview(label)
            view.tintColor = UIColor.whiteColor()
        }
    }
    
    func creatHeaderView() -> UIView {
        let view = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, TABLEVIEW_HEADER_HEIGHT))
        view.backgroundColor = UIColor.whiteColor()
        let iconImageView = UIImageView(image: UIImage(named: "new_task_icon"))
//        iconImageView.contentMode = UIViewContentMode.Center
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
        iconImageView.frame = CGRectMake(0, 0, 70, 70)
        iconImageView.center = view.center
        
        view.addSubview(iconImageView)
        return view
    }

    func createFooterView() -> UIView {
        
        let label = UILabel(frame: CGRectMake(LEFT_MARGIN, TOP_MARGIN, SCREEN_WIDTH - LEFT_MARGIN - RIGHT_MARGIN, 0))
        label.textColor = UIColor.lightGrayColor() // UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFontOfSize(13)
        label.text = "Pomodoro™ and The Pomodoro Technique™ are trademarks of Francesco Cirillo. This application is not affiliated or associated with or endorsed by Pomodoro™, The Pomodoro Technique™ or Francesco Cirillo."
        label.numberOfLines = 0
        label.sizeToFit()
        var expectedSize = label.frame
        expectedSize.origin.y = (TABLEVIEW_FOOTER_HEIGHT - label.frame.height) / 2
        label.frame = expectedSize
        label.textAlignment = NSTextAlignment.Center
        
        let view = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, TABLEVIEW_FOOTER_HEIGHT))
        view.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)

        view.addSubview(label)
        return view
    }

    func createAboutView() -> UIView {
        
        let aboutTextLabel = UILabel(frame: CGRectMake(LEFT_MARGIN, TOP_MARGIN, SCREEN_WIDTH - LEFT_MARGIN - RIGHT_MARGIN, 0))
        let text = "Tomato! is based on the Pomodoro Technique, and is perfected by the Lunars team. Tomato! is an elegant and clean app, and this is probably the best Pomodoro clock you will see or have seen."
        aboutTextLabel.text = text
        aboutTextLabel.numberOfLines = 0
        aboutTextLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        aboutTextLabel.sizeToFit()
        aboutTextLabel.textAlignment = NSTextAlignment.Center
        aboutTextLabel.font = UIFont.systemFontOfSize(15)
        
        let creditsLabel = UILabel(frame: CGRectMake(LEFT_MARGIN, aboutTextLabel.frame.size.height + 20, SCREEN_WIDTH, 0))
        creditsLabel.text = "Credits"
        creditsLabel.font = UIFont.boldSystemFontOfSize(16)
        creditsLabel.numberOfLines = 0
        creditsLabel.sizeToFit()
        
        let coderLabel = UILabel(frame: CGRectMake(LEFT_MARGIN, creditsLabel.frame.origin.y + creditsLabel.frame.size.height,
            SCREEN_WIDTH / 2, 0))
        coderLabel.text = "Software Engineering"
        coderLabel.font = UIFont.systemFontOfSize(15)
        creditsLabel.numberOfLines = 0
        coderLabel.sizeToFit()
        
        let coderNameLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        coderNameLabel.text = "Carl Yang"
        coderNameLabel.numberOfLines = 0
        coderNameLabel.font = UIFont.boldSystemFontOfSize(15)
        coderNameLabel.sizeToFit()
        coderNameLabel.frame = CGRectMake(SCREEN_WIDTH - LEFT_MARGIN - coderNameLabel.frame.size.width, creditsLabel.frame.origin.y + creditsLabel.frame.size.height, coderNameLabel.frame.size.width, coderNameLabel.frame.size.height)
        
        let designerLabel = UILabel(frame: CGRectMake(LEFT_MARGIN, coderLabel.frame.origin.y + coderLabel.frame.size.height,
            SCREEN_WIDTH / 2, 100))
        designerLabel.text = "Design"
        designerLabel.font = UIFont.systemFontOfSize(15)
        designerLabel.sizeToFit()
        
        let designerNameLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        designerNameLabel.text = "Marc Liu"
        designerNameLabel.numberOfLines = 0
        designerNameLabel.font = UIFont.boldSystemFontOfSize(15)
        designerNameLabel.sizeToFit()
        designerNameLabel.frame = CGRectMake(SCREEN_WIDTH - LEFT_MARGIN - designerNameLabel.frame.size.width, coderLabel.frame.origin.y + coderLabel.frame.size.height, designerNameLabel.frame.size.width, designerNameLabel.frame.size.height)
        
        let view = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, designerLabel.frame.origin.y + designerLabel.frame.size.height + BOTTOM_MARGIN + 8 + SECOND_SECTION_HEADER_HEIGHT))
        view.addSubview(aboutTextLabel)
        view.addSubview(creditsLabel)
        view.addSubview(coderLabel)
        view.addSubview(coderNameLabel)
        view.addSubview(designerLabel)
        view.addSubview(designerNameLabel)
        
        return view
    }
    
}
