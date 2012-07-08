//
//  PlanamoUser.h
//  Planamo
//
//  Created by Stanley Tang on 02/07/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AddressBookContact, Group, Message;

@interface PlanamoUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isLoggedInUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) AddressBookContact *addressBookContact;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *messagesSent;
@end

@interface PlanamoUser (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addMessagesSentObject:(Message *)value;
- (void)removeMessagesSentObject:(Message *)value;
- (void)addMessagesSent:(NSSet *)values;
- (void)removeMessagesSent:(NSSet *)values;

@end
