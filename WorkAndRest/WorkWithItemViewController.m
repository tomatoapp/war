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
    NSNumber *secondsValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"Seconds"];
    seconds = [secondsValue intValue] * 60;
    seconds = 15;
    NSLog(@"Get Seconds: %d", seconds);
    
    isPlaySecondSound = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondSound"] boolValue];
    isKeepScreenLight = [[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepLight"] boolValue];
    
    secondBeep = [self setupAudioPlayerWithFile:@"SecondBeep" type:@"wav"];

    self.title = self.itemToWork.text;
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
    self.workTimesLabel.text = [NSString stringWithFormat:@"Work Times: %@", self.itemToWork.costWorkTimes];

    [self enableButton:self.startButton];
    [self disableButton:self.stopButton];
    [self disableButton:self.silentButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.startButton.layer.cornerRadius = 30;
    self.startButton.layer.borderWidth = 1;
    
    self.stopButton.layer.cornerRadius = 30;
    self.stopButton.layer.borderWidth = 1;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentModelViewController = self;
    

}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stop];
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
    NSLog(@"start");
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
    NSLog(@"stop");
    isWorking = NO;
    
    [timer invalidate];
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
    
    [self enableButton:self.startButton];
    [self disableButton:self.stopButton];
    [self disableButton:self.silentButton];
}

- (IBAction)silentButtonClick:(id)sender
{
    isPlaySecondSound = !isPlaySecondSound;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isPlaySecondSound] forKey:@"SecondSound"];
}

#pragma mark - Timer

- (void)subtractTime
{
    NSLog(@"subtractTime");
    
    if (secondsLeft > 0) {
        
        secondsLeft--;
        minute = (secondsLeft % 3600) / 60;
        second = (secondsLeft % 3600) % 60;
        
        self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
        if (isPlaySecondSound) {
            [secondBeep play];
        }
    } else {
        NSLog(@"Timeout");
        isWorking = NO;
        
        [timer invalidate];
        
        [self completedOneWorkTime];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time is up!" message:@"" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: nil];
        [alert show];
        
        [self disableButton:self.stopButton];
        [self disableButton:self.silentButton];
        [self enableButton:self.startButton];
        
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
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
    if ([button.titleLabel.text isEqualToString:@"Start"]) {
        self.startButton.layer.borderColor = [UIColor colorWithRed:0 green:180.00/255.00 blue:0 alpha:1].CGColor;
        self.startButton.titleLabel.textColor = [UIColor colorWithRed:0 green:180.00/255.00 blue:0 alpha:1];
        
    } else if ([button.titleLabel.text isEqualToString:@"Stop"]) {
        self.stopButton.layer.borderColor = [UIColor redColor].CGColor;
        self.stopButton.titleLabel.textColor = [UIColor redColor];
        
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
    
    self.workTimesLabel.text = [NSString stringWithFormat:@"Work Times: %@", self.itemToWork.costWorkTimes];
}

@end
