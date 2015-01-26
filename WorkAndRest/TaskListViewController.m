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

//@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadAllTasks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
//        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.itemToEdit = sender;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowItem"]) {
        WorkWithItemViewController *controller = segue.destinationViewController;
        controller.itemToWork = sender;
//        controller.managedObjectContext = self.managedObjectContext;
    }
}

//#pragma mark - NSFetchedResultsControllerDelegate
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"*** controllerWillChangeContent");
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller
//   didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath
//     forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeInsert");
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeDelete");
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeUpdate");
//            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeMove");
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}


//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"*** controllerDidChangeContent");
//    [self.tableView endUpdates];
//}

#pragma mark - NewTaskViewControllerDelegate

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(Task *)item
{
    [DBOperate insertTask:item];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:item] withRowAnimation:UITableViewRowAnimationFade];
    [allTasks insertObject:item atIndex:0];
    [self.tableView reloadData];
    
}

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(Task *)item
{
    [DBOperate updateTask:item];
}

- (void)addTaskViewControllerDidCancel:(ItemDetailViewController *)controller
{
    NSLog(@"Click the Cancel Button");
}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allTasks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 130.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    //view.backgroundColor = [UIColor redColor];
    UIButton *button = [UIButton new];
    button.frame = CGRectMake(50, 20, 200, 80);
    [button setTitle:@"Start a new Timer" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(newTaskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
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
        [allTasks removeObject:task];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (UIView*)createHeaderView {
    UIView *headerView = [UIView new];
    // UNDONE:
    return headerView;
}

- (void)newTaskButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"AddItem" sender:nil];
}
@end
