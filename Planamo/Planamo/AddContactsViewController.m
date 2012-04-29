//
//  AddContactsViewController.m
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "AddContactsViewController.h"
#import "AddressBookScanner.h"

@implementation AddContactsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tokenField = _tokenField;

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
   // self.tokenField = [[ContactsTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    self.tokenField.managedObjectContext = self.managedObjectContext;
    self.tokenField.labelText = @"Who:";
    [self.tokenField becomeFirstResponder];
    self.view = self.tokenField;
    [AddressBookScanner scanAddressBookWithManagedContext:self.managedObjectContext];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
