//
//  WSTableItemArray.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  与 login 返回数据中的 tb 节点对应
 *  节点中的元素为 WSTableItem
 */

#define TB @"tb"

@interface WSTableItemsArray : NSObject

@property (nonatomic, strong) NSMutableArray *tableItemsArray;

- (id)initWithObject:(id)object;
- (void)initTableItemsWithArray:(NSArray *)array;
-(void)initTableItemsWithFuncsBeanArray:(NSArray*)array;
- (NSArray *)getTableItemWithMc:(NSString *)aMc;
//- (WSAcvtBean *)getAcvtById:(NSString *)anAcvtId;

@end
