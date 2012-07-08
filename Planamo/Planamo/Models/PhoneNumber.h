//
//  PhoneNumber.h
//  Planamo
//
//  Created by Stanley Tang on 02/07/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AddressBookContact;

@interface PhoneNumber : NSManagedObject

@property (nonatomic, retain) NSString * numberAsStringWithFormat;
@property (nonatomic, retain) NSString * numberAsStringWithoutFormat;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) AddressBookContact *owner;

@end
