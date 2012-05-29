//
//  GroupUsersListTableViewController.m
//  Planamo
//
//  Created by Stanley Tang on 29/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupUsersListTableViewController.h"

#import "GroupUserLink.h"
#import "PlanamoUser.h"
#import "GroupUsersListTableViewCell.h"
#import "MBProgressHUD.h"
#import "APIWebService.h"
#import "AddContactsViewController.h"
#import "CustomNavigationBar.h"

@implementation GroupUsersListTableViewController {
    NSIndexPath * currentPathEditing;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize group = _group;
@synthesize numUsersLabel = _numUsersLabel;
@synthesize editButton = _editButton;
@synthesize addButton = _addButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Server Calls

- (void)updateGroup:(Group *)group withUsers:(NSArray *)users {
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"group/%@/", group.id];
    
    NSDictionary *updatedGroupDictionary = [NSDictionary dictionaryWithObjectsAndKeys: users, @"usersInGroup", nil];
    
    NSLog(@"Calling API - PUT api/%@, jsonData: %@", functionName, updatedGroupDictionary);
    
    [[APIWebService sharedWebService] putPath:functionName parameters:updatedGroupDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"PUT %@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, save
        if (code == 0) {
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
            
        } else {
            // Otherwise, alert error and undo changes
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
            [self.managedObjectContext undo];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating user...";
}


#pragma mark - Fetched Results Controller

/**
 Create fetch request with Groups entity. Create fetched results controller and attach to this table view controller
 */
- (void)setupFetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"GroupUserLink" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group.id = %@", self.group.id];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"user.firstName" ascending:YES]];
    
    // Create and initialize fech results controller
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //TODO - section name key path, cache name
    self.fetchedResultsController = aFetchedResultsController;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    self.title = self.group.name;
    
    NSArray *groupUserLinkArray = [self.fetchedResultsController fetchedObjects];
    NSUInteger numberOfUsersInGroup = [groupUserLinkArray count];
    if (numberOfUsersInGroup == 1) {
        self.numUsersLabel.title = [NSString stringWithFormat:@"%d member", numberOfUsersInGroup];
    } else {
        self.numUsersLabel.title = [NSString stringWithFormat:@"%d members", numberOfUsersInGroup];
    }
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
    GroupUserLink *groupUserLink = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", groupUserLink.user.firstName, groupUserLink.user.lastName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	//GroupUserLink *groupUserLinkDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Not Working" 
                                                        message:@"We haven't implemented delete yet. Coming soon!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        // TODO - get delete user working. Need to implement NSFetchedResultsController Delegate
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
        addContactsController.managedObjectContext = self.managedObjectContext;
        addContactsController.tokenField = [[ContactsTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        addContactsController.group = self.group;
    }
}

@end
