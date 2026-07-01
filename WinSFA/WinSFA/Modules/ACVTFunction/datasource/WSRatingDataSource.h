//
//  WSRatingDataSource.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DataSource.h"

@interface WSRatingDataSource : NSObject<I_W_DataSource>

@property (nonatomic, strong) NSArray *dataSourceArray;

@end
