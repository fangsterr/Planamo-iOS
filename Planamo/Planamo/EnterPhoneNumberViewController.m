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
#import "UserActionsWebService.h"

@implementation EnterPhoneNumberViewController {
    int _textFieldSemaphore;
    PhoneNumberFormatter *_phoneNumberFormatter;
    NSString *_rawPhoneNumber;
}

@synthesize phoneNumberTextField;
@synthesize continueButton;
@synthesize managedObjectContext = _managedObjectContext;


#pragma mark - Phone Number Formatter

- (void)createPhoneNumberFormatter {
    _textFieldSemaphore = 0;
    _phoneNumberFormatter = [[PhoneNumberFormatter alloc] init];
    [self.phoneNumberTextField addTarget:self
                                  action:@selector(autoFormatTextField:)
                        forControlEvents:UIControlEventValueChanged];
    [self.phoneNumberTextField addTarget:self
                                  action:@selector(autoFormatTextField:)
                        forControlEvents:UIControlEventEditingChanged];
}

- (void)autoFormatTextField:(id)sender {    
    if(_textFieldSemaphore) return;
    _textFieldSemaphore = 1;
    self.phoneNumberTextField.text = [_phoneNumberFormatter format:self.phoneNumberTextField.text withLocale:@"us"]; //TODO - internationalization
    _textFieldSemaphore = 0;
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.phoneNumberTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPhoneNumberTextField:nil];
    [self setContinueButton:nil];
    self.managedObjectContext = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Button Action

- (IBAction)continue:(id)sender
{    
    // Get number and append USA country code - TODO internationalization
    _rawPhoneNumber = [_phoneNumberFormatter strip:self.phoneNumberTextField.text]; 
    _rawPhoneNumber = [NSString stringWithFormat:@"+1%@", _rawPhoneNumber];

    // Call server
    NSString *functionName = @"createNewMobileUser/";
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:_rawPhoneNumber, @"phoneNumber", @"j0d1eCHILLBE4R", @"secretCode", nil];
    
    NSLog(@"Calling user action - url:accounts/%@, jsonData: %@", functionName, phoneNumberDictionary);
    
    [[UserActionsWebService sharedWebService] postPath:functionName parameters:phoneNumberDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"createNewMobileUser return: %@", JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, next
        if (code == 0) {
            [self performSegueWithIdentifier:@"enterPin" sender:self];
        } else {
            // Otherwise, alert error
            [[UserActionsWebService sharedWebService] showAlertWithErrorCode:code];
            [self.phoneNumberTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[UserActionsWebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.phoneNumberTextField becomeFirstResponder];
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating account...";
    
    [self.phoneNumberTextField resignFirstResponder];
}

#pragma mark - View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"enterPin"]) {
        EnterPinViewController *enterPinController = (EnterPinViewController *)[segue destinationViewController];
        enterPinController.rawPhoneNumber = _rawPhoneNumber;
        enterPinController.managedObjectContext = self.managedObjectContext;
    }
}


@end
