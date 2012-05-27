//
//  AddressBookContact.h
//  Planamo
//
//  Created by Stanley Tang on 26/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber, PlanamoUser;

@interface AddressBookContact : NSManagedObject

@property (nonatomic, retain) NSNumber * addressBookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *phoneNumbers;
@property (nonatomic, retain) PlanamoUser *planamoUser;
@end

@interface AddressBookContact (CoreDataGeneratedAccessors)

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

@end
