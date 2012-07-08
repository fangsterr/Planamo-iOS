//
//  AddContactsViewController.m
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "AddContactsViewController.h"
#import "AddressBookScanner.h"
#import "WebService.h"
#import "PhoneNumber.h"
#import "AddressBookContact.h"
#import "MBProgressHUD.h"
#import "Group+Helper.h"
#import "NSManagedObjectContext+PatchedMagicalRecord.h"
#import "PlanamoUser+Helper.h"

@implementation AddContactsViewController

@synthesize tokenField = _tokenField;
@synthesize group = _group;

- (NSMutableArray *)convertUserTokensIntoUsersArray {
    // Convert user tokens into json array
    NSMutableArray *newUsersArray = [[NSMutableArray alloc] init];
    NSArray *contactsTokenArray = self.tokenField.tokens;
    for (ContactsTokenView *token in contactsTokenArray) {
        NSString *firstName = ((PhoneNumber *)token.object).owner.firstName;
        NSString *lastName = ((PhoneNumber *)token.object).owner.lastName;
        NSString *phoneNumber = ((PhoneNumber*)token.object).numberAsStringWithoutFormat;
        if ([phoneNumber isEqualToString:[PlanamoUser currentLoggedInUser].phoneNumber]) continue;
        NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:firstName, @"firstName", lastName, @"lastName", phoneNumber, @"phoneNumber", nil];
        [newUsersArray addObject:userData];
    }

    return newUsersArray;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.tokenField.managedObjectContext = [NSManagedObjectContext MR_defaultContext]; // TODO
    self.tokenField.labelText = @"Who:";
    [self.tokenField becomeFirstResponder];
    if (!_group) self.view = self.tokenField; // Group creation (view goes in AddGroupViewController)
    else [self.view addSubview:self.tokenField]; // Adding contacts
    [AddressBookScanner scanAddressBook];
}


#pragma mark - IB Actions

-(IBAction)done {
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"api/group/%@/users/", self.group.id];
    NSArray *usersArray = [self convertUserTokensIntoUsersArray];
    NSDictionary *updatedGroupUsersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:usersArray, @"users", nil];
    
    NSLog(@"Calling PUT %@, jsonData: %@", functionName, updatedGroupUsersDictionary);
    
    [[WebService sharedWebService] putPath:functionName parameters:updatedGroupUsersDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"PUT %@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, save
        if (code == 0) {
           
            [self dismissViewControllerAnimated:YES completion:^{
                [self.group addUsersToGroup:[JSON valueForKeyPath:@"users"]];
                [[NSManagedObjectContext MR_defaultContext] MR_save];
            }];

        } else {
            // Otherwise, alert error and undo changes
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            [self.tokenField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.tokenField becomeFirstResponder];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding users...";
    [self.tokenField resignFirstResponder];
}

-(IBAction)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

@end
