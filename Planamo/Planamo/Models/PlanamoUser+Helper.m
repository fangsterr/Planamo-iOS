//
//  PlanamoUser+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "PlanamoUser+Helper.h"

@implementation PlanamoUser (Helper)

+ (PlanamoUser *)currentLoggedInUser {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    return [PlanamoUser MR_findFirstByAttribute:@"isLoggedInUser" withValue:[NSNumber numberWithBool:YES] inContext:localContext];
}

+ (PlanamoUser *)findOrCreateUserWithPhoneNumber:(NSString *)phoneNumber {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PlanamoUser *user = [PlanamoUser MR_findFirstByAttribute:@"phoneNumber" withValue:phoneNumber inContext:localContext];
    if (user) return user;
    
    user = [PlanamoUser MR_createInContext:localContext];
    user.phoneNumber = phoneNumber;
    
    return user;
}

- (BOOL)importId:(id)data {
    self.id = [NSNumber numberWithInt:[data intValue]];
    return YES;
}

@end
