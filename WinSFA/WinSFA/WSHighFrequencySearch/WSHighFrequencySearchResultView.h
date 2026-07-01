//
//  WSHighFrequencySearchResultView.h
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSHighFrequencySearchResultViewDelegate;
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图
@interface WSHighFrequencySearchResultView : UIView

@property (nonatomic, weak) id <WSHighFrequencySearchResultViewDelegate> delegate;  //代理指针
@property (nonatomic, assign) CGFloat elementHeight;                                //元素高度

#pragma mark - 更新视图方法 dataArray:数据数组
- (void)updateViewWithDataArray:(NSArray *)dataArray;

#pragma mark - 获取元素个数方法
- (NSInteger)getSearchElementCount;

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果视图 代理指针
@protocol WSHighFrequencySearchResultViewDelegate <NSObject>

- (void)deleteClickAtText:(NSString *)text;  //删除点击代理
- (void)selectClickAtText:(NSString *)text;  //选择点击代理

@end
//=====================================================================================================================================
