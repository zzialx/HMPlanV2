//
//  WCKeychain.h
//  WinCore
//
//  Created by dujinfeng481 on 14-5-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface WCKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
