//
//  GroupUserLink+Helper.h
//  Planamo
//
//  Created by Stanley Tang on 13/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupUserLink.h"

@interface GroupUserLink (Helper)

// Find or create group user link. If error, return nil
+ (GroupUserLink *)findOrCreateGroupUserLinkForUser:(PlanamoUser *)user andGroup:(Group *)group inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
