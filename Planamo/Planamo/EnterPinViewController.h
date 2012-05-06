//
//  EnterPinViewController.h
//  Planamo
//
//  Created by Stanley Tang on 04/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface EnterPinViewController : UIViewController <WebServiceDelegate>

@property (nonatomic, strong) NSString *rawPhoneNumber;
@property (strong, nonatomic) IBOutlet UITextField *pinTextField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) WebService *webService;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)continue:(id)sender;

@end
