//
//  NSDate+Additions.h
//  
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (NSString *)getTimeString;

- (NSString *)getTimeStringForComment;

- (NSInteger)compareWithToday;
/*
 *取当前时间的格林威治时间（避免佛教时间等影响）
 */
+ (NSDate *)currentGregorianDate;


- (NSDate *)ws_dateAddingByDay:(NSInteger)day;
- (NSDate *)ws_dateAddingByMonth:(NSInteger)month;
- (NSDate *)ws_dateAddingByYear:(NSInteger)year;

@end
