//
//  RootViewController.h
//  Planamo
//
//  Created by Stanley Tang on 23/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsListTableViewController.h"
#import "FeedViewController.h"

@interface RootViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIView *viewControllerView;
@property (nonatomic, strong) IBOutlet UIButton *feedButton;
@property (nonatomic, strong) IBOutlet UIButton *groupsButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) FeedViewController *feedController;
@property (nonatomic, strong) GroupsListTableViewController *groupsListController;

-(IBAction)feedTabButtonPressed:(id)sender;
-(IBAction)groupsTabButtonPressed:(id)sender;

@end
