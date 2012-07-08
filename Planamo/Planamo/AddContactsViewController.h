//
//  AddContactsViewController.h
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsTokenField.h"
#import "Group.h"

@interface AddContactsViewController : UIViewController

@property (nonatomic, strong) ContactsTokenField *tokenField;
@property (nonatomic, strong) Group *group;

-(IBAction)done;
-(IBAction)cancel;
- (NSMutableArray *)convertUserTokensIntoUsersArray;

@end
