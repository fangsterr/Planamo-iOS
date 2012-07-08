//
//  Message+Helper.h
//  Planamo
//
//  Created by Stanley Tang on 29/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "Message.h"

@interface Message (Helper)

/*
 Find (and update) or create or delete users for group in core data, based on import message from server
 Import users expects array of dictionary (message JSON object)
 */
+ (void)updateOrCreateOrDeleteMessagesFromArray:(NSArray *)importMessages forGroup:(Group *)group;

@end
