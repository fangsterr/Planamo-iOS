//
//  EnterPinViewController.h
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanamoUser.h"

@interface EnterPinViewController : UIViewController

@property (nonatomic, strong) PlanamoUser *currentUser;
@property (nonatomic, strong) NSString *rawPhoneNumber;
@property (strong, nonatomic) IBOutlet UITextField *pinTextField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)continue:(id)sender;

@end
