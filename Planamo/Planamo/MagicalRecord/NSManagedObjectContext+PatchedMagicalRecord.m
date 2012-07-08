//
//  NSManagedObjectContext+PatchedMagicalRecord.m
//  Planamo
//
//  Created by Stanley Tang on 29/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "NSManagedObjectContext+PatchedMagicalRecord.h"

static NSString const * kMagicalRecordManagedObjectContextKey = @"MagicalRecord_NSManagedObjectContextForThreadKey";

@implementation NSManagedObjectContext (PatchedMagicalRecord)

+ (void) MR_setContextForBackgroundThread:(NSManagedObjectContext *)context {
    if ([NSThread isMainThread]) {
        NSLog(@"Cannot set context for main thread using MR_setContextForBackgroundThread");
    } else {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        [threadDict setObject:context forKey:kMagicalRecordManagedObjectContextKey];
    }
}


@end
