//
//  AddGroupViewController.h
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsTokenField.h"

@class AddGroupViewController;

@protocol AddGroupViewControllerDelegate
- (void)addGroupViewControllerDidCancel:(AddGroupViewController *)controller;
- (void)addGroupViewControllerDidFinish:(AddGroupViewController *)controller;
@end

@interface AddGroupViewController : UIViewController <UITextFieldDelegate, ContactsTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet id <AddGroupViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIView *contactsView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
