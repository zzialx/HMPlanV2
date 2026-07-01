//
//  WSRootConfigDataProcessService.h
//  WinSFA
//
//  Created by yang on 2017/7/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSRootConfigDataProcessService : NSObject

+ (void)processRootConfigData:(NSDictionary *)dic isRememberBtnSelected:(BOOL)isRememberBtnSelected;

@end
