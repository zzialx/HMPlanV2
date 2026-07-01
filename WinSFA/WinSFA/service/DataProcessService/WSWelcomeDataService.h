//
//  WSWelcomeManager.h
//  WinSFA
//
//  Created by Alicia on 2017/10/30.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^WSWelcomeCompleteBlock)(BOOL isSuccess);

@interface WSWelcomeDataService : NSObject

+ (WSWelcomeDataService *)sharedInstance;


- (WSFuncsBean *)getWelcomeFuncsBean;
- (NSString *)getWelcomeUrl;

- (BOOL)hasCacheFileWithUrl:(NSString *)url;
- (void)downloadFileWithUrl:(NSString *)url completeBlock:(WSWelcomeCompleteBlock)completeBlock;

@end
