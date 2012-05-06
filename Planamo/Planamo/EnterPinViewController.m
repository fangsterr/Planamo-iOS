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

#import "PlanamoUser.h"
#import "GroupUserLink.h"
#import "Group.h"

@implementation EnterPinViewController

@synthesize rawPhoneNumber = _rawPhoneNumber;
@synthesize pinTextField = _pinTextField;
@synthesize continueButton = _continueButton;
@synthesize webService = _webService;
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

/**
 Creates new login user on iphone
 */
- (void)createNewLoginUserWithID:(NSNumber *)userID firstName:(NSString *)firstName lastName:(NSString *)lastName andGroups:(NSArray *)groups
{
    PlanamoUser *currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"PlanamoUser" inManagedObjectContext:self.managedObjectContext];
    currentUser.id = userID;
    currentUser.firstName = firstName;
    currentUser.lastName = lastName;
    currentUser.phoneNumber = self.rawPhoneNumber;
    currentUser.isLoggedInUser = [NSNumber numberWithBool:YES];
    
    //TODO - add groups
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webService = [[WebService alloc] init];
    self.webService.delegate = self;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button actions

- (IBAction)continue:(id)sender
{        
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self GetUUID], @"deviceID", @"I", @"deviceType", nil];
    [self.webService verifyNewMobileUserWithPhoneNumber:self.rawPhoneNumber pinNumber:self.pinTextField.text andDeviceInfo:deviceInfo];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Verifying PIN number...";
    
    [self.pinTextField resignFirstResponder];
}


#pragma mark - Web Service Delegate

-(void)alertWebServiceWithErrorCode:(int)errorCode {  
    UIAlertView *alert;
    if (errorCode == 1) {
        alert = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" 
                                                    message:@"Sorry! Please enter your PIN again." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                           message:@"Sorry! Unable to connect to server. Try again" 
                                          delegate:nil 
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    [alert show];
    [self.pinTextField becomeFirstResponder];
}


-(void)verifyNewMobileUserCallbackReturn:(NSDictionary *)responseDictionary {
    NSLog(@"verifyNewMobileUser callback dictionary: %@", responseDictionary);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
    
    int code = [[responseDictionary valueForKey:@"code"] intValue];
    
    // If good, go to next page
    if (code == 0) {
        NSNumber *userID = [NSNumber numberWithInt:[[responseDictionary valueForKey:@"id"] intValue]];
        NSString *firstName = [responseDictionary valueForKey:@"firstName"];
        NSString *lastName = [responseDictionary valueForKey:@"lastName"];
        NSArray *groups = [responseDictionary valueForKey:@"groupsForUser"];
        
        // If name exists, create user and end sign up process
        if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]) {
            //[self createNewLoginUserWithID:userID firstName:firstName lastName:lastName andGroups:groups];
            [self.presentingViewController dismissModalViewControllerAnimated:YES];
        } else {
            // Otherwise, show enter name screen
            [self performSegueWithIdentifier:@"enterName" sender:self];
        }
    } else {
        // Otherwise, alert error
        [self alertWebServiceWithErrorCode:code];
    }
}

-(void)webService:(WebService *)webService didFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
    
    int errorCode = [error code];
    [self alertWebServiceWithErrorCode:errorCode];
}

#pragma mark - Enter Name View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"enterName"]) {
        EnterNameViewController *enterNameController = (EnterNameViewController *)[segue destinationViewController];
        enterNameController.rawPhoneNumber = _rawPhoneNumber;
        enterNameController.managedObjectContext = self.managedObjectContext;
    }
}

@end
