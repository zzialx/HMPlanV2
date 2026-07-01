//
//  WSMjetLoginManager.h
//  WinSFA
//
//  Created by Stephanie on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSMjetLoginManagerDelegate <NSObject>

- (void)mjetLoginSuccess:(NSDictionary *)dictionary;
- (void)mjetLoginFailed:(NSDictionary *)dictionary;

- (void)getSSOSessionSuccess:(NSDictionary *)dictionary;
- (void)getSSOSessionFailed:(NSDictionary *)dictionary;

@end

@interface WSMjetLoginManager : NSObject

@property (nonatomic, strong) NSArray *allMjetCookies;

@property (nonatomic, weak) id<WSMjetLoginManagerDelegate> delegate;

+ (WSMjetLoginManager *)sharedInstance;

+ (BOOL)isNeedMejtLogin;

+ (BOOL)isNeedGetSSOSession;

- (void)setUpUsername:(NSString *)username password:(NSString *)password;

- (void)mjetLogin;

- (BOOL)mjetLogout;

- (void)getSSOSessionForUrl:(NSString *)urlString;

@end
