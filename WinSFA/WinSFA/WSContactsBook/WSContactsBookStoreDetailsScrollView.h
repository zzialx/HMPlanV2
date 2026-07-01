//
//  WSContactsBookStoreDetailsScrollView.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSContactsBookServiceDataModel.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图代理协议
@protocol WSContactsBookStoreDetailsScrollViewDelegate <NSObject>

#pragma mark - 消息按键选择方法
- (void)messageButtonSelected:(NSString *)phone;

#pragma mark - 电话按键选择方法
- (void)phoneButtonSelected:(NSString *)phone;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图
@interface WSContactsBookStoreDetailsScrollView : UIScrollView

@property (nonatomic, strong) WSContactsDetailInfo *infoData;                                       //信息数据
@property (nonatomic, weak) id<WSContactsBookStoreDetailsScrollViewDelegate> interactiveDelegate;   //代理指针

@end
//===================================================================================================================================================================
