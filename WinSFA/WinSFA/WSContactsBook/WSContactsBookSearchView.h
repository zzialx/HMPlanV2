//
//  WSContactsBookSearchView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图代理协议
@protocol WSContactsBookSearchViewDelegate <NSObject>

#pragma mark - 结果选择代理协议
- (void)resultsSelect:(id)results;

#pragma mark - 滚动视图拖动代理协议
- (void)scrollViewStartDragging;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录搜索视图
@interface WSContactsBookSearchView : UIView

@property (nonatomic, strong) NSMutableArray *resultMutableArray;           //搜索结果数据
@property (nonatomic, weak) id<WSContactsBookSearchViewDelegate> delegate;  //代理指针

@end
//===================================================================================================================================================================
