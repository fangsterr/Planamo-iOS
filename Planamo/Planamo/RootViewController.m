//
//  RootViewController.m
//  Planamo
//
//  Created by Stanley Tang on 23/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "RootViewController.h"
#import "PlanamoUser+Helper.h"

@implementation RootViewController

@synthesize viewControllerView = _viewControllerView;
@synthesize feedButton, groupsButton, addButton;
@synthesize feedController, groupsListController;

#pragma mark - Custom Navigation & Tab Bar

-(IBAction)feedTabButtonPressed:(id)sender {
    // Set feed tab button
    UIImage *feedButtonImage = [UIImage imageNamed:@"feedTabButtonSelected.png"];
    self.feedButton.imageView.image = feedButtonImage;
    [self.feedButton setBackgroundImage:feedButtonImage forState:UIControlStateDisabled];
    self.feedButton.enabled = NO;
    
    // Set groups tab button
    UIImage *groupsButtonImage = [UIImage imageNamed:@"groupsTabButton.png"];
    self.groupsButton.imageView.image = groupsButtonImage;
    [self.groupsButton setBackgroundImage:groupsButtonImage forState:UIControlStateNormal];
    self.groupsButton.enabled = YES;
    
    // Set view controllers
    [self transitionFromViewController:self.groupsListController 
                      toViewController:self.feedController 
                              duration:0   
                               options:UIViewAnimationOptionTransitionNone
                            animations:nil 
                            completion:nil];
    
}

-(IBAction)groupsTabButtonPressed:(id)sender {
    // Set groups tab button
    UIImage *groupsButtonImage = [UIImage imageNamed:@"groupsTabButtonSelected.png"];
    self.groupsButton.imageView.image = groupsButtonImage;
    [self.groupsButton setBackgroundImage:groupsButtonImage forState:UIControlStateDisabled];
    self.groupsButton.enabled = NO;
    
    // Set feed tab button
    UIImage *feedButtonImage = [UIImage imageNamed:@"feedTabButton.png"];
    self.feedButton.imageView.image = feedButtonImage;
    [self.feedButton setBackgroundImage:feedButtonImage forState:UIControlStateNormal];
    self.feedButton.enabled = YES;
    
    // Set view controllers
    [self transitionFromViewController:self.feedController
                      toViewController:self.groupsListController
                              duration:0   
                               options:UIViewAnimationOptionTransitionNone
                            animations:nil 
                            completion:nil];
    
}

-(void)setUpCustomNavigationBar {
    // Set the title view to the Planamo logo
    UIImage* titleImage = [UIImage imageNamed:@"headerLogo.png"];
    UIView* titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,titleImage.size.width, self.navigationController.navigationBar.frame.size.height)];
    UIImageView* titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    [titleView addSubview:titleImageView];
    titleImageView.center = titleView.center;
    self.navigationItem.titleView = titleView;
}

// Set groups list tab as current selected
-(void)selectGroupsListTab {
    [self.viewControllerView addSubview:self.groupsListController.view];
    UIImage *groupsButtonImage = [UIImage imageNamed:@"groupsTabButtonSelected.png"];
    self.groupsButton.imageView.image = groupsButtonImage;
    [self.groupsButton setBackgroundImage:groupsButtonImage forState:UIControlStateDisabled];
    self.groupsButton.enabled = NO;
} 

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // If user is logged in, show launch screen
    if ([PlanamoUser currentLoggedInUser]) {
        [self performSegueWithIdentifier:@"launchScreen" sender:self];
    } else {
        // If user is not logged in, show sign up screen
        [self performSegueWithIdentifier:@"signUpProcess" sender:self];
    }
    
    // Create child view controllers
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.groupsListController = [storyboard instantiateViewControllerWithIdentifier:@"GroupsListTableViewController"];
    [self addChildViewController:self.groupsListController];
    self.feedController = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self addChildViewController:self.feedController];
    
    // Display groups list view
    [self selectGroupsListTab];
    
    // Set custom navigation bar
    [self setUpCustomNavigationBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.viewControllerView = nil;
    self.feedButton = nil;
    self.groupsButton = nil;
    self.addButton = nil;
    self.feedController = nil;
    self.groupsListController = nil;
}


@end
