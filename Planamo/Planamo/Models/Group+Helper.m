//
//  Group+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "Group+Helper.h"
#import "PlanamoUser+Helper.h"
#import "Message+Helper.h"
#import "AddressBookScanner.h"

@implementation Group (Helper)

+ (void)updateOrCreateOrDeleteGroupsFromArray:(NSArray *)importGroups {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSDate *dateStartUpdating = [NSDate date];
    
    for (NSDictionary *anImportGroup in importGroups) {     
        Group *group = [Group MR_importFromObject:anImportGroup inContext:localContext];
        group.lastUpdated = [NSDate date];
    }
    
    // Delete groups that were not updated
    NSArray *groupArray = [Group MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"lastUpdated < %@", dateStartUpdating] inContext:localContext];
    for (Group *group in groupArray) {
        [group MR_deleteInContext:localContext];
    }
}

- (void)addUsersToGroup:(NSArray *)importUsers {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];    
    
    for (NSDictionary *user in importUsers) {
        // Find or create planamo user
        PlanamoUser *user = [PlanamoUser MR_importFromObject:user inContext:localContext];
        
        // Add user to group
        [user addGroupsObject:self];
    }
}

- (void)willImport:(id)data {
    [self removeUsers:self.users];
}

- (BOOL)importId:(id)data {
    self.id = [NSNumber numberWithInt:[data intValue]];
    return YES;
}

- (BOOL)importMessages:(id)data {
    [Message updateOrCreateOrDeleteMessagesFromArray:[data valueForKeyPath:@"messages"] forGroup:self];
    return YES;
}

@end
