//
//  NewTaskViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "TaskItem.h"
// #import "Task.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

@synthesize delegate;
@synthesize textField;
@synthesize itemToEdit;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.itemToEdit != nil) {
        self.title = @"Edit Task";
        textField.text = itemToEdit.text;
    }
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addTaskViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if (itemToEdit == nil) {
        TaskItem *item = [[TaskItem alloc] init];
        item.text = textField.text;
        item.costWorkTimes = 0;
        item.completed = NO;
        [self.delegate addTaskViewController:self didFinishAddingTask:item];
    } else {
        self.itemToEdit.text = textField.text;
        [self.delegate addTaskViewController:self didFinishEditingTask:itemToEdit];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1f;
    }
    return 32.0f;
}

@end
