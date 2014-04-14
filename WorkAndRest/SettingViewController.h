//
//  SettingViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"

@interface SettingViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UISwitch *switchControl;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@end
