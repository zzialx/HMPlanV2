//
//  WSContactsBookHeaderView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 通讯录头视图代理协议
@protocol WSContactsBookHeaderViewDelegate <NSObject>

@optional

#pragma mark - 开始搜索方法
- (void)beginSearch;

#pragma mark - 结束搜索方法
- (void)endSearch;

#pragma mark - 搜索结果方法
- (void)searchResult:(NSString *)result;

#pragma mark - 标准按键选择方法
- (void)standardButtonSelected;

#pragma mark - 门店按键选择方法
- (void)storeButtonSelected;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图
@interface WSContactsBookHeaderView : UIView

@property (nonatomic, weak) id<WSContactsBookHeaderViewDelegate> delegate; //代理指针

#pragma mark - 更新视图方法 isShowOrganize:是否显示组织标示 isShowStoreButton:是否显示门店按键
- (void)updateWithIsShowOrganize:(BOOL)isShowOrganize isShowStoreButton:(BOOL)isShowStoreButton;

#pragma mark - 获取高度方法 isShowOrganize:是否显示组织标示 isShowStoreButton:是否显示门店按键 maxWidth:最大宽度
- (CGFloat)getHeightWithisShowOrganize:(BOOL)isShowOrganize isShowStoreButton:(BOOL)isShowStoreButton maxWidth:(CGFloat)maxWidth;

#pragma mark - 关闭搜索框方法
- (void)cloaseSearchBar;

@end
//===================================================================================================================================================================
