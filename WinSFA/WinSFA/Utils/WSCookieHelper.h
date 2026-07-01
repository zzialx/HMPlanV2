//
//  WSCookieHelper.h
//  WinSFA
//
//  Created by Stephanie on 16/5/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCookieHelper : NSObject


+ (void)setCookies:(NSArray *)cookies forURLString:(NSString *)urlString;

+ (void)setCookieByName:(NSString *)name value:(NSString *)value url:(NSURL *)url;

+ (void)removeCookieForName:(NSString *)name;

+ (void)removeCookieForName:(NSString *)name url:(NSURL *)url;

+ (NSString *)getCookieValueForName:(NSString *)name url:(NSURL *)url;

@end
