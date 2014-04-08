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

@interface TaskListViewController ()

@end

@implementation TaskListViewController  {
    NSMutableArray *items;
    NSArray *tasks;
    // When the objects have been changed, added or deleted, it can update the table.
    NSFetchedResultsController *fetchedResultsController;
}

@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
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

// 从数据库加载数据
- (void)loadFromCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    tasks = foundObjects;
}

- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskItem"];
    Task *item = [fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1000];
    titleLabel.text = item.text;
    [self configureCheckmarkForCell:cell withTask:item];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
     UILabel *titleLabel = (UILabel *)[cell viewWithTag:1000];
    Task *item = [fetchedResultsController objectAtIndexPath:indexPath];
    titleLabel.text = item.text;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    
    TaskItem *item = [fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"item is : %@", item.text);
    [self performSegueWithIdentifier:@"EditItem" sender:item];
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
    int index = [items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  
    [self configureTextForCell:cell withTaskItem:item];
     
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTaskViewControllerDidCancel:(ItemDetailViewController *)controller
{
    NSLog(@"Click the Cancel Button");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    TaskItem *item = [items objectAtIndex:indexPath.row];
    [item toggleCompleted];
    
    [self configureCheckmarkForCell:cell withTaskItem:item];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withTaskItem:(TaskItem *)item
{
    UILabel *label = (UILabel *)[cell viewWithTag:1001];
    
    if (item.completed) {
        label.text = @"√";
    } else {
        label.text = @"";
    }
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withTask:(Task *)item
{
    UILabel *label = (UILabel *)[cell viewWithTag:1001];
    
    if ([item.completed boolValue]) {
        label.text = @"√";
    } else {
        label.text = @"";
    }
}

- (void)configureTextForCell:(UITableViewCell *)cell withTaskItem:(TaskItem *)item
{
    UILabel *label =(UILabel *)[cell viewWithTag:1000];
    label.text = item.text;
}

- (void)configureTextForCell:(UITableViewCell *)cell withTask:(Task *)item
{
    UILabel *label =(UILabel *)[cell viewWithTag:1000];
    label.text = item.text;
}

- (void)dealloc
{
    fetchedResultsController.delegate = nil;
}
@end
