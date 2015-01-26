//
//  WorkAndRestViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-4.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "TaskListViewController.h"
#import "ItemDetailViewController.h"
#import "Task.h"
#import "Checkbox.h"
#import "CustomCell.h"
#import "WorkWithItemViewController.h"
#import "DBOperate.h"

@interface TaskListViewController ()

@end

@implementation TaskListViewController  {
    NSMutableArray *allTasks;
}

@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self firstRun];
    [self loadAllTasks];
}

// 首次运行程序
- (void)firstRun
{
    BOOL hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRun"];
    
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRun"];
        
        // Add the "Task Sample" item to the list.
        Task *sampleTask = [Task new];
        sampleTask.taskId = -1000;
        sampleTask.title = NSLocalizedString(@"Task Sample", nil);
        sampleTask.costWorkTimes = [NSNumber numberWithInteger:0];
        sampleTask.completed = [NSNumber numberWithBool:NO];
        sampleTask.date = [NSDate date];
        [DBOperate insertTask:sampleTask];
        
        // Set the default Second Sound to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SecondSound"];
        
        // Set the default Keep Screen Light to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"KeepLight"];
        
        // Set the Default Seconds.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:25] forKey:@"Seconds"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:NO animated:YES];
//    [self showToolBarItems];
    [self.tableView reloadData];
}

//- (void)showToolBarItems
//{
//    UIBarButtonItem *mainButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory)];
//    
//    UIBarButtonItem *statisticsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Statistics" style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory)];
//    
////    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
////    spacer.width = 85.0f;
//    
//    self.toolbarItems = [NSArray arrayWithObjects:mainButtonItem, statisticsButtonItem, nil];
//}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: identifier = %@", segue.identifier);
    
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.itemToEdit = sender;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowItem"]) {
        WorkWithItemViewController *controller = segue.destinationViewController;
        controller.itemToWork = sender;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}

#pragma mark - NewTaskViewControllerDelegate

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(Task *)item
{
    [DBOperate insertTask:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(Task *)item
{
    [DBOperate updateTask:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTaskViewControllerDidCancel:(ItemDetailViewController *)controller
{
    NSLog(@"Click the Cancel Button");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allTasks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    Task *item = [allTasks objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.title;
    cell.subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"work times: %@", nil),item.costWorkTimes];
    cell.checkBox.checked = [item.completed boolValue];
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Task *item = [allTasks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [allTasks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowItem" sender:task];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [allTasks objectAtIndex:indexPath.row];
        [DBOperate deleteTask:task];
    }
}

- (IBAction)checkBoxTapped:(id)sender forEvent:(UIEvent*)event
{
    NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    // Lookup the index path of the cell whose checkbox was modified.
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    
	if (indexPath != nil)
	{
		// Update our data source array with the new checked state.
        Task *task = [allTasks objectAtIndex:indexPath.row];
        task.completed = @([(Checkbox*)sender isChecked]);
        [DBOperate updateTask:task];
	}
    // Accessibility
    [self updateAccessibilityForCell:(CustomCell*)[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)updateAccessibilityForCell:(CustomCell*)cell
{
    // The cell's accessibilityValue is the Checkbox's accessibilityValue.
    cell.accessibilityValue = cell.checkBox.accessibilityValue;
    cell.checkBox.accessibilityLabel = cell.titleLabel.text;
}

#pragma mark - Private Methods
- (void)loadAllTasks {
    allTasks = [NSMutableArray arrayWithArray:[DBOperate loadAllTasks]];
}

- (void)statisticsButtonItemClick:(id) sender {
    
}

- (void)mainButtonItemClick:(id) sender {
    
}
@end
