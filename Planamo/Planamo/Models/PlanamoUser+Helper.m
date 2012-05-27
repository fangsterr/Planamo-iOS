//
//  PlanamoUser+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "PlanamoUser+Helper.h"
#import "AddressBookScanner.h"

@implementation PlanamoUser (Helper)

+ (PlanamoUser *)currentLoggedInUserInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    PlanamoUser *loggedInUser = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlanamoUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"isLoggedInUser = %@", [NSNumber numberWithBool:YES]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *loggedInUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!loggedInUserArray || ([loggedInUserArray count] > 1)) {
        // handle error
        NSLog(@"Error fetching logged in user from core data");
        return nil;
    } else if (![loggedInUserArray count]) {
        return nil;
    } else {
        loggedInUser = [loggedInUserArray lastObject];
    }
    
    return loggedInUser;
}

+ (PlanamoUser *)findOrCreateUserWithPhoneNumber:(NSString *)phoneNumber inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    phoneNumber = [AddressBookScanner reformatPhoneNumber:phoneNumber];
    
    PlanamoUser *user = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlanamoUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"phoneNumber = %@", phoneNumber];
    
    NSError *error = nil;
    NSArray *userArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!userArray || ([userArray count] > 1)) {
        NSLog(@"Error feteching planamo user from core data");
        return nil;
    } else if (![userArray count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"PlanamoUser" inManagedObjectContext:managedObjectContext];
        user.phoneNumber = phoneNumber;
    } else {
        user = [userArray lastObject];
    }
    
    return user;
}

@end
