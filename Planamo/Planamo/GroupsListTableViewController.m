//
//  GroupsListTableViewController.m
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupsListTableViewController.h"
#import "Group+Helper.h"
#import "WebService.h"
#import "GroupMessagesViewController.h"

@implementation GroupsListTableViewController {
    PullToRefreshView *pull;
}

#pragma mark - Fetched Results Controller

/**
 Create fetch request with Groups entity. Create fetched results controller and attach to this table view controller
 */
- (void)setupFetchedResultsController {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *fetchRequest = [Group MR_requestAllSortedBy:@"id" ascending:YES]; // TODO - sort by last message
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:localContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil]; // TODO - cache name
}

#pragma mark - PullToRefresh Delegate

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{    
    [[WebService sharedWebService] getPath:@"api/group/" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"pull to refresh get group return: %@", JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (code == 0) {
            // add data
            [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"objects"]];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            
            [pull finishedLoading];
            
        } else {
            // Otherwise, alert error (TODO - logout)
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            
            [pull finishedLoading];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
        
        [pull finishedLoading];
    }];
    
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set table view bounds to fit within root view controller (with tabbar)
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
   
    // If put in viewWillAppear, only need to set height to 367 - TODO
    CGRect frame = self.view.frame;
	frame.size.height = 412;
	self.view.frame = frame;
    
    // Pull to refresh
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}


#pragma mark - Table View Data Source / Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupsListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = group.name;
    
    return cell;
}


#pragma mark - View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"groupMessages"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        GroupMessagesViewController *groupMessagesController = [segue destinationViewController];
        groupMessagesController.group = [self.fetchedResultsController objectAtIndexPath:selectedRowIndex];
    }
}

@end
