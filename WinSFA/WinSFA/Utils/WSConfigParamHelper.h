//
//  WSConfigParamHelper.h
//  WinSFA
//
//  Created by yang on 2017/7/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSConfigParamHelper : NSObject

+ (NSString *)getParamByKey:(NSString *)key;

+ (BOOL)getIsCheckLeaveStore;
                             

@end
