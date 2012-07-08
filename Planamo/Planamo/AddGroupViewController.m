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
#import "WebService.h"
#import "MBProgressHUD.h"

@interface AddGroupViewController ()

@property (nonatomic, strong) AddContactsViewController *addContactsController;

@end

@implementation AddGroupViewController

@synthesize groupNameTextField = _groupNameTextField;
@synthesize contactsView = _contactsView;
@synthesize doneButton = _doneButton;
@synthesize addContactsController = _addContactsController;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addContactsController = [[AddContactsViewController alloc] init];
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
    [self setContactsView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    NSMutableArray *usersArray = self.addContactsController.convertUserTokensIntoUsersArray;
    
    // Add logged in user to users json array
    PlanamoUser *currentUser = [PlanamoUser currentLoggedInUser];
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:currentUser.firstName, @"firstName", currentUser.lastName, @"lastName", currentUser.phoneNumber, @"phoneNumber", nil];
    [usersArray addObject:userData];
    
    // Get group name
    NSString *groupName = self.groupNameTextField.text;
    
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"api/group/"];
    NSMutableDictionary *newGroupDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupName, @"name", usersArray, @"users", nil];
    
    NSLog(@"Calling - POST %@, jsonData: %@", functionName, newGroupDictionary);
    
    [[WebService sharedWebService] postPath:functionName parameters:newGroupDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"POST %@ - return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, create group and end group creation process
        if (code == 0) {
            [self dismissViewControllerAnimated:YES completion:^{
                Group *group = [Group MR_importFromObject:JSON];
                group.lastUpdated = [NSDate date];
                [[NSManagedObjectContext MR_defaultContext] MR_save];
            }];
            
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            [self.groupNameTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
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
