//
//  AddressBookScanner.m
//  Planamo
//
//  Created by Stanley Tang on 27/04/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "AddressBookScanner.h"
#import "AddressBookContact.h"
#import "PhoneNumber.h"

@implementation AddressBookScanner

/**
 Reformats phone number string such that it contains only integers. Also
 appends USA country code if one does not exist and is 10 digits
 */
+ (NSString *)reformatPhoneNumber:(NSString *)phoneNumber {
    NSMutableString *newPhoneNumber = [[NSMutableString alloc] init];
    
    for (int i=0; i<[phoneNumber length]; i++) {
        if (isdigit([phoneNumber characterAtIndex:i])) {
            [newPhoneNumber appendFormat:@"%c",[phoneNumber characterAtIndex:i]];
        }
    }
    
    // Append USA country code - TODO (if internationalized)
    if ([newPhoneNumber characterAtIndex:0] == '+') {
        //ignore  
    } else if ([newPhoneNumber characterAtIndex:0] == '1' &&
               [newPhoneNumber length] == 11) {
        [newPhoneNumber insertString:@"+" atIndex:0];
    } else if ([newPhoneNumber length] == 10) {
        [newPhoneNumber insertString:@"+1" atIndex:0];
    } else {
        // Invalid USA phone number
        NSLog(@"%@ is an invalid US phone number", phoneNumber);
    }
    
    return [NSString stringWithString:newPhoneNumber];
}

// TODO - ask user permission, sync with server, address book mutliple contact selector
+ (void)scanAddressBookWithManagedContext:(NSManagedObjectContext *)managedObjectContext
{
    // Retrive last the address book was scanned
    NSDate* lastScanned = [[NSUserDefaults standardUserDefaults] objectForKey:@"AddressBookLastScannedDate"];

    // Get address book and store into array
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
    if (!allPeople || !nPeople || nPeople == 0)
    {
        NSLog(@"NO ADDRESS BOOK ENTRIES TO SCAN");
        CFRelease(addressBook);
        CFRelease(allPeople);
        return;
    }
    
    // Iterate through address book list
    NSUInteger i;
    for (i=0; i < nPeople; i++ )
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        if (!person) continue;
        
        // Last time the contact was modified
        if (lastScanned) {
            CFDateRef modifyDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
            // If last scanned date is after modified date, (i.e. continue)
            if ([lastScanned compare:(__bridge NSDate*)modifyDate] == NSOrderedDescending) {
                CFRelease(modifyDate);
                continue;
            } else {
                CFRelease(modifyDate);
            }
        } 
        
        // Make sure it is a contact with first and last names, otherwise, ignore
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);  
        if (!firstName || !lastName) {
            CFRelease(person);
            continue;
        }
        
        // Get contact's address book ID
        NSNumber *addressBookID = [NSNumber numberWithInt:ABRecordGetRecordID(person)]; 
        
        // Find if duplicate contact exists in Core Data
        AddressBookContact *contact = nil;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AddressBookContact"];
        request.predicate = [NSPredicate predicateWithFormat:@"addressBookID = %@", addressBookID];
        
        NSError *error = nil;
        NSArray *contacts = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (!contacts || ([contacts count] > 1)) {
            NSLog(@"Error feteching contacts from core data when scanning addres book");
        } else if (![contacts count]) {
            contact = [NSEntityDescription insertNewObjectForEntityForName:@"AddressBookContact" inManagedObjectContext:managedObjectContext];
            contact.addressBookID = addressBookID;
        } else {
            contact = [contacts lastObject];
        }
        
        // Update name
        contact.firstName = firstName;
        contact.lastName = lastName;
        
        // Delete existing phone numbers
        for (PhoneNumber *number in contact.phoneNumbers) {
            [managedObjectContext deleteObject:number];
        }
        
        // Add new phone numbers
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
        NSUInteger k;
        for (k=0; k < phoneNumberCount; k++)
        {
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, k);
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex(phoneNumbers, k);
            CFStringRef phoneNumberLocalizedLabel = ABAddressBookCopyLocalizedLabel(phoneNumberLabel);    // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
            
            //Save phone number
            PhoneNumber *phoneNumber = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber" inManagedObjectContext:managedObjectContext];
            phoneNumber.numberAsStringWithFormat = (__bridge NSString *)phoneNumberValue;
            phoneNumber.numberAsStringWithoutFormat = [self reformatPhoneNumber:(__bridge NSString *)phoneNumberValue];
            phoneNumber.type = (__bridge NSString *)phoneNumberLocalizedLabel;
            phoneNumber.owner = contact;
            
            NSLog(@"Address Book Phone Entry -> %@ %@ (%@): %@ (format number), %@ (raw number)", contact.firstName, contact.lastName, phoneNumberLocalizedLabel, phoneNumberValue, phoneNumber.numberAsStringWithoutFormat);
            
            CFRelease(phoneNumberLocalizedLabel);
            CFRelease(phoneNumberLabel);
            CFRelease(phoneNumberValue);
        }
        CFRelease(phoneNumbers);
        CFRelease(person);
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"AddressBookLastScannedDate"];
    
    CFRelease(allPeople);
}

@end
