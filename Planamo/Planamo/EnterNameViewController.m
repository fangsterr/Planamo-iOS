//
//  EnterNameViewController.m
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "EnterNameViewController.h"
#import "MBProgressHUD.h"
#import "WebService.h"
#import "PlanamoUser+Helper.h"

@implementation EnterNameViewController

@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize doneButton;


#pragma mark - View lifecycle

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
}


#pragma mark - Button actions

- (IBAction)done:(id)sender
{      
    PlanamoUser *user = [PlanamoUser currentLoggedInUser];
    
    // Call server
    NSString *functionName = [NSString stringWithFormat:@"api/user/%@/", user.id];
    NSDictionary *userUpdateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.firstNameTextField.text, @"firstName", self.lastNameTextField.text, @"lastName", nil];
    
    NSLog(@"Calling - PUT %@, jsonData: %@", functionName, userUpdateDictionary);
    
    [[WebService sharedWebService] putPath:functionName parameters:userUpdateDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"PUT %@ - return: %@", functionName, JSON);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        int code = [[JSON valueForKeyPath:@"code"] intValue];
        
        // If good, update user and end sign up process
        if (code == 0) {
            user.firstName = self.firstNameTextField.text;
            user.lastName = self.lastNameTextField.text;
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            
            [self dismissModalViewControllerAnimated:YES];
            
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
            [self.firstNameTextField becomeFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES]; // remove progress indicator
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
        [self.firstNameTextField becomeFirstResponder];
    }];

    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating name...";
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
}

@end
