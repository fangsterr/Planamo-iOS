//
//  AddGroupViewController.m
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "AddGroupViewController.h"

#import "PhoneNumber.h"
#import "Contact.h"

#import "AddContactsViewController.h"

@interface AddGroupViewController ()

@property (nonatomic, strong) AddContactsViewController *addContactsController;

@end

@implementation AddGroupViewController

@synthesize delegate = _delegate;
@synthesize groupNameTextField = _groupNameTextField;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize contactsView = _contactsView;
@synthesize doneButton = _doneButton;

@synthesize addContactsController = _addContactsController;

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
    self.addContactsController = [[AddContactsViewController alloc] init];
    self.addContactsController.managedObjectContext = self.managedObjectContext;
    self.addContactsController.tokenField = [[ContactsTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    self.addContactsController.tokenField.tokenFieldDelegate = self;
    [self.contactsView addSubview:self.addContactsController.view];
    
    self.groupNameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.groupNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setGroupNameTextField:nil];
    [self setView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate addGroupViewControllerDidCancel:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addGroupViewControllerDidCancel:self];
}

#pragma mark - Add contacts view

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAddContacts"]) {
        //[[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - ContactsTokenFieldDelegate

- (void)tokenField:(ContactsTokenField*)tokenField didAddObject:(id)object {
    [self.doneButton setEnabled:[tokenField.tokens count] > 0 && [self.groupNameTextField.text length] > 0];
}

- (void)tokenField:(ContactsTokenField*)tokenField didRemoveObject:(id)object {
    [self.doneButton setEnabled:[tokenField.tokens count] > 0 && [self.groupNameTextField.text length] > 0];
}

#pragma mark - Group name text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.doneButton setEnabled:[self.addContactsController.tokenField.tokens count] > 0 && [self.groupNameTextField.text length] > 0];
}

@end
