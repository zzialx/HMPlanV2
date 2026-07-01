//
//  WSAbstArrayStoreBean.h
//  WinSFA
//
//  Created by xiajl on 14-8-15.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAbstArrayStoreBean : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *storesArray;


- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object noteName:(NSString *)aNoteName;
- (id)initWithObjectForSer:(id)object notName:(NSString *)aNotName;

- (id)initWithStoreArray:(NSArray *)array;

//箭牌为了快速支持stores结点，将区分好计划内外的门店还按照旧格式分别放入inplanstore和outplanstore中，这样不影响门店列表页面的逻辑
- (void)addStoresWithArray:(NSArray *)array noteName:(NSString *)noteName;

- (WSStoreBean *)getStoreByID:(NSString *)storeID;

@end
