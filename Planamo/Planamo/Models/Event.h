//
//  Event.h
//  Planamo
//
//  Created by Stanley Tang on 26/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventUserLink, Group, PlanamoUser;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDatetime;
@property (nonatomic, retain) PlanamoUser *creator;
@property (nonatomic, retain) NSSet *eventUserLinks;
@property (nonatomic, retain) Group *group;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addEventUserLinksObject:(EventUserLink *)value;
- (void)removeEventUserLinksObject:(EventUserLink *)value;
- (void)addEventUserLinks:(NSSet *)values;
- (void)removeEventUserLinks:(NSSet *)values;

@end
