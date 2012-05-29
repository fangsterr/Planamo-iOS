//
//  GroupMessagesViewController.m
//  Planamo
//
//  Created by Stanley Tang on 24/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupMessagesViewController.h"
#import "GroupMessagesTableViewCell.h"
#import "PlanamoUser.h"
#import "Message.h"
#import "GroupUsersListTableViewController.h"

@implementation GroupMessagesViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize messagesTableView, sendButton, messagesInputBoxTextView, messageBarView;
@synthesize messageBarBackground, messagesInputBoxBackground;
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

-(IBAction)sendMessage {
    
}

#pragma mark - Server Calls

-(void)fetchMessagesFromServer {
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    self.messagesTableView = nil;
    self.sendButton = nil;
    self.group = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
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

- (NSFetchedResultsController *)fetchedResultsController
{
    NSFetchedResultsController *aFetchedResultsController = _fetchedResultsController;
    if (!aFetchedResultsController) {
        
        // Create and configure fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group.id = %@", self.group.id];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];

        // Create and initialize fech results controller
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"message"]; // TODO - cache

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

#pragma mark - View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"groupUsersList"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        GroupUsersListTableViewController *groupUsersController = (GroupUsersListTableViewController *)navController.topViewController;
        groupUsersController.group = self.group;
        groupUsersController.managedObjectContext = self.managedObjectContext;
    }
}


@end
