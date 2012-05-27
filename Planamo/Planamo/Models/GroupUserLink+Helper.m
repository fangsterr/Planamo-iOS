//
//  GroupUserLink+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 13/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupUserLink+Helper.h"
#import "PlanamoUser.h"
#import "Group.h"

@implementation GroupUserLink (Helper)

+ (GroupUserLink *)findOrCreateGroupUserLinkForUser:(PlanamoUser *)user andGroup:(Group *)group inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    GroupUserLink *groupUserLink = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GroupUserLink"];
    request.predicate = [NSPredicate predicateWithFormat:@"(group = %@) AND (user = %@)", group, user];
    
    NSError *error = nil;
    NSArray *groupUserLinkArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!groupUserLinkArray || ([groupUserLinkArray count] > 1)) {
        NSLog(@"Error feteching group-user link from core data");
        groupUserLink = nil;
        
    } else if (![groupUserLinkArray count]) {
        groupUserLink = [NSEntityDescription insertNewObjectForEntityForName:@"GroupUserLink" inManagedObjectContext:managedObjectContext];
        groupUserLink.user = user;
        groupUserLink.group = group;
        groupUserLink.lastUpdated = [NSDate date];
    } else {
        groupUserLink = [groupUserLinkArray lastObject];
    }
    
    return groupUserLink;
}

@end
