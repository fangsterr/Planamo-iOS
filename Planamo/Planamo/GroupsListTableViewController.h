//
//  GroupsListTableViewController.h
//  Planamo
//
//  Created by Stanley Tang on 26/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataTableViewController.h"
#import "AddGroupViewController.h"

@interface GroupsListTableViewController : CoreDataTableViewController <AddGroupViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

//temp
-(IBAction)refresh:(id)sender;

@end
