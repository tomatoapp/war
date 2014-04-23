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

@interface TaskListViewController ()

@end

@implementation TaskListViewController  {
    // When the objects have been changed, added or deleted, it can update the table.
    NSFetchedResultsController *fetchedResultsController;
    BOOL isShowHistoryTasks;
}

@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowHistoryTasks = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsShowHistoryTasks"];
    [self performFetch];
    [self firstRun];
}

// 首次运行程序
- (void)firstRun
{
    BOOL hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRun"];
    
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRun"];
        
        // Add the "Task Sample" item to the list.
        Task *sampleTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        sampleTask.text =NSLocalizedString(@"Task Sample", nil);
        sampleTask.costWorkTimes = [NSNumber numberWithInteger:0];
        sampleTask.completed = [NSNumber numberWithBool:NO];
        sampleTask.date = [NSDate date];
        NSError *error;
        if(![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
        // Set the default Second Sound to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SecondSound"];
        
        // Set the default Keep Screen Light to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"KeepLight"];
        
        // Set the Default Seconds.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:25] forKey:@"Seconds"];
    }
}

- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self showToolBarItems];
    [self.tableView reloadData];
}

- (void)showToolBarItems
{
    NSString *title;
    if (isShowHistoryTasks) {
        title = NSLocalizedString(@"Hidden History", nil);
    } else {
        title = NSLocalizedString(@"Show History", nil);
    }
    UIBarButtonItem *showHistoryButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory)];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 85.0f;
    
    self.toolbarItems = [NSArray arrayWithObjects:spacer, showHistoryButtonItem, nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)showHistory
{
    UIBarButtonItem *showHistoryButtonItem = (UIBarButtonItem *)[self.toolbarItems objectAtIndex:1];
    if (isShowHistoryTasks) {
        showHistoryButtonItem.title = NSLocalizedString(@"Show History", nil);
    } else {
        showHistoryButtonItem.title = NSLocalizedString(@"Hidden History", nil);
    }
    isShowHistoryTasks = !isShowHistoryTasks;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isShowHistoryTasks] forKey:@"IsShowHistoryTasks"];
    self.fetchedResultsController = nil;
    [self performFetch];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *completedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:completedSortDescriptor, dateSortDescriptor, nil]];
        
        if (!isShowHistoryTasks) {
            NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"completed == %@", [NSNumber numberWithBool:NO]];
            [fetchRequest setPredicate:fetchPredicate];
        }
        [fetchRequest setFetchBatchSize:20];
        [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:@"Tasks"];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newFetchedResultsController
{
    fetchedResultsController = newFetchedResultsController;
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
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(Task *)item
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
    }
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    Task *item = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = item.text;
    cell.subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"work times: %@", nil),item.costWorkTimes];
    cell.checkBox.checked = [item.completed boolValue];
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Task *item = [fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowItem" sender:task];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:task];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
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
        Task *task = [fetchedResultsController objectAtIndexPath:indexPath];
        task.completed = @([(Checkbox*)sender isChecked]);
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
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

- (void)dealloc
{
    fetchedResultsController.delegate = nil;
}
@end
