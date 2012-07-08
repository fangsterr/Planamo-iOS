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
+ (void)updateOrCreateOrDeleteGroupsFromArray:(NSArray *)importGroups;

/*
 Add new users to group. Import users expects array of dictionary (user JSON object)
 */
- (void)addUsersToGroup:(NSArray *)importUsers;

// Override magical records import
- (void)willImport:(id)data;
- (BOOL)importId:(id)data;
- (BOOL)importMessages:(id)data;

@end
