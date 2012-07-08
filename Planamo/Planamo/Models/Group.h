//
//  Group.h
//  Planamo
//
//  Created by Stanley Tang on 02/07/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, PlanamoUser;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * hasEvent;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSDate * eventStartDatetime;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addUsersObject:(PlanamoUser *)value;
- (void)removeUsersObject:(PlanamoUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
