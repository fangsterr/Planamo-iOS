//
//  Contact.h
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * addressBookID;
@property (nonatomic, retain) NSSet *phoneNumber;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addPhoneNumberObject:(PhoneNumber *)value;
- (void)removePhoneNumberObject:(PhoneNumber *)value;
- (void)addPhoneNumber:(NSSet *)values;
- (void)removePhoneNumber:(NSSet *)values;

@end
