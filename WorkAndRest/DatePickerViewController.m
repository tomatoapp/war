//
//  DatePickerViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-4-14.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

@synthesize tableView, datePicker, delegate, date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.datePicker setDate:self.date animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel
{
    [self.delegate datePickerDidCancel:self];
}

- (IBAction)done
{
    [self.delegate datePicker:self didPickDate:self.date];
     NSLog(@"date: %@", self.date);
}

- (IBAction)dateChanged
{
    self.date = [self.datePicker date];
    NSLog(@"dateChanged date: %@", self.date);
}

@end
