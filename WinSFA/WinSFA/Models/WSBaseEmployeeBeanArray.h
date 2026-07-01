//
//  WSBaseEmployeeBeanArray.h
//  WinSFA
//
//  Created by winchannel on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#define BASEEMPLOYEE @ "baseemployee"
#import <Foundation/Foundation.h>

@interface WSBaseEmployeeBeanArray : NSObject

@property (nonatomic ,strong) NSMutableArray *baseEmployeeBeanArray;
- (id)initWithObject:(id)object;
@end
