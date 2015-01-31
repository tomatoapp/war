//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class TaskListItemCell: UITableViewCell {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.setup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        let bgImage = UIImage(named: "list_item_normal_bg")
        let bgImageView = UIImageView(image: bgImage)
        let bgView = UIView(frame: self.frame)
        bgView.addSubview(bgImageView)
        bgImageView.mas_makeConstraints { (make) -> Void in
            
            make.width.equalTo()(bgView.frame.size.width * 0.9)
            make.height.equalTo()(55)
            make.centerX.equalTo()(bgView.mas_centerX).offset()(10)
            make.centerY.equalTo()(bgView.mas_centerY)
            return ()
        }
        
        self.backgroundView = bgView
    }
    
    func setTaskTitle(title: String!) {
        self.titleLabel.text = "\(title)"
    }

}
