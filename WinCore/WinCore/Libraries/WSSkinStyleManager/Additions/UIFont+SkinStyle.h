//
//  UIFont+SkinStyle.h
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (SkinStyle)

+ (UIFont *)fontForKey:(id)key;

+ (UIFont *)boldFontForKey:(id)key;

+ (UIFont *)mainFontOfSize:(CGFloat)fontSize;

+ (UIFont *)mainBoldFontOfSize:(CGFloat)fontSize;

@end
