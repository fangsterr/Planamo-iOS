//
//  WebService.m
//  Planamo
//
//  Created by Stanley Tang on 06/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "WebService.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAPIWebServiceBaseURLString = @"http://sharp-fire-8026.herokuapp.com/"; // TODO - secure
#define kAPIKey         @"j0d1eCHILLBE4R"

@implementation WebService

+ (WebService *)sharedWebService {
    static WebService * _sharedWebService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebService = [[WebService alloc] initWithBaseURL:[NSURL URLWithString:kAPIWebServiceBaseURLString]];
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

#pragma mark - Server Calls


#pragma mark - Web Service Methods

-(void)showAlertWithErrorCode:(int)errorCode
{
    UIAlertView *alert = nil;
    
    if (errorCode == 11) {
        alert = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" 
                                           message:@"Sorry! Please enter your PIN again." 
                                          delegate:nil 
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    } else if (errorCode == 30) {
        alert = [[UIAlertView alloc] initWithTitle:@"Exceeded Max Groups" 
                                           message:@"Sorry! You've reached the maximum number of groups you can create" 
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

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]); 
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

-(void)authenticateUsername:(NSString*)username andPassword:(NSString *)password {
    // Authenticate in HTTPAuthentication
    [self setAuthorizationHeaderWithUsername:username password:password];
    
    // Authenticate in PlanamoAuthentication (sometimes, server cannot read HTTPAuthentication)
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
    [self setDefaultHeader:@"PlanamoAuthentication" value:[NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(basicAuthCredentials)]];
}


@end
