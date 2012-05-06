//
//  EnterPhoneNumberViewController.m
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterPhoneNumberViewController.h"
#import "EnterPinViewController.h"
#import "MBProgressHUD.h"

@implementation EnterPhoneNumberViewController

@synthesize phoneNumberTextField;
@synthesize continueButton;
@synthesize webService;
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
}

#pragma mark - Phone number formatter

- (void)createPhoneNumberFormatter {
    _textFieldSemaphore = 0;
    _phoneNumberFormatter = [[PhoneNumberFormatter alloc] init];
    [self.phoneNumberTextField addTarget:self
                                  action:@selector(autoFormatTextField:)
                        forControlEvents:UIControlEventValueChanged
     ];
    [self.phoneNumberTextField addTarget:self
                                  action:@selector(autoFormatTextField:)
                        forControlEvents:UIControlEventEditingChanged
     ];
}

- (void)autoFormatTextField:(id)sender {    
    if(_textFieldSemaphore) return;
    _textFieldSemaphore = 1;
    self.phoneNumberTextField.text = [_phoneNumberFormatter format:self.phoneNumberTextField.text withLocale:@"us"]; //TODO - internationalization
    _textFieldSemaphore = 0;
    
    // Set enter button to enabled/disabled
    // TODO - internationalization
    if ([_phoneNumberFormatter strip:self.phoneNumberTextField.text].length == 10) {
        [self.continueButton setEnabled:YES];
    } else {
        [self.continueButton setEnabled:NO];
    }
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createPhoneNumberFormatter];
    [self.continueButton setEnabled:NO];
    self.webService = [[WebService alloc] init];
    self.webService.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.phoneNumberTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPhoneNumberTextField:nil];
    [self setContinueButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Button actions

- (IBAction)continue:(id)sender
{    
    _rawPhoneNumber = [_phoneNumberFormatter strip:self.phoneNumberTextField.text]; 
    //Append USA country code - TODO internationalization
    _rawPhoneNumber = [NSString stringWithFormat:@"1%@", _rawPhoneNumber];
    [self.webService createNewMobileUserWithPhoneNumber:_rawPhoneNumber];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating account...";
    
    [self.phoneNumberTextField resignFirstResponder];
}

//temp
- (IBAction)login:(id)sender
{
    [self.webService loginMobile];
}

#pragma mark - Web Service Delegate

-(void)alertWebServiceWithErrorCode:(int)errorCode {
    // Only one possible error, so always alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Sorry! Unable to connect to server. Try again" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.phoneNumberTextField becomeFirstResponder];
}

-(void)createNewMobileUserCallbackReturn:(NSDictionary *)responseDictionary {
    NSLog(@"createNewMobileUser callback dictionary: %@", responseDictionary);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
    
    int code = [[responseDictionary valueForKey:@"code"] intValue];
    
    // If good, go to next page
    if (code == 0) {
        [self performSegueWithIdentifier:@"enterPin" sender:self];
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

#pragma mark - Enter Pin View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"enterPin"]) {
        EnterPinViewController *enterPinController = (EnterPinViewController *)[segue destinationViewController];
        enterPinController.rawPhoneNumber = _rawPhoneNumber;
        enterPinController.managedObjectContext = self.managedObjectContext;
    }
}


@end
