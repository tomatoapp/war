//
//  SettingViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController {
    int secondsValue;
}

@synthesize dateLabel, switchControl;

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
    self.title = @"Setting";
    self.switchControl.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondSound"] boolValue];
    self.lightSwitchControl.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepLight"] boolValue];
    NSNumber *secondsNumber = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"Seconds"];
    secondsValue = [secondsNumber intValue];
    self.dateLabel.text = [NSString stringWithFormat:@"00:%02d:00", secondsValue];
    self.slider.value = secondsValue;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            return 0.1f;
        }
        return 10.0f;
    }
    return 32.0f;
}

- (IBAction)secondSoundSwitchChanged:(id)sender
{
    NSLog(@"self.switchControl.on %hhd",self.switchControl.on);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.switchControl.on] forKey:@"SecondSound"];
}

- (IBAction)keepScreenLightSwitchChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.lightSwitchControl.on] forKey:@"KeepLight"];
}

- (IBAction)sliderValueChanged:(id)sender
{
    secondsValue = ((UISlider *)sender).value;
    self.dateLabel.text = [NSString stringWithFormat:@"00:%02d:00", secondsValue];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:secondsValue] forKey:@"Seconds"];
}

@end
