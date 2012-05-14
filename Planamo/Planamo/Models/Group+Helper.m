//
//  Group+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "Group+Helper.h"
#import "PlanamoUser+Helper.h"
#import "GroupUserLink+Helper.h"
#import "AddressBookScanner.h"

@implementation Group (Helper)

+ (void)updateOrCreateOrDeleteGroupsFromArray:(NSArray *)importGroups withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *error = nil;
    NSDate *dateStartUpdating = [NSDate date];
    
    for (NSDictionary *anImportGroup in importGroups) {        
        // Find or create new group
        Group *currentGroup = nil;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        request.predicate = [NSPredicate predicateWithFormat:@"id = %@", [anImportGroup valueForKey:@"id"]];        
        NSArray *groupArray = [managedObjectContext executeFetchRequest:request error:&error];
        
        // If group doesn't exist, create
        if (![groupArray count]) {
            [Group createNewGroupFromDictionary:anImportGroup withManagedObjectContext:managedObjectContext];
        
        // If group exists, update
        } else { 
            currentGroup = [groupArray lastObject];
            currentGroup.name = [anImportGroup valueForKey:@"name"];
            currentGroup.twilioNumberForUser = [AddressBookScanner reformatPhoneNumber:[anImportGroup valueForKey:@"twilioNumberForUser"]];
            currentGroup.welcomeMessage = [anImportGroup valueForKey:@"welcomeMessage"];
            [Group updateOrCreateOrDeleteUsersInGroupFromArray:[anImportGroup valueForKey:@"usersInGroup"] forGroup:currentGroup withManagedObjectContext:managedObjectContext];
            currentGroup.lastUpdated = [NSDate date];
        }
    }
    
    // Delete groups that were not updated
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastUpdated < %@", dateStartUpdating];
    NSArray *groupArray = [managedObjectContext executeFetchRequest:request error:&error];
    for (Group *group in groupArray) {
        [managedObjectContext deleteObject:group];
    }
    
    // Save
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
}

+ (void)createNewGroupFromDictionary:(NSDictionary *)groupDictionary withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    // Get users array
    NSArray *usersInGroupArray = [groupDictionary valueForKey:@"usersInGroup"];
    
    // Create group
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:managedObjectContext];
    group.name = [groupDictionary valueForKey:@"name"];
    group.id = [NSNumber numberWithInt:[[groupDictionary valueForKey:@"id"] intValue]];
    group.lastUpdated = [NSDate date];
    group.twilioNumberForUser = [groupDictionary valueForKey:@"twilioNumberForUser"];
    group.welcomeMessage = [groupDictionary valueForKey:@"welcomeMessage"];
    
    // Create users + links
    for (NSDictionary *anUserInGroup in usersInGroupArray) {
        NSDictionary *userInfo = [anUserInGroup valueForKey:@"user"];        
        NSString *firstName = [userInfo valueForKey:@"firstName"];
        NSString *lastName = [userInfo valueForKey:@"lastName"];
        NSString *phoneNumber = [userInfo valueForKey:@"phoneNumber"];
        BOOL isOrganizer = (BOOL)[anUserInGroup valueForKey:@"isOrganizer"];
        
        // Find or create planamo user
        PlanamoUser *user = [PlanamoUser findOrCreateUserWithPhoneNumber:phoneNumber withManagedObjectContext:managedObjectContext];
        if (!user.firstName) user.firstName = firstName;
        if (!user.lastName) user.lastName = lastName;
        
        // Create group-user link
        GroupUserLink *groupUserLink = [GroupUserLink findOrCreateGroupUserLinkForUser:user andGroup:group withManagedObjectContext:managedObjectContext];
        groupUserLink.isOrganizer = [NSNumber numberWithBool:isOrganizer];
    }
    
    // Save
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }

}

+ (void)updateOrCreateOrDeleteUsersInGroupFromArray:(NSArray *)importUsers forGroup:(Group *)group withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *error = nil;
    NSDate *dateStartUpdating = [NSDate date];
    
    for (NSDictionary *anUserInGroup in importUsers) {
        // Get user 
        NSDictionary *userInfo = [anUserInGroup valueForKey:@"user"];        
        NSString *firstName = [userInfo valueForKey:@"firstName"];
        NSString *lastName = [userInfo valueForKey:@"lastName"];
        NSString *phoneNumber = [userInfo valueForKey:@"phoneNumber"];
        BOOL isOrganizer = (BOOL)[anUserInGroup valueForKey:@"isOrganizer"];
        
        // Find or create planamo user
        PlanamoUser *user = [PlanamoUser findOrCreateUserWithPhoneNumber:phoneNumber withManagedObjectContext:managedObjectContext];
        
        // Update planamo user
        user.firstName = firstName;
        user.lastName = lastName;
        
        // Find or create group user link
        GroupUserLink *groupUserLink = [GroupUserLink findOrCreateGroupUserLinkForUser:user andGroup:group withManagedObjectContext:managedObjectContext];
        
        // Update group user link
        groupUserLink.isOrganizer = [NSNumber numberWithBool:isOrganizer];
        groupUserLink.lastUpdated = [NSDate date];
    }
    
    // Delete group user links that were not updated
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GroupUserLink"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastUpdated < %@", dateStartUpdating];
    NSArray *groupUserLinkArray = [managedObjectContext executeFetchRequest:request error:&error];
    for (GroupUserLink *groupUserLink in groupUserLinkArray) {
        [managedObjectContext deleteObject:groupUserLink];
    }
    
    // Save
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
}

@end
