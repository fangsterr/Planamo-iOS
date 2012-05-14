//
//  EnterNameViewController.m
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterNameViewController.h"
#import "MBProgressHUD.h"
#import "APIWebService.h"

@implementation EnterNameViewController

@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize doneButton;
@synthesize rawPhoneNumber = _rawPhoneNumber;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentUser = _currentUser;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.firstNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{ 
    [self setLastNameTextField:nil];
    [self setFirstNameTextField:nil];
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

#pragma mark - Button actions

- (IBAction)done:(id)sender
{      
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"user/%@/", self.currentUser.id];
    NSDictionary *userUpdateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.firstNameTextField.text, @"firstName", self.lastNameTextField.text, @"lastName", nil];
    
    NSLog(@"Calling API - PUT api/%@, jsonData: %@", functionName, userUpdateDictionary);
    
    [[APIWebService sharedWebService] putPath:functionName parameters:userUpdateDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"PUT %@ - return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, update user and end sign up process
        if (!code || code == 0) {
            self.currentUser.firstName = self.firstNameTextField.text;
            self.currentUser.lastName = self.lastNameTextField.text;
            
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
            
            [self.presentingViewController dismissModalViewControllerAnimated:YES];
            
        } else {
            // Otherwise, alert error
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
            [self.firstNameTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.firstNameTextField becomeFirstResponder];
    }];

    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating name...";
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
}

@end
