//
//  LaunchScreenViewController.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import "WebService.h"
#import "Group+Helper.h"
#import "NSManagedObjectContext+PatchedMagicalRecord.h"

@implementation LaunchScreenViewController

#pragma mark - Server calls

- (void)getGroupsFromServer {
    NSString *functionName = @"api/group/";
    NSLog(@"Calling - GET %@", functionName);
        
    [[WebService sharedWebService] getPath:functionName parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"%@ return: %@", functionName, JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (code == 0) {
            
            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
                [NSManagedObjectContext MR_setContextForBackgroundThread:localContext];

                // Add groups
                [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"objects"]];
                
                [localContext MR_saveNestedContexts];
            }];
            
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get username and password
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    [[WebService sharedWebService] authenticateUsername:username andPassword:password];
    
    NSLog(@"Logging in...");
    
    [[WebService sharedWebService] postPath:@"accounts/loginMobile/" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"loginMobile return: %@", JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (!jsonCode || code == 0) {
            // TODO - get groups for user - background
            
            [self dismissModalViewControllerAnimated:NO];            
        } else {
            // Otherwise, alert error (TODO - logout)
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];
    }];
    
    [self getGroupsFromServer]; // TODO - don't make it background
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
