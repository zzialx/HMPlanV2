//
//  WSCustomEnterStoreTimeObject.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCustomEnterStoreTimeObject : NSObject

@property (nonatomic, strong) NSString  *empIdStr;              //用户id
@property (nonatomic, strong) NSString  *timeLimitStr;          //时间可选限制（-(负数)代表向前时间范围，（正数)代表向后时间范围）

- (id) initWithDic:(NSDictionary*)dic;

@end
