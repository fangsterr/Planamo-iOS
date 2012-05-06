//
//  AddressBookScanner.h
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookScanner : NSObject

// Scans user's address book and stores in Core Data
+ (void)scanAddressBookWithManagedContext:(NSManagedObjectContext *)managedObjectContext;

// Formats phone number string into raw format USA (e.g. 16503916950)
+ (NSString *)reformatPhoneNumber:(NSString *)phoneNumber;

@end
