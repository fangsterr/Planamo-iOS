//
//  GroupMessagesViewController.h
//  Planamo
//
//  Created by Stanley Tang on 24/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HPGrowingTextView.h"

@interface GroupMessagesViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>

@property (nonatomic, strong) Group *group;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) IBOutlet UITableView *messagesTableView;

@property (nonatomic, strong) IBOutlet UIView *messageBarView;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *messagesInputBoxTextView;
@property (nonatomic, strong) IBOutlet UIImageView *messagesInputBoxBackground;
@property (nonatomic, strong) IBOutlet UIImageView *messageBarBackground;

-(IBAction)sendMessage;

@end
