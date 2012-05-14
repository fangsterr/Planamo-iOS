//
//  EnterPinViewController.m
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterPinViewController.h"
#import "MBProgressHUD.h"
#import "EnterNameViewController.h"
#import "UserActionsWebService.h"
#import "APIWebService.h"
#import "Group+Helper.h"
#import "PlanamoUser+Helper.h"
#import "AddressBookScanner.h"

@implementation EnterPinViewController

@synthesize currentUser = _currentUser;
@synthesize rawPhoneNumber = _rawPhoneNumber;
@synthesize pinTextField = _pinTextField;
@synthesize continueButton = _continueButton;
@synthesize managedObjectContext = _managedObjectContext;

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

/**
 Generates unique UUID for device
 */
- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pinTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPinTextField:nil];
    [self setContinueButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Button actions

- (IBAction)continue:(id)sender
{   
    NSString *uuid = [self GetUUID];
    
    // Call server
    NSString *functionName = @"verifyNewMobileUser/";
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:uuid, @"deviceID", @"I", @"deviceType", nil];
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.rawPhoneNumber, @"phoneNumber", self.pinTextField.text, @"pinNumber", deviceInfo, @"deviceInfo", nil];   

    NSLog(@"Calling user action - url:accounts/%@, jsonData: %@", functionName, phoneNumberDictionary);
    
    [[UserActionsWebService sharedWebService] postPath:functionName parameters:phoneNumberDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"verifyNewMobileUser return: %@", JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, next
        if (code == 0) {
            // Save authentication - TODO (in keychain)
            NSString *username = self.rawPhoneNumber;
            NSString *password = [NSString stringWithFormat:@"%@%@", @"I", uuid];
            
            [[APIWebService sharedWebService] setAuthorizationHeaderWithUsername:username password:password];
            [[APIWebService sharedWebService] authenticateUsername:username andPassword:password]; //temp TODO - remove
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Create planamo user in core data
            NSDictionary *user = [JSON valueForKeyPath:@"user"];
            NSNumber *userID = [NSNumber numberWithInt:[[user valueForKey:@"id"] intValue]];
            NSString *firstName = [user valueForKey:@"firstName"];
            NSString *lastName = [user valueForKey:@"lastName"];
            self.currentUser = [PlanamoUser findOrCreateUserWithPhoneNumber:self.rawPhoneNumber withManagedObjectContext:self.managedObjectContext];
            self.currentUser.id = userID;
            if (firstName) self.currentUser.firstName = firstName;
            if (lastName) self.currentUser.lastName = lastName;
            self.currentUser.isLoggedInUser = [NSNumber numberWithBool:YES];
            
            // Scan address book
            [AddressBookScanner scanAddressBookWithManagedContext:self.managedObjectContext];
            
            // Add groups
            [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"groupsForUser"] withManagedObjectContext:self.managedObjectContext];
            
            // If name exists, end sign up process
            if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]) {
                [self.presentingViewController dismissModalViewControllerAnimated:YES];
            } else {
                // Otherwise, show enter name screen
                [self performSegueWithIdentifier:@"enterName" sender:self];
            }

        } else {
            // Otherwise, alert error
            [[UserActionsWebService sharedWebService] showAlertWithErrorCode:code];
            [self.pinTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[UserActionsWebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.pinTextField becomeFirstResponder];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Verifying PIN number...";
    
    [self.pinTextField resignFirstResponder];
}


#pragma mark - Enter Name View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"enterName"]) {
        EnterNameViewController *enterNameController = (EnterNameViewController *)[segue destinationViewController];
        enterNameController.rawPhoneNumber = self.rawPhoneNumber;
        enterNameController.managedObjectContext = self.managedObjectContext;
        enterNameController.currentUser = self.currentUser;
    }
}

@end
