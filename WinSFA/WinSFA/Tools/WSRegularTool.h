//
//  WSRegularTool.h
//  WinSFA
//
//  Created by lishuli on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSRegularTool : NSObject

//SFA-24175 订单添加产品搜索—模糊搜索功能需求
- (NSString *)getFactorArrayWithInputString:(NSString *)inpuStr;

@end
