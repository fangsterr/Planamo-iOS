//
//  GroupMessagesTableViewController.h
//  Planamo
//
//  Created by Stanley Tang on 23/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface GroupMessagesTableViewController : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
