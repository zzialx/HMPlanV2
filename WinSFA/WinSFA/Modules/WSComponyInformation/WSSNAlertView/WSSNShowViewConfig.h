//
//  WSSNShowViewConfig.h
//  WSSNShowView
//
//  Created by admin on 2023/2/14.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSSNShowViewConfig : NSObject


@property (nonatomic,strong)UIColor *bgColor ;   //背景颜色

@property (nonatomic,strong)UIFont  *tittleFont ; //标题字体大小

@property (nonatomic,strong)UIColor *titleColor ;//标题字体颜色

@property (nonatomic,strong)UIFont  *subtitleFont ;  //副标题字体大小
@property (nonatomic,strong)UIColor *subTitleColor ;//副标题字体颜色

@property (nonatomic,strong)UIFont  *buttonFont ;    //按钮字体大小
@property (nonatomic,strong)UIColor *buttonColor ;  //按钮字体颜色
@property (nonatomic,strong)UIColor *buttonBgColor ;//按钮背景颜色

@property (nonatomic,assign)UIEdgeInsets easyViewEdgeInsets ;//整个emptyview往内缩的距离(如果为负数，则会超出边界)
@property (nonatomic,assign)UIEdgeInsets buttonEdgeInsets ; //按钮往内缩的边距（按钮四边边缘距离文字的距离）
@property (nonatomic,assign)BOOL scrollVerticalEnable ;//是否可以上下滚动

+ (instancetype)shared ;
- (WSSNShowViewConfig *(^)(UIColor *))setBgColor ;
- (WSSNShowViewConfig *(^)(UIFont *))setTitleFont ;
- (WSSNShowViewConfig *(^)(UIColor *))setTitleColor ;
- (WSSNShowViewConfig *(^)(UIFont *))setSubtitleFont ;
- (WSSNShowViewConfig *(^)(UIColor *))setSubtitleColor ;
- (WSSNShowViewConfig *(^)(UIFont *))setButtonFont ;
- (WSSNShowViewConfig *(^)(UIColor *))setButtonColor ;
- (WSSNShowViewConfig *(^)(UIColor *))setButtonBgColor ;
- (WSSNShowViewConfig *(^)(UIEdgeInsets))setEasyViewEdgeInsets ;
- (WSSNShowViewConfig *(^)(UIEdgeInsets))setButtonEdgeInsets ;
- (WSSNShowViewConfig *(^)(BOOL))setScrollVerticalEnable ;


+ (instancetype)configWithBgColor:(UIColor *)bgColor ;
+ (instancetype)configWithBgColor:(UIColor *)bgColor titleFount:(UIFont *)titleFount ;


@end

NS_ASSUME_NONNULL_END
