//
//  WorkWithItemViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "WorkWithItemViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface WorkWithItemViewController ()

@end

@implementation WorkWithItemViewController {
    NSFetchedResultsController *fetchedResultsController;
    NSTimer *timer;
    // int secondsLeft;
    int minute, second;
    int seconds;
    AVAudioPlayer *secondBeep;
    BOOL isPlaySecondSound;
    BOOL isKeepScreenLight;
}

@synthesize itemToWork;
@synthesize isWorking;
@synthesize secondsLeft;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Status

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.translucent = YES;
    
    seconds = [[[NSUserDefaults standardUserDefaults] valueForKey:@"Seconds"] intValue] * 60;
    // seconds = seconds / 60;
    isPlaySecondSound = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondSound"] boolValue];
    isKeepScreenLight = [[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepLight"] boolValue];
    
    secondBeep = [self setupAudioPlayerWithFile:@"sec" type:@"wav"];
    
    self.title = self.itemToWork.text;
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
    self.workTimesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"work times: %@", nil), self.itemToWork.costWorkTimes];

    [self enableButton:self.startButton];
    [self disableButton:self.stopButton];
    [self disableButton:self.silentButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.startButton.layer.cornerRadius = 38;
    self.startButton.layer.borderWidth = 1.5;
    
    self.stopButton.layer.cornerRadius = 38;
    self.stopButton.layer.borderWidth = 1.5;
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.currentModelViewController = self;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:@"Tasks"];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions

- (IBAction)start
{
    isWorking = YES;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(subtractTime) userInfo:nil repeats:YES];
    
    self.itemToWork.completed = [NSNumber numberWithBool:NO];
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }

    [self enableButton:self.stopButton];
    [self enableButton:self.silentButton];
    [self disableButton:self.startButton];
    
    if (isKeepScreenLight) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

- (IBAction)stop
{
    [self showStopAlertView];
}

- (IBAction)silentButtonClick:(id)sender
{
    isPlaySecondSound = !isPlaySecondSound;
    if (isPlaySecondSound) {
        [self.silentButton setTitleColor:[UIColor colorWithRed:0 green:200.00/255.00 blue:0 alpha:1] forState:UIControlStateNormal];
        
    } else {
        [self.silentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isPlaySecondSound] forKey:@"SecondSound"];
}

#pragma mark - Timer

- (void)subtractTime
{
    
    if (secondsLeft > 0) {
        
        secondsLeft--;
        minute = (secondsLeft % 3600) / 60;
        second = (secondsLeft % 3600) % 60;
        
        self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
        if (isPlaySecondSound) {
            [secondBeep play];
        }
    } else {
        isWorking = NO;
        
        [self cancelTimer];
        
        [self completedOneWorkTime];
        
        //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1005);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Completed", nil) message:NSLocalizedString(@"Time is up!", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles: nil];
        [alert show];
        
        [self disableButton:self.stopButton];
        [self disableButton:self.silentButton];
        [self enableButton:self.startButton];
        
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"Completed", nil)]) {
        [self resetTimerLabel];
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"Break this work?", nil)]) {
        if (buttonIndex == 1) {
            isWorking = NO;
            
            [self cancelTimer];
            [self resetTimerLabel];
            
            [self enableButton:self.startButton];
            [self disableButton:self.stopButton];
            [self disableButton:self.silentButton];
        }
    }
}

- (void)showStopAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Break this work?", nil) message:NSLocalizedString(@"It will be ineffective", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alert show];
}

#pragma mark - Private Methods

- (AVAudioPlayer *)setupAudioPlayerWithFile:(NSString *)file type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle]pathForResource:file ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!audioPlayer) {
        NSLog(@"%@", [error description]);
    }
    return audioPlayer;
}

- (NSString *)stringFromSecondsLeft:(int) theSecondsLeft
{
    minute = (theSecondsLeft % 3600) / 60;
    second = (theSecondsLeft % 3600) % 60;
    
    return [NSString stringWithFormat:@"00:%02d:%02d", minute, second];
}

- (void)disableButton:(UIButton *)button
{
    button.enabled = NO;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

- (void)enableButton:(UIButton *)button
{
    button.enabled = YES;
    if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"Start", nil)]) {
        self.startButton.layer.borderColor = [UIColor colorWithRed:0 green:200.00/255.00 blue:0 alpha:1].CGColor;
        self.startButton.titleLabel.textColor = [UIColor colorWithRed:0 green:200.00/255.00 blue:0 alpha:1];
        [self.startButton setTitleColor:[UIColor colorWithRed:0 green:200.00/255.00 blue:0 alpha:1] forState:UIControlStateNormal];
        
    } else if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"Stop", nil)]) {
        self.stopButton.layer.borderColor = [UIColor redColor].CGColor;
        self.stopButton.titleLabel.textColor = [UIColor redColor];
        [self.stopButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    } else {
        if (isPlaySecondSound) {
            [self.silentButton setTitleColor:[UIColor colorWithRed:0 green:200.00/255.00 blue:0 alpha:1] forState:UIControlStateNormal];
            
        } else {
            [self.silentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

- (void)completedOneWorkTime
{
    self.itemToWork.costWorkTimes = [NSNumber numberWithInt:[self.itemToWork.costWorkTimes intValue] + 1];
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    self.workTimesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"work times: %@", nil), self.itemToWork.costWorkTimes];
}

- (void)cancelTimer
{
    [timer invalidate];
}

- (void)resetTimerLabel
{
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
}

- (void)reset
{
    [self cancelTimer];
    [self resetTimerLabel];
    isWorking = NO;
    
    [self enableButton:self.startButton];
    [self disableButton:self.stopButton];
    [self disableButton:self.silentButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isWorking) {
        [self cancelTimer];
    }
}

@end
