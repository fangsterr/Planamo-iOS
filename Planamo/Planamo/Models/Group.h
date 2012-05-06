//
//  Group.h
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupUserLink;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * welcomeMessage;
@property (nonatomic, retain) NSSet *users;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addUsersObject:(GroupUserLink *)value;
- (void)removeUsersObject:(GroupUserLink *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
