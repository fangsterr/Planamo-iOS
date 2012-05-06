//
//  EnterNameViewController.h
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface EnterNameViewController : UIViewController <WebServiceDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSString *rawPhoneNumber;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(IBAction)done:(id)sender;

@end
