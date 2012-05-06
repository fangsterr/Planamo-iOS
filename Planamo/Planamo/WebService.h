//
//  WebService.h
//  Planamo
//
//  Created by Stanley Tang on 01/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

@protocol WebServiceDelegate;

@interface WebService : NSObject

@property (nonatomic, weak) id <WebServiceDelegate> delegate;

// Calls to server
-(void)createNewMobileUserWithPhoneNumber:(NSString *)rawPhoneNumber;
-(void)verifyNewMobileUserWithPhoneNumber:(NSString *)rawPhoneNumber pinNumber:(NSString *)pinNumber andDeviceInfo:(NSDictionary *)deviceInfo;

-(void)loginMobile;

@end

@protocol WebServiceDelegate <NSObject>
-(void)webService:(WebService *)webService didFailWithError:(NSError *)error;

@optional
-(void)createNewMobileUserCallbackReturn:(NSDictionary *)responseDictionary;
-(void)verifyNewMobileUserCallbackReturn:(NSDictionary *)responseDictionary;

@end
