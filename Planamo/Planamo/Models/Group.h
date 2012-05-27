//
//  Group.h
//  Planamo
//
//  Created by Stanley Tang on 26/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * welcomeMessage;
@property (nonatomic, retain) NSManagedObject *event;
@property (nonatomic, retain) NSSet *groupUserLinks;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addGroupUserLinksObject:(NSManagedObject *)value;
- (void)removeGroupUserLinksObject:(NSManagedObject *)value;
- (void)addGroupUserLinks:(NSSet *)values;
- (void)removeGroupUserLinks:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
