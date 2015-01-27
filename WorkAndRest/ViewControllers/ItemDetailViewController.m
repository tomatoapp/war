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
        self.title = NSLocalizedString(@"Edit Task", nil);
        textField.text = itemToEdit.title;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addTaskViewControllerDidCancel:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self.view endEditing:YES];

    if (itemToEdit == nil) {
        Task *newItem = [Task new];
        newItem.title = textField.text;
        newItem.costWorkTimes = [NSNumber numberWithInt:0];
        newItem.completed = [NSNumber numberWithBool:NO];
        newItem.date = [NSDate date];
        [self.delegate addTaskViewController:self didFinishAddingTask:newItem];
    } else {
        self.itemToEdit.title = textField.text;
        [self.delegate addTaskViewController:self didFinishEditingTask:itemToEdit];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 24.0f;
    }
    return 14.0f;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [self done:theTextField];
    return YES;
}
@end
