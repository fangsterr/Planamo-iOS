//
//  GroupUsersListTableViewController.m
//  Planamo
//
//  Created by Stanley Tang on 29/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupUsersListTableViewController.h"

#import "PlanamoUser+Helper.h"
#import "GroupUsersListTableViewCell.h"
#import "MBProgressHUD.h"
#import "WebService.h"
#import "AddContactsViewController.h"

@implementation GroupUsersListTableViewController {
    NSIndexPath * currentPathEditing;
}

@synthesize group = _group;
@synthesize numUsersLabel = _numUsersLabel;
@synthesize editButton = _editButton;
@synthesize addButton = _addButton;
@synthesize delegate = _delegate;

-(void)displayNumOfUsersLabel {
    NSArray *groupUsersArray = [self.fetchedResultsController fetchedObjects];
    NSUInteger numberOfUsersInGroup = [groupUsersArray count];
    if (numberOfUsersInGroup == 1) {
        self.numUsersLabel.title = [NSString stringWithFormat:@"%d member", numberOfUsersInGroup];
    } else {
        self.numUsersLabel.title = [NSString stringWithFormat:@"%d members", numberOfUsersInGroup];
    }
}

#pragma mark - Server Calls

-(void)deleteUserFromGroup:(PlanamoUser *)userToDelete {
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"api/group/%@/users/%@/", self.group.id, userToDelete.id];
    
    NSLog(@"Calling DELETE %@", functionName);
    
    [[WebService sharedWebService] deletePath:functionName parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"DELETE %@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, delete user locally
        if (code == 0) {            
            
            // If user is logged in user, remove group, then go back to home screen
            if ([userToDelete.id isEqualToNumber:[PlanamoUser currentLoggedInUser].id]) {
                [self.group MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_save];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.delegate lastUserInGroupDidGetDeleted];
                }];
            } else {
                // Otherwise, just remove user from group
                [userToDelete removeGroupsObject:self.group];
                [[NSManagedObjectContext MR_defaultContext] MR_save];
            }
                        
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting user...";
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Delete user from group
        PlanamoUser *userToDelete = [self.fetchedResultsController objectAtIndexPath:currentPathEditing];
        [self deleteUserFromGroup:userToDelete];
    } else {
         // Cancelled. Do nothing
    }
}

#pragma mark - Fetched Results Controller

/**
 Create fetch request with Groups entity. Create fetched results controller and attach to this table view controller
 */
- (void)setupFetchedResultsController {
    NSFetchRequest *fetchRequest = [PlanamoUser MR_requestAllSortedBy:@"firstName" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"ANY groups.id = %@", self.group.id]];
    
    // Create and initialize fech results controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil]; //TODO - section name key path, cache name
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [self displayNumOfUsersLabel];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    self.title = self.group.name;
    [self displayNumOfUsersLabel];
}

- (void)viewDidUnload
{
    [self setNumUsersLabel:nil];
    [self setEditButton:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}

#pragma mark - IB Actions

-(IBAction)done{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)setEditMode:(UIBarButtonItem *)sender {
    if (self.editing) {
        [super setEditing:NO animated:YES];
    } else {
        [super setEditing:YES animated:YES];
    } 
}

#pragma mark - Table View Data Source / Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupUsersListCell";
    
    GroupUsersListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GroupUsersListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    PlanamoUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentPathEditing = indexPath;
	PlanamoUser *userToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *alertTitle = nil;
    
    if ([userToDelete.isLoggedInUser isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        alertTitle = [NSString stringWithFormat:@"Are you sure you want to remove yourself from the group?"];
    } else {
        alertTitle = [NSString stringWithFormat:@"Are you sure you want to remove %@ %@ from the group?", userToDelete.firstName, userToDelete.lastName];
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle 
                                                        message:@"You cannot undo this."
                                                       delegate:self
                                              cancelButtonTitle:@"Yes"
                                              otherButtonTitles:@"No", nil];
        [alert show];
    }
}

/** CODE THAT DOESN"T INDENT YOU IF IT'S YOU (but then, I thought, maybe the user can remove himself)
 
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupUserLink *groupUserLink = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([groupUserLink.user.isLoggedInUser boolValue]) {
        return NO;
    } else {
        return YES;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupUserLink *groupUserLink = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([groupUserLink.user.isLoggedInUser boolValue]) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}
 
 **/


#pragma mark - View Segue Transitions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addContacts"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddContactsViewController *addContactsController = (AddContactsViewController *)navController.topViewController;
        addContactsController.tokenField = [[ContactsTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        addContactsController.group = self.group;
    }
}

@end
