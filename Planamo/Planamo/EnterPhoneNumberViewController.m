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
#import "WebService.h"
#import "PhoneNumberFormatter.h"

@implementation EnterPhoneNumberViewController {
    int _textFieldSemaphore;
    PhoneNumberFormatter *_phoneNumberFormatter;
    NSString *_rawPhoneNumber;
}

@synthesize phoneNumberTextField;
@synthesize continueButton;

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
    [super viewDidUnload];
}


#pragma mark - Button Action

- (IBAction)continue:(id)sender
{    
    // Get number and append USA country code - TODO internationalization
    _rawPhoneNumber = [_phoneNumberFormatter strip:self.phoneNumberTextField.text]; 
    _rawPhoneNumber = [NSString stringWithFormat:@"+1%@", _rawPhoneNumber];
    
    // TODO - debug
    [self performSegueWithIdentifier:@"enterPin" sender:self];
    return;

    // Call server
    NSString *functionName = @"accounts/createNewMobileUser/";
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:_rawPhoneNumber, @"phoneNumber", @"j0d1eCHILLBE4R", @"secretCode", nil];
    
    NSLog(@"Calling - POST %@, jsonData: %@", functionName, phoneNumberDictionary);
    
    [[WebService sharedWebService] postPath:functionName parameters:phoneNumberDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"%@ return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        if (code == 0) { // If good, next
            [self performSegueWithIdentifier:@"enterPin" sender:self];
        
        } else { //Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            [self.phoneNumberTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
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
    }
}


@end
