//
//  WSTLAlertManager.h
//  WinSFA
//
//  Created by mwj on 2021/8/10.
//  Copyright © 2021 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSStoreBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSTLAlertManager : NSObject

+ (void)addMapNavigationCustomAlertViewWithStorebean:(WSStoreBean *)storebean;

@end

NS_ASSUME_NONNULL_END
