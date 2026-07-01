//
//  WSBdLocationDataTable.h
//  WinSFA
//
//  Created by Alicia on 2017/8/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBdLocationDataTable : WSSqliteUtil

- (NSArray *)queryWithCurrentEmpId;
- (void)insertWithLocation:(WSLocationDescribe *)locationDescribe withTimeStamp:(NSNumber *)timeStamp withDateTimeString:(NSString *)dateTimeString;

@end
