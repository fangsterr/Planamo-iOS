//
//  LaunchScreenViewController.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import "APIWebService.h"
#import "Group+Helper.h"
#import "AddressBookScanner.h"

@implementation LaunchScreenViewController

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get username and password
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    [[APIWebService sharedWebService] setAuthorizationHeaderWithUsername:username password:password];
    [[APIWebService sharedWebService] authenticateUsername:username andPassword:password]; //temp TODO - remove
    
    [[APIWebService sharedWebService] getPath:@"group" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"launch screen get group for user return: %@", JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (!jsonCode || code == 0) {
            // add data
            [Group updateOrCreateOrDeleteGroupsFromArray:[JSON valueForKeyPath:@"objects"] inManagedObjectContext:self.managedObjectContext];
                    
            [self dismissModalViewControllerAnimated:NO];            
        } else {
            // Otherwise, alert error (TODO - logout)
            [[APIWebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [[APIWebService sharedWebService] showAlertWithErrorCode:[error code]];
    }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
