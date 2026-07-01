//
//  UIColor+SkinStyle.m
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "UIColor+SkinStyle.h"
#import "WSSkinStyleManagerKit.h"

@implementation UIColor (SkinStyle)

+ (UIColor *)colorForKey:(NSString *)key
{
    return [UIColor colorForKey:key style:WSSkinStyleColorTypeNormal];
}

+ (UIColor *)highlightColorForKey:(id)key
{
    return [UIColor colorForKey:key style:WSSkinStyleColorTypeHightLight];
}

+ (UIColor *)shadowColorForKey:(id)key
{
    return [UIColor colorForKey:key style:WSSkinStyleColorTypeShadow];
}

+ (UIColor *)shadowHighlightColorForKey:(id)key
{
    return [UIColor colorForKey:key style:WSSkinStyleColorTypeShadowHightLight];
}

+ (UIColor *)colorForKey:(id)key style:(WSSkinStyleColorType)type
{
    NSDictionary *dataDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:key];
    
    NSString *colorKeyString = nil;
    NSString *colorString = nil;
    switch (type) {
        case WSSkinStyleColorTypeNormal:
            colorKeyString = kColorKey;
            break;
            
        case WSSkinStyleColorTypeHightLight:
            colorKeyString = kColorHighlightKey;
            break;
            
        case WSSkinStyleColorTypeShadow:
            colorKeyString = kShadowColorKey;
            break;
            
        case WSSkinStyleColorTypeShadowHightLight:
            colorKeyString = kShadowColorHighlightKey;
            break;
            
        default:
            colorKeyString = kColorKey;
            break;
    }
    
    if (INTERFACE_IS_PAD) {
        colorString = [dataDic objectForKey:[NSString stringWithFormat:@"%@%@", colorKeyString, kiPadSuffix]];
    }
    if (colorString == nil) {
        colorString = [dataDic objectForKey:colorKeyString];
    }
    
    if (colorString == nil || [colorString length] == 0) {
        return nil;
    }
    
    float red,green,blue,alpha;
    NSArray *colorArray = [colorString componentsSeparatedByString:@","];
    if (colorArray && [colorArray count] >= 3) {
        red = [[colorArray objectAtIndex:0] floatValue];
        green = [[colorArray objectAtIndex:1] floatValue];
        blue = [[colorArray objectAtIndex:2] floatValue];
        
        if ([colorArray count] >= 4) {
            alpha = [[colorArray objectAtIndex:3] floatValue];
        }
        else {
            alpha = 1.0;
        }
    }
    else
    {
        return nil;
    }
    
    if (alpha < 0.0f) {
        return [UIColor clearColor];
    }
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}


@end
