//
//  PlanamoUser.h
//  Planamo
//
//  Created by Stanley Tang on 29/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact, GroupUserLink;

@interface PlanamoUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isLoggedInUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSSet *groupsBelongedTo;
@property (nonatomic, retain) Contact *addressBookContact;
@end

@interface PlanamoUser (CoreDataGeneratedAccessors)

- (void)addGroupsBelongedToObject:(GroupUserLink *)value;
- (void)removeGroupsBelongedToObject:(GroupUserLink *)value;
- (void)addGroupsBelongedTo:(NSSet *)values;
- (void)removeGroupsBelongedTo:(NSSet *)values;

@end
