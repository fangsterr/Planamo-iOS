//
//  AddContactsViewController.h
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsTokenField.h"

@interface AddContactsViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ContactsTokenField *tokenField;

@end
