//
//  EnterPhoneNumberViewController.h
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneNumberFormatter.h"

@interface EnterPhoneNumberViewController : UIViewController {
    @private
        int _textFieldSemaphore;
        PhoneNumberFormatter *_phoneNumberFormatter;
        NSString *_rawPhoneNumber;
}

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)continue:(id)sender;

@end
