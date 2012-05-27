//
//  GroupUsersListTableViewController.h
//  Planamo
//
//  Created by Stanley Tang on 29/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataTableViewController.h"
#import "Group.h"

@interface GroupUsersListTableViewController : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Group *group;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *numUsersLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
