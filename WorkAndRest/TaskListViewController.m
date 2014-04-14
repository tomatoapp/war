//
//  WorkAndRestViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-4.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "TaskListViewController.h"
#import "ItemDetailViewController.h"
#import "TaskItem.h"
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
        
        TaskItem *item;
        item = [[TaskItem alloc] init];
        item.text = @"Task Sample";
        item.completed = YES;
        item.costWorkTimes = 5;
        
        Task *sampleTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        sampleTask.text = item.text;
        sampleTask.costWorkTimes = [NSNumber numberWithInteger:item.costWorkTimes];
        sampleTask.completed = [NSNumber numberWithBool:item.completed];
        
        NSError *error;
        if(![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
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
    [self.tableView reloadData];}

- (void)showToolBarItems
{
    NSString *title;
    if (isShowHistoryTasks) {
        title = @"Hidden History";
    } else {
        title = @"Show History";
    }
    UIBarButtonItem *showHistoryButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory)];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 95.0f;
    
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
        showHistoryButtonItem.title = @"Show History";
    } else {
        showHistoryButtonItem.title = @"Hidden History";
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
            // 简便写法：
            // NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"completed == 0"];
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

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(TaskItem *)item
{
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    task.text = item.text;
    task.completed = [NSNumber numberWithBool:NO];
    task.costWorkTimes = [NSNumber numberWithInteger:0];
    task.date = [NSDate date];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(TaskItem *)item
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
    cell.subTitleLabel.text = [NSString stringWithFormat:@"cost: %@",item.costWorkTimes];
    cell.checkBox.checked = [item.completed boolValue];
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    
    Task *item = [fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"item is : %@", item.text);
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
