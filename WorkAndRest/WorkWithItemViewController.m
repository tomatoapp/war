//
//  WorkWithItemViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-4-10.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "WorkWithItemViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WorkWithItemViewController ()

@end

@implementation WorkWithItemViewController {
    NSFetchedResultsController *fetchedResultsController;
    NSTimer *timer;
    int secondsLeft;
    int minute, second;
    int seconds;
    //AVAudioPlayer *secondBeep;
}

@synthesize itemToWork;

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
    NSNumber *secondsValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"Seconds"];
    seconds = [secondsValue intValue] * 60;
    NSLog(@"Get Seconds: %d", seconds);
    self.stopButton.enabled = NO;
    //secondBeep = [self setupAudioPlayerWithFile:@"SecondBeep" type:@"wav"];

    self.title = self.itemToWork.text;
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
}

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
- (IBAction)start
{
    NSLog(@"start");
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(subtractTime) userInfo:nil repeats:YES];
    
}

- (void)subtractTime
{
    NSLog(@"subtractTime");
    
    if (secondsLeft > 0) {
        
        secondsLeft--;
        minute = (secondsLeft % 3600) / 60;
        second = (secondsLeft % 3600) % 60;
        
        self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
        //[secondBeep play];
    } else {
        NSLog(@"Timeout");
        [timer invalidate];
        self.startButton.enabled = YES;
        self.stopButton.enabled = NO;
        secondsLeft = seconds;
        self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
        self.itemToWork.costWorkTimes = [NSNumber numberWithInt:[self.itemToWork.costWorkTimes intValue] + 1];
        self.itemToWork.completed = NO;
        
        NSError *error;
        if(![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time is up!" message:@"" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: nil];
        [alert show];
        
    }
}

- (NSString *)stringFromSecondsLeft:(int) theSecondsLeft
{
    minute = (theSecondsLeft % 3600) / 60;
    second = (theSecondsLeft % 3600) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

- (IBAction)stop
{
    NSLog(@"stop");
    [timer invalidate];
    secondsLeft = seconds;
    self.timerLabel.text = [self stringFromSecondsLeft:secondsLeft];
    self.stopButton.enabled = NO;
    self.startButton.enabled = YES;
}

@end
