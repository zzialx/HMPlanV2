//
//  WSSNShowViewGlobalConfig.m
//  WSSNShowView
//
//  Created by zzialx on 2023/2/14.
//  Copyright © 2023年 zzialx. All rights reserved.
//

#import "WSSNShowViewGlobalConfig.h"

@implementation WSSNShowViewGlobalConfig

static WSSNShowViewGlobalConfig *instance = nil;

+ (WSSNShowViewGlobalConfig *)shared
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSSNShowViewGlobalConfig alloc] init];
        });
    }
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _bgColor = [UIColor blackColor];
        _tittleFont = [UIFont systemFontOfSize:17];
        _titleColor = [UIColor blackColor];
        _subtitleFont = [UIFont systemFontOfSize:15];
        _subTitleColor = [UIColor lightGrayColor];
        _buttonFont = [UIFont systemFontOfSize:13];
        _buttonColor = [UIColor blueColor];
        _buttonBgColor = [UIColor whiteColor];
        _buttonEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 20);
        _scrollVerticalEnable = YES ;
    }
    return self ;
}
@end
