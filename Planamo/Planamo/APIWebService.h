//
//  APIWebService.h
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface APIWebService : AFHTTPClient

+ (APIWebService *)sharedWebService;

-(void)showAlertWithErrorCode:(int)errorCode;

//temp
-(void)authenticateUsername:(NSString*)username andPassword:(NSString *)password;

@end
