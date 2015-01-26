//
//  NewTaskViewController.h
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskItem.h"

@class ItemDetailViewController;
@class Task;

@protocol ItemDetailViewControllerDelegate <NSObject>

- (void)addTaskViewControllerDidCancel:(ItemDetailViewController *)controller;
- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(Task *)item;
- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(Task *)item;

@end

@interface ItemDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <ItemDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) Task *itemToEdit;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
