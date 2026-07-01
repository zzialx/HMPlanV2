//
//  WSMainLeftViewManager.h
//  WinSFA
//
//  Created by mac on 2017/11/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSMainLeftView.h"
// mainleftView 管理类
@interface WSMainLeftViewManager : NSObject
@property (nonatomic , strong) WSMainLeftView * mainLeftView;

#pragma 辉瑞医院使用
@property (nonatomic , copy) NSString *funcFc ; // 需要跳转的fc-- for SFA-13481 辉瑞医院

+(instancetype)getInstance;
@end
