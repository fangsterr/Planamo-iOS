//
//  Message.h
//  Planamo
//
//  Created by Stanley Tang on 02/07/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, PlanamoUser;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * datetimeSent;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isNotification;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) PlanamoUser *sender;

@end
