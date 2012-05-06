//
//  GroupUserLink.h
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, PlanamoUser;

@interface GroupUserLink : NSManagedObject

@property (nonatomic, retain) NSNumber * isOrganizer;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) PlanamoUser *user;

@end
