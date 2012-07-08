//
//  EnterPinViewController.m
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterPinViewController.h"
#import "MBProgressHUD.h"
#import "WebService.h"
#import "Group+Helper.h"
#import "PlanamoUser+Helper.h"
#import "AddressBookScanner.h"
#import "CustomNavigationBar.h"
#import "NSManagedObjectContext+PatchedMagicalRecord.h"

@implementation EnterPinViewController

@synthesize rawPhoneNumber = _rawPhoneNumber;
@synthesize pinTextField = _pinTextField;
@synthesize continueButton = _continueButton;


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

#pragma mark - Custom Navigation Bar

-(void)setUpCustomNavigationBar{
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton* backButton = [customNavigationBar backButtonWith:[UIImage imageNamed:@"navigationBarBackButton.png"] highlight:nil leftCapWidth:14.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [customNavigationBar setText:@"Back" onBackButton:(UIButton*)self.navigationItem.leftBarButtonItem.customView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCustomNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pinTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPinTextField:nil];
    [self setContinueButton:nil];
    self.rawPhoneNumber = nil;
    [super viewDidUnload];
}


#pragma mark - Button actions

- (IBAction)continue:(id)sender
{   
    NSString *uuid = [self GetUUID];
    
    // Call server
    NSString *functionName = @"accounts/verifyNewMobileUser/";
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:uuid, @"deviceID", @"I", @"deviceType", nil];
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.rawPhoneNumber, @"phoneNumber", self.pinTextField.text, @"pinNumber", deviceInfo, @"deviceInfo", nil];   

    NSLog(@"Calling - POST %@, jsonData: %@", functionName, phoneNumberDictionary);
    
    [[WebService sharedWebService] postPath:functionName parameters:phoneNumberDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"%@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, next
        if (code == 0) {
            // Save authentication
            NSString *username = self.rawPhoneNumber;
            NSString *password = [NSString stringWithFormat:@"%@%@", @"I", uuid];
            [[WebService sharedWebService] authenticateUsername:username andPassword:password];
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Get JSON data for planamo user
            NSDictionary *userData = [JSON valueForKeyPath:@"user"];
            NSString *firstName = [userData valueForKey:@"firstName"];
            NSString *lastName = [userData valueForKey:@"lastName"];
            
            // Create planamo user
            PlanamoUser *planamoUser = [PlanamoUser MR_importFromObject:userData];
            planamoUser.isLoggedInUser = [NSNumber numberWithBool:YES];
            
            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
                [NSManagedObjectContext MR_setContextForBackgroundThread:localContext];
                
                // Scan address book
                [AddressBookScanner scanAddressBook];
            
                // Add groups
                [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"groupsForUser"]];
                
                [localContext MR_saveNestedContexts];
            }];
            
            // If name exists, end sign up process
            if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]) {
                [self.presentingViewController dismissModalViewControllerAnimated:YES];
            } else {
                // Otherwise, show enter name screen
                [self performSegueWithIdentifier:@"enterName" sender:self];
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_save];

        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            [self.pinTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.pinTextField becomeFirstResponder];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Verifying PIN number...";
    
    [self.pinTextField resignFirstResponder];
}

@end
