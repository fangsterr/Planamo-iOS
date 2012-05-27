//
//  PlanamoUser.h
//  Planamo
//
//  Created by Stanley Tang on 26/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AddressBookContact, EventUserLink;

@interface PlanamoUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isLoggedInUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) AddressBookContact *addressBookContact;
@property (nonatomic, retain) NSSet *eventUserLinks;
@property (nonatomic, retain) NSSet *groupUserLinks;
@end

@interface PlanamoUser (CoreDataGeneratedAccessors)

- (void)addEventUserLinksObject:(EventUserLink *)value;
- (void)removeEventUserLinksObject:(EventUserLink *)value;
- (void)addEventUserLinks:(NSSet *)values;
- (void)removeEventUserLinks:(NSSet *)values;

- (void)addGroupUserLinksObject:(NSManagedObject *)value;
- (void)removeGroupUserLinksObject:(NSManagedObject *)value;
- (void)addGroupUserLinks:(NSSet *)values;
- (void)removeGroupUserLinks:(NSSet *)values;

@end
