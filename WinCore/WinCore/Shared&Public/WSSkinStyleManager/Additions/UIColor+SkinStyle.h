//
//  UIColor+SkinStyle.h
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	WSSkinStyleColorTypeNormal,
	WSSkinStyleColorTypeHightLight,
	WSSkinStyleColorTypeShadow,
    WSSkinStyleColorTypeShadowHightLight
} WSSkinStyleColorType;

@interface UIColor (SkinStyle)

+ (UIColor *)colorForKey:(NSString *)key;

+ (UIColor *)shadowColorForKey:(id)key;

+ (UIColor *)highlightColorForKey:(id)key;

+ (UIColor *)shadowHighlightColorForKey:(id)key;

+ (UIColor *)colorForKey:(id)key style:(WSSkinStyleColorType)type;

@end
