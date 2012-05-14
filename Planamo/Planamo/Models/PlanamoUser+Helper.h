//
//  PlanamoUser+Helper.h
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "PlanamoUser.h"

@interface PlanamoUser (Helper)

// Get current logged in user on the phone. If none, return nil
+ (PlanamoUser *)currentLoggedInUserWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// Find or create planamo user. If error, return nil
+ (PlanamoUser *)findOrCreateUserWithPhoneNumber:(NSString *)phoneNumber withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
