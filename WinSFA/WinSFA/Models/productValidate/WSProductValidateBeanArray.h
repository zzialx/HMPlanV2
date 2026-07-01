//
//  WSProductValidateBeanArray.h
//  WinSFA
//
//  Created by yang on 15/11/5.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseBeanArray.h"

@class WSProductValidateBean;

@interface WSProductValidateBeanArray : WSBaseBeanArray

- (NSArray *)getSKUProductArrayByGroupName:(NSString *)groupName;

- (WSProductValidateBean *)getGroupProductByGroupName:(NSString *)groupName;

@end
