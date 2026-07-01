//
//  WSBaseDropListPanel.h
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "I_CascadeRelation.h"

#import "WSBaseDropListView.h"

@protocol WSDropListViewDelegate;

@class WSBaseDropListView;

@interface WSBaseDropListPanel : WSSingleTitlePanel<WSDropListViewDelegate,I_CascadeRelation>

@property (nonatomic, strong) NSArray *allStores;


@property (nonatomic, strong) WSBaseDropListView *dropListView;

@property (nonatomic, assign) BOOL needCheckValueChange;   //是否需要检查value change（放在acvtview的changeDic里面代表值已改变，未上传退出时会弹出提示）

@property (nonatomic, assign) BOOL needRiseSelectionChange; //是否需要发起change的事件 （触发脚本之类的）

@property (nonatomic, assign) BOOL showRedisValueAfterExcuteLuaSript;

@property (nonatomic, assign) BOOL isExecuteLuacript;///是否执行脚本

- (void)setSelectedNum:(NSString *)limit;
- (void)setSourceTableReadOnly:(BOOL)readOnly;

//- (void)flushDropListDataSource;

- (NSArray *)getDataSource;

- (void)refreshDataSource;

- (void)cleanSelection;


#pragma mark - for I_CascadeRelation

@property (nonatomic, weak) id<I_CascadeRelation> parentWidget;

//@property (nonatomic, weak) id<I_CascadeRelation> subWidget;

- (void)initDataForCascadeRelation:(BOOL)isRefreshSelf;

@property (nonatomic , strong) NSMutableArray * subWidgetArray; // 子级控件集合 MN-1633

@end
