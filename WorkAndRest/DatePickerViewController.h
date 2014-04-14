//
//  DatePickerViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-4-14.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerViewController;

@protocol DatePickerViewControllerDelegate <NSObject>

- (void)datePickerDidCancel:(DatePickerViewController *)datePicker;
- (void)datePicker:(DatePickerViewController *)datePicker didPickDate:(NSDate *)date;

@end

@interface DatePickerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) id <DatePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *date;

- (IBAction)cancel;
- (IBAction)done;
- (IBAction)dateChanged;

@end
