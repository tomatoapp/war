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
#import "Masonry.h"

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
    [self performSelector:@selector(insertItem:) withObject:item afterDelay:0.5];
}

- (void)insertItem:(Task*)newItem
{
    [DBOperate insertTask:newItem];
    [allTasks insertObject:newItem atIndex:0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Private Methods
- (void)loadAllTasks {
    NSArray *result = [DBOperate loadAllTasks];
    NSArray *sortedResult = result; // UNDONE:
    allTasks = [NSMutableArray arrayWithArray:sortedResult];
}

- (UIView*)createHeaderView {
    // UNDONE:
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    UIButton *button = [UIButton new];
//    button.frame = CGRectMake(50, 20, 240, 73);

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(240, 73));
        make.center.mas_equalTo(headerView.center);
    }];
    [button setImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(newTaskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    return headerView;
}

- (void)newTaskButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"EditItem" sender:nil];
}

@end
