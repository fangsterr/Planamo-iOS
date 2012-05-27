//
//  GroupsListTableViewController.m
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupsListTableViewController.h"
#import "Group+Helper.h"
#import "GroupUsersListTableViewController.h"
#import "APIWebService.h"

@implementation GroupsListTableViewController {
    PullToRefreshView *pull;
}

@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Fetched Results Controller

/**
 Create fetch request with Groups entity. Create fetched results controller and attach to this table view controller
 */
- (void)setupFetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastUpdated" ascending:YES]];
    
    // Create and initialize fech results controller
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //TODO - section name key path, cache name
    self.fetchedResultsController = aFetchedResultsController;
}

#pragma mark - PullToRefresh Delegate

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [[APIWebService sharedWebService] getPath:@"group" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"pull to refresh get group return: %@", JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (!jsonCode || code == 0) {
            // add data
            [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"objects"] inManagedObjectContext:self.managedObjectContext];
            
            [pull finishedLoading];
            
        } else {
            // Otherwise, alert error (TODO - logout)
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
            
            [pull finishedLoading];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
        
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
} */

#pragma mark - View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"groupUsersList"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        GroupUsersListTableViewController *groupUsersController = [segue destinationViewController];
        groupUsersController.group = [self.fetchedResultsController objectAtIndexPath:selectedRowIndex];
        groupUsersController.managedObjectContext = self.managedObjectContext;
    }
}

@end
