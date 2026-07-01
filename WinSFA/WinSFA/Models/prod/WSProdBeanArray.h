//
//  ProdBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WinChannelDataArrayParent.h"

@class WSProdBean;

@interface WSProdBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *prodArray;

- (id)initWithObject:(id)object;
- (NSArray *)getProdsWithFilter:(NSString *)filter;
- (WSProdBean *)getProdWithPid:(NSString *)pid;
- (NSArray *)getProdsWithBrandId:(NSString *)aBrandId;
- (NSArray *)getProdsWithBrandType:(NSString *)aBrandType; // 中粮稽核使用
- (NSArray *)getProdsWithBrandId:(NSString *)aBrandId andProductType:(NSString *)aProductType;

/**
 *  分组list模型
 */
@property (nonatomic,copy) NSString *name;

// 二级菜单是否展开
@property (nonatomic, assign, getter=isExpend) BOOL expend;

// 全选按钮状态
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//选中的个数
@property (nonatomic,assign) NSInteger selectNum;


@end
