//
//  Group+Helper.h
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "Group.h"

@interface Group (Helper)

/*
 Find (and update) or create or delete groups in core data, based on import groups from server
 
 Import groups expects array of dictionary in format like (in order of group id):
    [{
        id = 5, 
        name = "New group", 
        twilioNumberForUser = "+14155992671", 
        usersInGroup = {
            user = {
                firstName = "Stanley",
                lastName = "Tang",
                id = 5,
                phoneNumber = "+16503916950"
            },
            isOrganizer = YES
        },
        welcomeMessage = "welcome to the group"
    },
    etc
 ]
 */
+ (void)updateOrCreateOrDeleteGroupsFromArray:(NSArray *)importGroups withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;


/* Creates new group from dictionary, like the format specified in the comments for updateOrCreateOrDeleteGroupsFromArray:withmanagedObjectContext*/
+ (void)createNewGroupFromDictionary:(NSDictionary *)groupDictionary withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*
 Find (and update) or create or delete users in core data, based on import users from server
 
 Import users expects array of dictionary in format like:
 
 [
    {
    isOrganizer = True;
    user = {
        firstName = Andy;
        lastName = Fang;
        phoneNumber = "+14082216266";
    },
    etc
 ]
 */
+ (void)updateOrCreateOrDeleteUsersInGroupFromArray:(NSArray *)importUsers forGroup:(Group *)group withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
