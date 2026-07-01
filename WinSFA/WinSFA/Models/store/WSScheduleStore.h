//
//  WSScheduleStore.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-5-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSScheduleStore : NSObject<NSCoding>

@property (nonatomic, strong) NSDate            *date;
@property (nonatomic, strong) NSMutableArray    *ids;       //WSStoreBean id

@end
