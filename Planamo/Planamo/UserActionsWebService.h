//
//  UserActionsWebService.h
//  Planamo
//
//  Created by Stanley Tang on 05/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface UserActionsWebService : AFHTTPClient

+ (UserActionsWebService *)sharedWebService;

-(void)showAlertWithErrorCode:(int)errorCode;

@end