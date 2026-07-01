//
//  WSSNShowViewConfig.m
//  WSSNShowView
//
//  Created by admin on 2023/2/14.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSSNShowViewConfig.h"
#import "WSSNShowViewGlobalConfig.h"

@implementation WSSNShowViewConfig

+ (instancetype)shared
{
    return [[WSSNShowViewConfig alloc]init];
}
- (instancetype)init{
    if ([super init]) {
        WSSNShowViewGlobalConfig *globalC = [WSSNShowViewGlobalConfig shared] ;
        _scrollVerticalEnable = globalC.scrollVerticalEnable ;
        _easyViewEdgeInsets = UIEdgeInsetsZero ;
    }
    return self ;
}


- (WSSNShowViewConfig *(^)(UIColor *))setBgColor
{
    return ^WSSNShowViewConfig *(UIColor *bgColor){
        self.bgColor = bgColor ;
        return self ;
    };
}
- (WSSNShowViewConfig *(^)(UIFont *))setTitleFont
{
    return ^WSSNShowViewConfig *(UIFont *titleFont){
        self.tittleFont = titleFont ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIColor *))setTitleColor
{
    return ^WSSNShowViewConfig *(UIColor *titleColor){
        self.titleColor = titleColor ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIFont *))setSubtitleFont
{
    return ^WSSNShowViewConfig *(UIFont *subtitleFont){
        self.subtitleFont = subtitleFont ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIColor *))setSubtitleColor
{
    return ^WSSNShowViewConfig *(UIColor *titleColor){
        self.subTitleColor = titleColor ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIFont *))setButtonFont
{
    return ^WSSNShowViewConfig *(UIFont *buttonFont){
        self.buttonFont = buttonFont ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIColor *))setButtonColor
{
    return ^WSSNShowViewConfig *(UIColor *buttonColor){
        self.buttonColor = buttonColor ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIColor *))setButtonBgColor
{
    return ^WSSNShowViewConfig *(UIColor *buttonbgColor){
        self.buttonBgColor = buttonbgColor ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIEdgeInsets))setEasyViewEdgeInsets
{
    return ^WSSNShowViewConfig *(UIEdgeInsets edge){
        self.easyViewEdgeInsets = edge ;
        return self ;
    } ;
}
- (WSSNShowViewConfig *(^)(UIEdgeInsets))setButtonEdgeInsets
{
    return ^WSSNShowViewConfig *(UIEdgeInsets edge){
        self.buttonEdgeInsets = edge ;
        return self ;
    } ;
}

- (WSSNShowViewConfig *(^)(BOOL))setScrollVerticalEnable
{
    return ^WSSNShowViewConfig *(BOOL enabel){
        self.scrollVerticalEnable = enabel ;
        return self ;
    } ;
}

+ (instancetype)configWithBgColor:(UIColor *)bgColor
{
    return [self configWithBgColor:bgColor titleFount:[WSSNShowViewGlobalConfig shared].tittleFont];
}
+ (instancetype)configWithBgColor:(UIColor *)bgColor titleFount:(UIFont *)titleFount
{
    WSSNShowViewConfig *config = [self shared] ;
    config.bgColor = bgColor ;
    config.tittleFont = titleFount ;
    return config ;
}
@end
