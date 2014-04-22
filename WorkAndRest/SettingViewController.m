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
    self.switchControl.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondSound"] boolValue];
    self.lightSwitchControl.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepLight"] boolValue];
    NSNumber *secondsNumber = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"Seconds"];
    secondsValue = [secondsNumber intValue];
    self.dateLabel.text = [NSString stringWithFormat:@"00:%02d:00", secondsValue];
    self.slider.value = secondsValue;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segguestionsTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.suggestionsLabel addGestureRecognizer:tapGestureRecognizer];
    self.suggestionsLabel.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)segguestionsTapped
{
    NSLog(@"Send email.");
    NSString *urlEmail = [NSString stringWithFormat:@"mailto:workrest@outlook.com?subject=%@", NSLocalizedString(@"Suggestions", nil)];
    NSString *url = [urlEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end
