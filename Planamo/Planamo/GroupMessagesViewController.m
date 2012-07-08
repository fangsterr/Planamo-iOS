//
//  GroupMessagesViewController.m
//  Planamo
//
//  Created by Stanley Tang on 24/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupMessagesViewController.h"
#import "GroupMessagesTableViewCell.h"
#import "PlanamoUser+Helper.h"
#import "Message+Helper.h"
#import "WebService.h"

@implementation GroupMessagesViewController {
    int _messageIsForEvent;
    BOOL _beginUpdates;
    BOOL _pauseTrackingChanges;
    NSTimer *_messageFetcher;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize messagesTableView, sendButton, messagesInputBoxTextView, messageBarView, eventIconButton;
@synthesize messageBarBackground, messagesInputBoxBackground;
@synthesize eventDetailsHeader, eventNameLabel, deleteEventButton;
@synthesize group = _group;


#pragma mark - Message Bar

-(void)hideKeyboard {
    [self.messagesInputBoxTextView.internalTextView resignFirstResponder];
}

-(void)createMessageBarView {
    // Message input text box
    self.messagesInputBoxTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 15);
    self.messagesInputBoxTextView.minNumberOfLines = 1;
	self.messagesInputBoxTextView.maxNumberOfLines = 4;
	self.messagesInputBoxTextView.returnKeyType = UIReturnKeyGo; //just as an example
	self.messagesInputBoxTextView.font = [UIFont systemFontOfSize:14.0f];
	self.messagesInputBoxTextView.delegate = self;
    self.messagesInputBoxTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.messagesInputBoxTextView.backgroundColor = [UIColor whiteColor];
    self.messagesInputBoxTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Message input box background
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    self.messagesInputBoxBackground.image = entryBackground;
    self.messagesInputBoxBackground.frame = CGRectMake(5, 0, 248, 40); // TODO - put this in storyboard
    self.messagesInputBoxBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    // Message bar background
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    self.messageBarBackground.image = background;
    self.messageBarBackground.frame = CGRectMake(0, 0, self.messageBarView.frame.size.width, self.messageBarView.frame.size.height); 
    self.messageBarBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Send button
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.sendButton setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    
    self.messageBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    // TODO - event icon button
    
    // Tap to remove keyboard gesture
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.messagesTableView addGestureRecognizer:gestureRecognizer];
}

- (void)resetSendButton {
    sendButton.enabled = NO;
    sendButton.titleLabel.alpha = 0.5f;
}

- (void)enableSendButton {
    if (sendButton.enabled == NO) {
        sendButton.enabled = YES;
        sendButton.titleLabel.alpha = 1.0f;
    }
}

- (void)disableSendButton {
    if (sendButton.enabled == YES) {
        [self resetSendButton];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger bottomRow = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.messagesTableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void) keyboardWillShow:(NSNotification *)note{
    if (self.group.hasEvent) {
        //TODO clean up - event detail header
        CGRect r = self.eventDetailsHeader.frame;
        r.origin.y = -r.size.height;
        self.eventDetailsHeader.frame = r;
        
        CGRect table = self.messagesTableView.frame;
        table.origin.y = 0;
        CGRect containerFrame = self.messageBarView.frame;
        table.size.height = self.view.bounds.size.height - containerFrame.size.height;
        self.messagesTableView.frame = table;
    }
    
    
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.messageBarView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    // get a rect for the messageTableView frame
    CGRect tableFrame = self.messagesTableView.frame;
    tableFrame.size.height = self.messagesTableView.bounds.size.height - (keyboardBounds.size.height);
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.messageBarView.frame = containerFrame;
    self.messagesTableView.frame = tableFrame;
    
	// commit animations
	[UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.messageBarView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // get a rect for the messageTableView frame
    CGRect tableFrame = self.messagesTableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - containerFrame.size.height;
    	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.messageBarView.frame = containerFrame;
    self.messagesTableView.frame = tableFrame;
    
    
    if (self.group.hasEvent) {
    //TODO clean up - event detail header
    CGRect r = self.eventDetailsHeader.frame;
    r.origin.y = 0;
    self.eventDetailsHeader.frame = r;
    CGRect table = self.messagesTableView.frame;
    table.origin.y = r.size.height;
    table.size.height -= r.size.height;
    self.messagesTableView.frame = table;
    }
    
	
	// commit animations
	[UIView commitAnimations];
        
    [self scrollToBottomAnimated:YES];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    // Change message bar height
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.messageBarView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.messageBarView.frame = r;
    
    // Change table view height
    CGRect tbr = self.messagesTableView.frame;
    tbr.size.height += diff;
	self.messagesTableView.frame = tbr;
    
    [self scrollToBottomAnimated:YES];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    if (growingTextView.text.length > 0) {
        [self enableSendButton];
    } else {
        [self disableSendButton];
    }
}

-(IBAction)switchEventIcon {
    if (_messageIsForEvent == 0) {
        UIImage *calendarColorIcon = [UIImage imageNamed:@"CalendarColorIcon.png"];
        [self.eventIconButton setBackgroundImage:calendarColorIcon forState:UIControlStateNormal];
        [self.eventIconButton setBackgroundImage:calendarColorIcon forState:UIControlStateSelected];
        
        _messageIsForEvent = 1;
    } else {
        UIImage *calendarGreyIcon = [UIImage imageNamed:@"CalendarGreyIcon.png"];
        [self.eventIconButton setBackgroundImage:calendarGreyIcon forState:UIControlStateNormal];
        [self.eventIconButton setBackgroundImage:calendarGreyIcon forState:UIControlStateSelected];
        
        _messageIsForEvent = 0;
    }
}

#pragma mark - Event details Header

-(void)createEventDetailsHeader {
    // TODO - clean this code up
    
    if (self.group.hasEvent) {
        CGRect r = self.eventDetailsHeader.frame;
        r.origin.y = 0;
        self.eventDetailsHeader.frame = r;
        
        CGRect table = self.messagesTableView.frame;
        table.origin.y = r.size.height;
        table.size.height -= r.size.height;
        self.messagesTableView.frame = table;
        
        self.eventNameLabel.text = self.group.eventName;
        
    } else {
        CGRect r = self.eventDetailsHeader.frame;
        r.origin.y = -r.size.height;
        self.eventDetailsHeader.frame = r;
        
        CGRect table = self.messagesTableView.frame;
        table.origin.y = 0;
        CGRect containerFrame = self.messageBarView.frame;
        table.size.height = self.view.bounds.size.height - containerFrame.size.height;
        self.messagesTableView.frame = table;
    }
}

#pragma mark - Server Calls

#import "MBProgressHUD.h"

-(IBAction)sendMessage {
    // TODO - abstract
    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.messagesInputBoxTextView.text, @"messageText", nil];
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:messageDictionary, @"message", self.group.id, @"groupID", nil];
    
    NSString *functionName = @"messages/sendMessageFromiOS/";
    
    NSLog(@"Calling - %@, jsonData: %@", functionName, dataDictionary);
    
    [[WebService sharedWebService] postPath:functionName parameters:dataDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"POST %@ - return: %@", functionName, JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // TODO - create nsobject, then remove (or try again sign) if unsuccessful (feels faster)
        
        // If good, next
        if (code == 0) {
            // add data
            Message *newMessage = [Message MR_createEntity];
            newMessage.id = [JSON valueForKeyPath:@"messageID"];
            newMessage.isNotification = [NSNumber numberWithBool:NO];
            newMessage.messageText = self.messagesInputBoxTextView.text;
            newMessage.group = self.group;
            newMessage.sender = [PlanamoUser currentLoggedInUser];
            newMessage.datetimeSent = [NSDate date];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            
            //[self.messagesTableView reloadData];
                        
            self.messagesInputBoxTextView.text = @"";
            
            [self scrollToBottomAnimated:YES];

            
            // TODO - event. Abstract code
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        NSLog(@"Error: %@", error);
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];        
    }];
    
    // Add progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending...";
}

-(void)fetchMessagesFromServer {
    NSString *functionName = [NSString stringWithFormat:@"api/group/%@/messages", self.group.id];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"-id", @"order_by", nil];
    
    NSLog(@"Calling GET %@, param %@", functionName, param);
    
    [[WebService sharedWebService] getPath:functionName parameters:param success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"GET %@ - return: %@", functionName, JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
        
        // If good, next
        if (code == 0) {
            
            _pauseTrackingChanges = YES;
            
            [Message updateOrCreateOrDeleteMessagesFromArray:[JSON valueForKeyPath:@"objects"] forGroup:self.group];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
                                    
            _pauseTrackingChanges = NO;
            
            [self.messagesTableView reloadData];
                                    
            [self scrollToBottomAnimated:NO];
                        
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];        
    }];

}

-(IBAction)deleteEvent {
    NSString *functionName = [NSString stringWithFormat:@"api/group/%@/event/", self.group.id];
    
    NSLog(@"Calling DELETE %@", functionName);
    
    [[WebService sharedWebService] deletePath:functionName parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"DELETE %@ - return: %@", functionName, JSON);
        
        NSString *jsonCode = [JSON valueForKeyPath:@"code"];
        int code = [jsonCode intValue];
                
        // If good, next
        if (code == 0) {
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            [self createEventDetailsHeader];
                        
        } else {
            // Otherwise, alert error
            [[WebService sharedWebService] showAlertWithErrorCode:code];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[WebService sharedWebService] showAlertWithErrorCode:[error code]];        
    }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.group.name;
    [self createMessageBarView];
            
    // Listen for keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil]; 
    
    [self resetSendButton];
    
    _messageIsForEvent = 0;
    
    [self createEventDetailsHeader];
    
    if (self.group.hasEvent) [self switchEventIcon];
    
    //TODO - figure out how event details header gets displayed
    
    _messageFetcher = [NSTimer scheduledTimerWithTimeInterval:7.0
                                     target:self
                                   selector:@selector(fetchMessagesFromServer)
                                   userInfo:nil
                                    repeats:YES];
    
    
    
    // TODO - fetch messages. Event creation
  /*  CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton* backButton = [customNavigationBar backButtonWith:[UIImage imageNamed:@"navigationBarBackButton.png"] highlight:nil leftCapWidth:14.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [customNavigationBar setText:@"Back" onBackButton:(UIButton*)self.navigationItem.leftBarButtonItem.customView];
   
   HTTP request - lazy loading
   http://www.iphonedevsdk.com/forum/iphone-sdk-development/18876-paging-pagination-load-more-uitableview.html
   */
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_messageFetcher invalidate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
    self.messagesTableView = nil;
    self.sendButton = nil;
    self.group = nil;
    _messageFetcher = nil;
}


#pragma mark - Table View Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupMessagesCell";
    
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    GroupMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GroupMessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure cell
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", message.sender.firstName, message.sender.lastName];
    cell.messageLabel.text = message.messageText;
    cell.dateLabel.text = [GroupMessagesTableViewCell transformedValueForDate:message.datetimeSent];
    
    // Dynamically adjust message label height
    CGRect newFrame = cell.messageLabel.frame;
    newFrame.size.height = [GroupMessagesTableViewCell messageLabelHeightForText:message.messageText];
    cell.messageLabel.frame = newFrame;

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat messageLabelHeight = [GroupMessagesTableViewCell messageLabelHeightForText:message.messageText];
    return messageLabelHeight + 30.0f; // 30 = height of name label + padding 
}

#pragma mark - Fetched Results Controller & Delegate 

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!_pauseTrackingChanges) {
        [self.messagesTableView beginUpdates];
        _beginUpdates = YES;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (_beginUpdates) {
        [self.messagesTableView endUpdates];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSFetchedResultsController *aFetchedResultsController = _fetchedResultsController;
    if (!aFetchedResultsController) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        
        // Create and configure fetch request
        NSFetchRequest *fetchRequest = [Message MR_requestAllSortedBy:@"datetimeSent" 
                                                            ascending:YES 
                                                        withPredicate:[NSPredicate predicateWithFormat:@"group.id = %@", self.group.id]];
     
        // Create and initialize fech results controller
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:localContext sectionNameKeyPath:nil cacheName:nil]; // TODO - cache
        //[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName]; //TODO - if uses cache
        _fetchedResultsController.delegate = self;

        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Messages - performFetch error %@, %@", error, [error userInfo]);
        }
        
        [self.messagesTableView reloadData];
    }
    
    return aFetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{		
    if (!_pauseTrackingChanges) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.messagesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.messagesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.messagesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.messagesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.messagesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

#pragma mark - Group Users List Delegate

-(void)lastUserInGroupDidGetDeleted {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"groupUsersList"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        GroupUsersListTableViewController *groupUsersController = (GroupUsersListTableViewController *)navController.topViewController;
        groupUsersController.group = self.group;
        groupUsersController.delegate = self;
    }
}


@end
