//
//  EnterNameViewController.m
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterNameViewController.h"
#import "MBProgressHUD.h"

@implementation EnterNameViewController

@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize doneButton;
@synthesize rawPhoneNumber = _rawPhoneNumber;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button actions

- (IBAction)done:(id)sender
{        
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating name...";
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
}


#pragma mark - Web Service Delegate

-(void)alertWebServiceWithErrorCode:(int)errorCode {  
    // Only one error possible
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                           message:@"Sorry! Unable to connect to server. Try again" 
                                          delegate:nil 
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    [alert show];
    [self.firstNameTextField becomeFirstResponder];
}


-(void)verifyNewMobileUserCallbackReturn:(NSDictionary *)responseDictionary {
    NSLog(@"verifyNewMobileUser callback dictionary: %@", responseDictionary);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
    
    int code = [[responseDictionary valueForKey:@"code"] intValue];
    
    // If good, go to next page
    if (code == 0) {
        //     [self performSegueWithIdentifier:@"enterPin" sender:self];
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

@end
