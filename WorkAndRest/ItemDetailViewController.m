//
//  NewTaskViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "Task.h"

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
        Task *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        newItem.text = textField.text;
        newItem.costWorkTimes = [NSNumber numberWithInt:0];
        newItem.completed = [NSNumber numberWithBool:NO];
        newItem.date = [NSDate date];
        [self.delegate addTaskViewController:self didFinishAddingTask:newItem];
    } else {
        self.itemToEdit.text = textField.text;
        [self.delegate addTaskViewController:self didFinishEditingTask:itemToEdit];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1.0f;
    }
    return 32.0f;
}

@end
