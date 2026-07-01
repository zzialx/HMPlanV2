//
//  WSHelpSalesViewConfig.h
//  WinSFA
//
//  Created by zzialx on 2025/5/7.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSHelpSalesViewConfig : NSObject

@property (nonatomic,copy,nonnull)NSString * defaultConfig;

@property (nonatomic,strong)UIColor * bgColor ;   //背景颜色

@property (nonatomic,assign)BOOL isCanSelectVisitModule;///是否能选择拜访模块

@property (nonatomic,assign)BOOL isCanSelectHelpSalesModule;///是否能选择助销模块


- (WSHelpSalesViewConfig *(^)(NSString *))setDefaultConfig;

- (WSHelpSalesViewConfig *(^)(UIColor *))setBgColor;

- (WSHelpSalesViewConfig *(^)(BOOL ))setIsCanSelectVisitModule;

- (WSHelpSalesViewConfig *(^)(BOOL ))setIsCanSelectHelpSalesModule;


@end

NS_ASSUME_NONNULL_END
