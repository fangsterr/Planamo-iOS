//
//  EventUserLink.h
//  Planamo
//
//  Created by Stanley Tang on 26/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlanamoUser;

@interface EventUserLink : NSManagedObject

@property (nonatomic, retain) NSNumber * hasRSVPed;
@property (nonatomic, retain) NSManagedObject *event;
@property (nonatomic, retain) PlanamoUser *user;

@end
