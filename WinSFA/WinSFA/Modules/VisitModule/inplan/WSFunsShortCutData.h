//
//  WSFunsShortCutData.h
//  WinSFA
//
//  Created by winchannel on 15/9/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean.h"
#import "WSFuncsBeanArray.h"

@interface WSFunsShortCutData : NSObject

@property (nonatomic ,strong) NSMutableArray *shortCutArray;
@property (nonatomic ,strong) WSFuncsBean *funcsBean;

- (NSArray *)filterShortCutData:(WSFuncsBean *)funcsBean;



@end
