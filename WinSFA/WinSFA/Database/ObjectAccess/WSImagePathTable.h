//
//  WSImagePathTable.h
//  WinSFA
//
//  Created by yang on 13-10-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSImagePathTable : WSSqliteUtil

+ (WSImagePathTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//更新
- (void)updateWithImageIDX:(NSString *)imageIDX withValuesArray:(NSArray *)valuesArray;

//删除
- (void)deleteWithImageIDX:(NSString *)imageIDX;
- (void)deleteWithImageIDX:(NSString *)imageIDX withImgKey:(NSString*)imgKeyStr;

//查询
- (NSArray *)queryWithImageIDX:(NSString *)imageIDX;

//查询图片路径
- (NSString *)backImagePathQueryWithImageIDX:(NSString *)imageIDX;


@end
