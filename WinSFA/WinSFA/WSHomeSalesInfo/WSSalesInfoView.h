//
//  WSSalesInfoView.h
//  WinSFA
//
//  Created by yuanji on 2018/4/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSalesInfoViewShowData;
typedef void (^NotifyClickBlock)(void);   //定义 通知点击闭包
//===================================================================================================================================================================

#pragma mark - 销售信息视图
@interface WSSalesInfoView : UIView

@property (nonatomic, copy) NotifyClickBlock notifyClickBlock;  //通知点击闭包
@property (nonatomic, copy, readonly) NSString *noticeCount;    //通知数量

#pragma mark - 计算销售信息视图高度方法 width:宽度
- (CGFloat)calculationSalesInfoViewHeightWithWidth:(CGFloat)width;

#pragma mark - 更新销售信息视图方法 showData:显示数据
- (void)updateSalesInfoViewWithShowData:(WSSalesInfoViewShowData *)showData;

#pragma mark - 更新通知数量方法 countData:数量数据
- (void)updateNoticeCountWithCountData:(NSString *)countData;

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图显示数据
@interface WSSalesInfoViewShowData : NSObject

@property (nonatomic, copy) NSString *slogan;           //口号
@property (nonatomic, copy) NSString *noticeCount;      //通知数量

@property (nonatomic, copy) NSString *tilte1;           //标题1
@property (nonatomic, copy) NSString *content1;         //内容1
@property (nonatomic, copy) NSString *tilte2;           //标题2
@property (nonatomic, copy) NSString *content2;         //内容2
@property (nonatomic, copy) NSString *tilte3;           //标题3
@property (nonatomic, copy) NSString *content3;         //内容3
@property (nonatomic, copy) NSString *tilte4;           //标题4
@property (nonatomic, copy) NSString *content4;         //内容4
@property (nonatomic, copy) NSString *tilte5;           //标题5
@property (nonatomic, copy) NSString *content5;         //内容5
@property (nonatomic, copy) NSString *tilte6;           //标题6
@property (nonatomic, copy) NSString *content6;         //内容6
@property (nonatomic, copy) NSString *tilte7;           //标题6
@property (nonatomic, copy) NSString *content7;         //内容6
@end
//===================================================================================================================================================================

