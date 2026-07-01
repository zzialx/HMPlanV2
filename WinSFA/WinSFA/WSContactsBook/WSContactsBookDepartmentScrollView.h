//
//  WSContactsBookDepartmentScrollView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSContactsBookDepartmentScrollView;
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图代理协议
@protocol WSContactsBookDepartmentScrollViewDelegate <NSObject>

#pragma mark - 点击事件方法 departmentScrollView:通讯录部门滚动视图 index:索引
- (void)departmentScrollView:(WSContactsBookDepartmentScrollView *)departmentScrollView tappedAtIndex:(NSInteger)index;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图
@interface WSContactsBookDepartmentScrollView : UIView

@property (nonatomic, strong) NSMutableArray *tags;                                 //标签数组
@property (nonatomic, strong) NSString *tagPlaceholder;                             //标签占位符
@property (nonatomic, strong) UIFont *font;                                         //字体
@property (nonatomic, weak) id<WSContactsBookDepartmentScrollViewDelegate> delegate;//代理指针

#pragma mark - 重载标签子视图方法
- (void)reloadTagSubviews;

#pragma mark - 添加标签方法
- (void)addTag:(NSString *)tag;

@end
//===================================================================================================================================================================
