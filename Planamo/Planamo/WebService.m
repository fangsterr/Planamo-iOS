//
//  WebService.m
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "WebService.h"

#import "SBJson.h"

#define kApiBaseUrl     @"http://sharp-fire-8026.herokuapp.com/api/"
#define kRequestTimeout 500
#define kSecretCode     @"j0d1eCHILLBE4R"

@implementation WebService

@synthesize delegate = _delegate;

-(id)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

-(void)loginMobile {
    
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"yo dawg new group name", @"name", nil];
    
    NSString *jsonDataString = [NSString stringWithFormat:@"%@", [phoneNumberDictionary JSONRepresentation], nil];
    
    jsonDataString = @"{\"name\": \"bleh\", \"twilioNumberForUser\": \"+14155992671\", \"usersInGroup\": [{\"firstName\": \"Andy\", \"id\": \"1\", \"lastName\": \"Fang\", \"phoneNumber\": \"+14082216266\"}], \"welcomeMessage\": \"Waddup fools.\"}";
    
    NSData *jsonData = [NSData dataWithBytes:[jsonDataString UTF8String] length:[jsonDataString length]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kApiBaseUrl, @"group/2/"];
    
    NSLog(@"Calling API - groups. jsonDataString: %@, url:%@", jsonDataString, urlString);
    
    ASIHTTPRequest* _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    __weak __block ASIHTTPRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
    //[request addRequestHeader:@"X-HTTP-Method-Override" value:@"PATCH"];
	[request setDelegate:self];
	
    [request setCompletionBlock:^{
        NSLog(@"response string: %@", [request responseString]);
        NSDictionary* responseDictionary = [[request responseString] JSONValue];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(createNewMobileUserCallbackReturn:)]) {
            //  [_delegate createNewMobileUserCallbackReturn:responseDictionary];
        }
        request = nil;
    }];
    
	[request appendPostData:jsonData];
    [request setRequestMethod:@"PUT"];
	[request setTimeOutSeconds:kRequestTimeout];
    
	[request startAsynchronous];
}

-(void)createNewMobileUserWithPhoneNumber:(NSString *)rawPhoneNumber {
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:rawPhoneNumber, @"phoneNumber", kSecretCode, @"secretCode", nil];
    
    NSString *jsonDataString = [NSString stringWithFormat:@"%@", [phoneNumberDictionary JSONRepresentation], nil];
    NSData *jsonData = [NSData dataWithBytes:[jsonDataString UTF8String] length:[jsonDataString length]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kApiBaseUrl, @"accounts/createNewMobileUser/"];
                           
    NSLog(@"Calling API - createNewMobileUser. jsonDataString: %@, url:%@", jsonDataString, urlString);
    
    ASIHTTPRequest* _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    __weak __block ASIHTTPRequest *request = _request;
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	[request setDelegate:self];
	
    [request setCompletionBlock:^{
        NSLog(@"response string: %@", [request responseString]);
        NSDictionary* responseDictionary = [[request responseString] JSONValue];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(createNewMobileUserCallbackReturn:)]) {
            [_delegate createNewMobileUserCallbackReturn:responseDictionary];
        }
        request = nil;
    }];
    
	[request appendPostData:jsonData];
    [request setRequestMethod:@"POST"];
	[request setTimeOutSeconds:kRequestTimeout];
    
	[request startAsynchronous];
}

-(void)verifyNewMobileUserWithPhoneNumber:(NSString *)rawPhoneNumber pinNumber:(NSString *)pinNumber andDeviceInfo:(NSDictionary *)deviceInfo {
    
    NSDictionary *phoneNumberDictionary = [NSDictionary dictionaryWithObjectsAndKeys:rawPhoneNumber, @"phoneNumber", pinNumber, @"pinNumber", deviceInfo, @"deviceInfo", nil];
    
    NSString *jsonDataString = [NSString stringWithFormat:@"%@", [phoneNumberDictionary JSONRepresentation], nil];
    NSData *jsonData = [NSData dataWithBytes:[jsonDataString UTF8String] length:[jsonDataString length]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kApiBaseUrl, @"accounts/verifyNewMobileUser/"];
    
    NSLog(@"Calling API - verifyNewMobileUser. jsonDataString: %@, url:%@", jsonDataString, urlString);
    
    ASIHTTPRequest* _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    __weak __block ASIHTTPRequest *request = _request;
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	[request setDelegate:self];
	
    [request setCompletionBlock:^{
        NSLog(@"response string: %@", [request responseString]);
        NSDictionary* responseDictionary = [[request responseString] JSONValue];
        
        // Store username and password in keychain
        request.username = rawPhoneNumber;
        request.password = [NSString stringWithFormat:@"%@%@", [deviceInfo valueForKey:@"deviceType"], [deviceInfo valueForKey:@"deviceID"]];
        [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
        [request setUseKeychainPersistence:YES];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(verifyNewMobileUserCallbackReturn:)]) {
            [_delegate verifyNewMobileUserCallbackReturn:responseDictionary];
        }
        
        request = nil;
    }];
    
	[request appendPostData:jsonData];
    [request setRequestMethod:@"POST"];
	[request setTimeOutSeconds:kRequestTimeout];
    
	[request startAsynchronous];
}


#pragma mark ASIHTTPRequest standard callback 

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"REQUEST FAILED: %@ %@", request, [request error]);
    if (_delegate != nil && [_delegate respondsToSelector:@selector(webService:didFailWithError:)]) {
        [_delegate webService:self didFailWithError:[request error]];
    }
}

@end


