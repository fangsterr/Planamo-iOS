//
//  PlanamoUser+Helper.h
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "PlanamoUser.h"

@interface PlanamoUser (Helper)

// Get current logged in user on the phone. If error, return nil
+ (PlanamoUser *)currentLoggedInUser;

// Find or create planamo user with phone number (in format +16503916950). If error, return nil
+ (PlanamoUser *)findOrCreateUserWithPhoneNumber:(NSString *)phoneNumber;

// Override magical records import
- (BOOL)importId:(id)data;

@end
