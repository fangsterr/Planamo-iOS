//
//  WebService.h
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface WebService : AFHTTPClient

+ (WebService *)sharedWebService;

// Server calls

// Web service methods
-(void)showAlertWithErrorCode:(int)errorCode;
-(void)authenticateUsername:(NSString*)username andPassword:(NSString *)password;


@end
