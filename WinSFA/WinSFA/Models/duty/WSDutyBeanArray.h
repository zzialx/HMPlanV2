//
//  WSDutyBeanArray.h
//  WinSFA
//
//  Created by heju on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSDutyBean.h"

@interface WSDutyBeanArray : NSObject

@property (nonatomic,strong)NSMutableArray *dutyArray;

-(id)initWithObject:(id)object;
@end
