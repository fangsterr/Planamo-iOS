//
//  GroupsListTableViewController.m
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupsListTableViewController.h"
#import "Group.h"
#import "EnterPhoneNumberViewController.h"

@implementation GroupsListTableViewController

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

/** 
 Returns true if there is a user already logged in on the app. Otherwise false (so can show sign up process)
 */
- (BOOL)isAUserLoggedIn 
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlanamoUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"isLoggedInUser = %@", [NSNumber numberWithBool:YES]];
    
    NSError *error = nil;
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!userArray || ([userArray count] > 1)) {
        NSLog(@"Error feteching loggedInUser from core data");
        return NO;
    } else if (![userArray count]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Fetched results controller

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //TODO - if user not logged in
    [self.navigationController performSegueWithIdentifier:@"signUpProcess" sender:self];
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

#pragma mark - Table view data source

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Add Group View

- (void)addGroupViewControllerDidCancel:(AddGroupViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addGroupViewControllerDidFinish:(AddGroupViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    //TODO - show groups list
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addGroup"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddGroupViewController *addGroupController = (AddGroupViewController *)navController.topViewController;
        addGroupController.delegate = self;
        addGroupController.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"signUpProcess"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        EnterPhoneNumberViewController *phoneNumberController = (EnterPhoneNumberViewController *)navController.topViewController;
        phoneNumberController.managedObjectContext = self.managedObjectContext;
    }
}

@end
