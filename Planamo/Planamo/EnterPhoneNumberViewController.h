//
//  EnterPhoneNumberViewController.h
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterPhoneNumberViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;

- (IBAction)continue:(id)sender;

@end
