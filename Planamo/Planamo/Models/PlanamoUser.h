//
//  PlanamoUser.h
//  Planamo
//
//  Created by Stanley Tang on 05/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AddressBookContact, GroupUserLink;

@interface PlanamoUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * isLoggedInUser;
@property (nonatomic, retain) AddressBookContact *addressBookContact;
@property (nonatomic, retain) NSSet *groupsBelongedTo;
@end

@interface PlanamoUser (CoreDataGeneratedAccessors)

- (void)addGroupsBelongedToObject:(GroupUserLink *)value;
- (void)removeGroupsBelongedToObject:(GroupUserLink *)value;
- (void)addGroupsBelongedTo:(NSSet *)values;
- (void)removeGroupsBelongedTo:(NSSet *)values;

@end
