//
//  WorkAndRestViewController.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-4.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "TaskListViewController.h"
#import "ItemDetailViewController.h"
#import "Checkbox.h"
#import "CustomCell.h"
#import "WorkWithItemViewController.h"
#import "Masonry.h"

#import "WorkAndRest-Swift.h"

@interface TaskListViewController ()
@end

@implementation TaskListViewController  {
    NSMutableArray *allTasks;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 50)];
    
    [self loadAllTasks];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.itemToEdit = sender;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowItem"]) {
        WorkWithItemViewController *controller = segue.destinationViewController;
        controller.itemToWork = sender;
    }
}

#pragma mark - NewTaskViewControllerDelegate

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishAddingTask:(Task *)item
{
    [self performSelector:@selector(insertItem:) withObject:item afterDelay:0.4];
    [DBOperate insertTask:item];
}

- (void)insertItem:(Task*)newItem
{
    [self.tableView beginUpdates];
    [allTasks insertObject:newItem atIndex:0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)insertItem:(Task*)newItem withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView beginUpdates];
    [allTasks insertObject:newItem atIndex:0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)deleteItem:(Task*)item withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView beginUpdates];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:[allTasks indexOfObject:item] inSection:0]];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [allTasks removeObject:item];
    [self.tableView endUpdates];
}

- (void)moveItem:(Task*)item
{
    [self deleteItem:item withRowAnimation:UITableViewRowAnimationLeft];
    [self insertItem:item withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addTaskViewController:(ItemDetailViewController *)controller didFinishEditingTask:(Task *)item
{
    [self performSelector:@selector(moveItem:) withObject:item afterDelay:0.5];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    Task *item = [allTasks objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Task *item = [allTasks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [allTasks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:task];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%@ %@", @(indexPath.section), @(indexPath.row));
        Task *task = [allTasks objectAtIndex:indexPath.row];
        [DBOperate deleteTask:task];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:indexPath];
        
        [self deleteItem:task withRowAnimation:UITableViewRowAnimationFade];

    }
}

#pragma mark - Private Methods
- (void)loadAllTasks {
    NSArray *result = [DBOperate loadAllTasks];
    NSArray *sortedResult = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(Task*)obj1 taskId] < [(Task*)obj2 taskId];
    }];
    allTasks = [NSMutableArray arrayWithArray:sortedResult];
}

- (UIView*)createHeaderView {
    // UNDONE:
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(50, 20, 240, 73);

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(240, 74));
        make.center.mas_equalTo(headerView.center);
    }];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:5];
//    [button setImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [button setAdjustsImageWhenHighlighted:NO];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"start_button_pressed"] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"start_button_pressed"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(newTaskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    return headerView;
}

- (void)newTaskButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"EditItem" sender:nil];
}

@end
