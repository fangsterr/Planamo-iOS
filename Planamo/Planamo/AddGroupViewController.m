//
//  AddGroupViewController.m
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "AddGroupViewController.h"

#import "PhoneNumber.h"
#import "PlanamoUser+Helper.h"
#import "Group+Helper.h"
#import "AddressBookContact.h"
#import "AddContactsViewController.h"
#import "APIWebService.h"
#import "MBProgressHUD.h"

@interface AddGroupViewController ()

@property (nonatomic, strong) AddContactsViewController *addContactsController;

@end

@implementation AddGroupViewController

@synthesize groupNameTextField = _groupNameTextField;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize contactsView = _contactsView;
@synthesize doneButton = _doneButton;
@synthesize addContactsController = _addContactsController;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addContactsController = [[AddContactsViewController alloc] init];
    self.addContactsController.managedObjectContext = self.managedObjectContext;
    self.addContactsController.tokenField = [[ContactsTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    self.addContactsController.tokenField.tokenFieldDelegate = self;
    [self.contactsView addSubview:self.addContactsController.view];
    
    self.groupNameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.groupNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setGroupNameTextField:nil];
    [self setView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

// TODO - show welcome message screen
- (IBAction)done:(id)sender
{
    // Convert user tokens into json array
    NSMutableArray *usersInGroupArray = [[NSMutableArray alloc] init];
    NSArray *contactsTokenArray = self.addContactsController.tokenField.tokens;
    for (ContactsTokenView *token in contactsTokenArray) {
        NSString *firstName = ((PhoneNumber*)token.object).owner.firstName;
        NSString *lastName = ((PhoneNumber*)token.object).owner.lastName;
        NSString *phoneNumber = ((PhoneNumber*)token.object).numberAsStringWithoutFormat;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:firstName, @"firstName", lastName, @"lastName", phoneNumber, @"phoneNumber", nil];
        NSDictionary *userInGroup = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"user", [NSNumber numberWithBool:NO], @"isOrganizer", nil];
        [usersInGroupArray addObject:userInGroup];
    }
    
    // Add logged in user to users json array
    PlanamoUser *currentUser = [PlanamoUser currentLoggedInUserInManagedObjectContext:self.managedObjectContext];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:currentUser.firstName, @"firstName", currentUser.lastName, @"lastName", currentUser.phoneNumber, @"phoneNumber", nil];
    NSDictionary *userInGroup = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"user", [NSNumber numberWithBool:YES], @"isOrganizer", nil];
    [usersInGroupArray addObject:userInGroup];
    
    // Get group name
    NSString *groupName = self.groupNameTextField.text;
    
    // Create default welcome message - TODO
    NSString *welcomeMessage = [NSString stringWithFormat:@"You just got added to the %@ group by %@ %@ on Planamo. However, replies will only go to %@ and the organizers", groupName, currentUser.firstName, currentUser.lastName, currentUser.firstName];
    
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"group/"];
    NSMutableDictionary *newGroupDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupName, @"name", usersInGroupArray, @"usersInGroup", welcomeMessage, @"welcomeMessage", nil];
    
    NSLog(@"Calling API - POST api/%@, jsonData: %@", functionName, newGroupDictionary);
    
    [[APIWebService sharedWebService] postPath:functionName parameters:newGroupDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"POST %@ - return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, create group and end group creation process
        if (!code || code == 0) {
            NSNumber *groupID = [NSNumber numberWithInt:[[JSON valueForKeyPath:@"id"] intValue]];
            NSString *twilioNumberForUser = [JSON valueForKeyPath:@"twilioNumberForUser"];
            [newGroupDictionary setObject:groupID forKey:@"id"]; 
            [newGroupDictionary setObject:twilioNumberForUser forKey:@"twilioNumberForUser"];
            
            [Group createNewGroupFromDictionary:newGroupDictionary inManagedObjectContext:self.managedObjectContext];
            [self dismissModalViewControllerAnimated:YES];
            
        } else {
            // Otherwise, alert error
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
            [self.groupNameTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.groupNameTextField becomeFirstResponder];
    }];
    
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating group...";
    
    [self.groupNameTextField resignFirstResponder];
    [self.addContactsController.tokenField resignFirstResponder]; 
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Add contacts view

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAddContacts"]) {
        //[[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - ContactsTokenFieldDelegate

/**
 HELPER FUNCTION. Updates done button enabled status (enabled only if there is a group name and at least one contact)
 */
- (void)updateDoneButtonEnabledStatus
{
    [self.doneButton setEnabled:[self.addContactsController.tokenField.tokens count] > 0 && [self.groupNameTextField.text length] > 0];
}

- (void)tokenField:(ContactsTokenField*)tokenField didAddObject:(id)object {
    [self updateDoneButtonEnabledStatus];
}

- (void)tokenField:(ContactsTokenField*)tokenField didRemoveObject:(id)object {
    [self updateDoneButtonEnabledStatus];
}

#pragma mark - Group name text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateDoneButtonEnabledStatus];
}

@end
