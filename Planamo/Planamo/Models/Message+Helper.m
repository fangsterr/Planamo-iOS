//
//  Message+Helper.m
//  Planamo
//
//  Created by Stanley Tang on 29/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "Message+Helper.h"
#import "Group.h"
#import "PlanamoUser+Helper.h"

@implementation Message (Helper)


+ (void)updateOrCreateOrDeleteMessagesFromArray:(NSArray *)importMessages forGroup:(Group *)group {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];    
    
    // Delete all messages
    for (Message* message in group.messages) {
        [message MR_deleteInContext:localContext];
    }
    
    // Add new messages
    for (NSDictionary *messageData in importMessages) {        
        // Get JSON data
        NSNumber *messageID = [NSNumber numberWithInt:[[messageData valueForKey:@"id"] intValue]];
        NSString *messageText = [messageData valueForKey:@"messageText"];
        NSDictionary *senderData = [messageData valueForKey:@"sender"];
        BOOL isNotification = [(NSNumber *)[messageData valueForKey:@"isNotification"] boolValue];
        double dateTimeSent = [[messageData valueForKey:@"datetimeSent"] doubleValue];
        
        // Create message - TODO own function
        Message *newMessage = [Message MR_createInContext:localContext];
        newMessage.id = messageID;
        newMessage.messageText = messageText;
        
        if (senderData) {
            newMessage.sender = [PlanamoUser findOrCreateUserWithPhoneNumber:[senderData valueForKey:@"phoneNumber"]];
            newMessage.sender.firstName = [senderData valueForKey:@"firstName"];
            newMessage.sender.lastName = [senderData valueForKey:@"lastName"];
        }
        newMessage.isNotification = [NSNumber numberWithBool:isNotification];
        newMessage.datetimeSent = [NSDate dateWithTimeIntervalSince1970:dateTimeSent];
        newMessage.group = group;
    }
    
    // TODO - support paging. Better syncing solution
}

@end
