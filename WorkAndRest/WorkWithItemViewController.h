//
//  WorkWithItemViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskItem.h"

@interface WorkWithItemViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, strong) TaskItem *itemToWork;

@property (nonatomic, strong) IBOutlet UILabel *timerLabel;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;

- (IBAction)start;
- (IBAction)stop;

@end
