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
#import "GroupUsersListTableViewController.h"

@interface GroupMessagesViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate, GroupUsersListTableViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) Group *group;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) IBOutlet UITableView *messagesTableView;

// Message bar
@property (nonatomic, strong) IBOutlet UIView *messageBarView;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *messagesInputBoxTextView;
@property (nonatomic, strong) IBOutlet UIImageView *messagesInputBoxBackground;
@property (nonatomic, strong) IBOutlet UIImageView *messageBarBackground;

// Board message header
@property (nonatomic, strong) IBOutlet UIView *boardMessageView;
@property (nonatomic, strong) IBOutlet UIImageView *boardMessageBackground;
@property (nonatomic, strong) IBOutlet UITextView *boardMessageTextView;

-(IBAction)sendMessage;

@end
