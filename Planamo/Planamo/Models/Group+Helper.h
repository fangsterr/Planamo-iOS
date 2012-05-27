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
 Import groups expects array of dictionary (group JSON object)
 */
+ (void)updateOrCreateOrDeleteGroupsFromArray:(NSArray *)importGroups inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;


/* Creates new group from dictionary (group JSON object) */
+ (void)createNewGroupFromDictionary:(NSDictionary *)groupDictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*
 Find (and update) or create or delete users for group in core data, based on import users from server
 Import users expects array of dictionary (user JSON object)
 */
+ (void)updateOrCreateOrDeleteUsersInGroupFromArray:(NSArray *)importUsers forGroup:(Group *)group onlyUpdate:(BOOL)onlyUpdate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
