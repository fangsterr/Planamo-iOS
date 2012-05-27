//
//  AddContactsViewController.m
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "AddContactsViewController.h"
#import "AddressBookScanner.h"
#import "APIWebService.h"
#import "PhoneNumber.h"
#import "AddressBookContact.h"
#import "MBProgressHUD.h"
#import "Group+Helper.h"

@implementation AddContactsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tokenField = _tokenField;
@synthesize group = _group;

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad
{
    self.tokenField.managedObjectContext = self.managedObjectContext;
    self.tokenField.labelText = @"Who:";
    [self.tokenField becomeFirstResponder];
    if (!_group) self.view = self.tokenField; // Group creation (view goes in AddGroupViewController)
    else [self.view addSubview:self.tokenField]; // Adding contacts
    [AddressBookScanner scanAddressBookWithManagedContext:self.managedObjectContext];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - IB Actions

-(IBAction)done {
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"group/%@/", self.group.id];
    
    // Convert user tokens into json array
    NSMutableArray *newUsersArray = [[NSMutableArray alloc] init];
    NSArray *contactsTokenArray = self.tokenField.tokens;
    for (ContactsTokenView *token in contactsTokenArray) {
        NSString *firstName = ((PhoneNumber *)token.object).owner.firstName;
        NSString *lastName = ((PhoneNumber *)token.object).owner.lastName;
        NSString *phoneNumber = ((PhoneNumber*)token.object).numberAsStringWithoutFormat;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:firstName, @"firstName", lastName, @"lastName", phoneNumber, @"phoneNumber", nil];
        NSDictionary *userInGroup = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"user", [NSNumber numberWithBool:NO], @"isOrganizer", nil];
        [newUsersArray addObject:userInGroup];
    }
    
    NSDictionary *updatedGroupDictionary = [NSDictionary dictionaryWithObjectsAndKeys: newUsersArray, @"usersInGroup", nil];
    
    NSLog(@"Calling API - PUT api/%@, jsonData: %@", functionName, updatedGroupDictionary);
    
    [[APIWebService sharedWebService] putPath:functionName parameters:updatedGroupDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"PUT %@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, save
        if (code == 0) {
            [Group updateOrCreateOrDeleteUsersInGroupFromArray:newUsersArray forGroup:self.group onlyUpdate:YES inManagedObjectContext:self.managedObjectContext];
            
            [self dismissModalViewControllerAnimated:YES];
            
        } else {
            // Otherwise, alert error and undo changes
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
            [self.tokenField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
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
