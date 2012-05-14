//
//  UserActionsWebService.m
//  Planamo
//
//  Created by Stanley Tang on 05/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "UserActionsWebService.h"
#import "AFJSONRequestOperation.h"

static NSString * const kUserActionsBaseURLString = @"https://sharp-fire-8026.herokuapp.com/accounts/";
//static NSString * const kUserActionsBaseURLString = @"http://localhost:8000/accounts/";
#define kSecretCode                 @"j0d1eCHILLBE4R"

@implementation UserActionsWebService

+ (UserActionsWebService *)sharedWebService {
    static UserActionsWebService * _sharedWebService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebService = [[UserActionsWebService alloc] initWithBaseURL:[NSURL URLWithString:kUserActionsBaseURLString]];
    });
    
    return _sharedWebService;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    return self;
}


#pragma mark - Error code

-(void)showAlertWithErrorCode:(int)errorCode
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    if (errorCode == 11) {
        alert = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" 
                                           message:@"Sorry! Please enter your PIN again." 
                                          delegate:nil 
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Sorry! Unable to connect to server. Try again" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    }
    [alert show];
}

@end