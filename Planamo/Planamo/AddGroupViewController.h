//
//  AddGroupViewController.h
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsTokenField.h"

@interface AddGroupViewController : UIViewController <UITextFieldDelegate, ContactsTokenFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIView *contactsView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
