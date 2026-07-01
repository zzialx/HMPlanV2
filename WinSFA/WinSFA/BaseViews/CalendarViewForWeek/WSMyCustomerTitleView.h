//
//  WSMyCustomerTitleView.h
//  WinSFA
//
//  Created by zhiqing on 16/7/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,WSMyCustomerTitleViewStyle) {
    WSMyCustomerTitleViewStyleMyCustomer,   // 我的客户
    WSMyCustomerTitleViewStyleAddNewVisit   // 添加拜访计划

};

@protocol WSMyCustomerTitleViewDelegate <NSObject>

-(void)queryStoresFromDBWithConditions:(NSString *)conditions;

@end

@interface WSMyCustomerTitleView : UIView

@property(nonatomic,weak) id <WSMyCustomerTitleViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame style:(WSMyCustomerTitleViewStyle)style withItems:(NSArray *)items;
@end
