//
//  WSSellFloatWindowManager.h
//  
//
//  Created by zzialx on 2022/10/22.
//  Copyright © 2022 zzialx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSellFloatWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSSellFloatWindowManager : NSObject

+ (WSSellFloatWindowManager *)sharedInstance;

+ (void)showSellFloatWindow;

+ (void)hideSellFloatWindow;

+ (BOOL)isShowSellFloatWindowWithRole;

@end

NS_ASSUME_NONNULL_END
