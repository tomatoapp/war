//
//  WorkWithItemViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface WorkWithItemViewController : UIViewController<UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Task *itemToWork;

@property (nonatomic, strong) IBOutlet UILabel *timerLabel;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UILabel *workTimesLabel;
@property (nonatomic, strong) IBOutlet UIButton *silentButton;

- (IBAction)start;
- (IBAction)stop;

@end
