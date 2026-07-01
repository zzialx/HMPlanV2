//
//  UIFont+SkinStyle.m
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "UIFont+SkinStyle.h"
#import "WSSkinStyleManagerKit.h"

@implementation UIFont (SkinStyle)

+ (UIFont *)fontForKey:(id)key
{
    //应用的主字体
    NSDictionary *mainFontDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:kMainFont];
    NSString *mainFontName = [mainFontDic objectForKey:kFontNameKey];
    NSString *mainFontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        mainFontName_iPad = [mainFontDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    
    //当前字体
    NSDictionary *dataDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:key];
    NSString *fontName = [dataDic objectForKey:kFontNameKey];
    NSString *fontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        fontName_iPad = [dataDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    //字体大小
    NSString *fontSizeString = [dataDic objectForKey:kFontSizeKey];
    NSString *fontSizeString_iPad = nil;
    if (INTERFACE_IS_PAD) {
        fontSizeString_iPad = [dataDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontSizeKey, kiPadSuffix]];
    }
    CGFloat fontSize = -1;
    if (INTERFACE_IS_PAD && fontSizeString_iPad && [fontSizeString_iPad length] > 0) {
        fontSize = [fontSizeString_iPad floatValue];
    }
    else if(fontSizeString && [fontSizeString length] > 0)
    {
        fontSize = [fontSizeString floatValue];
    }
    
    if (fontSize < 0) {
        return nil;
    }
    
    
    UIFont *resultFont = nil;
    //优先使用当前字体
    if (fontName || fontName_iPad) {
        if (INTERFACE_IS_PAD && fontName_iPad && [fontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:fontName_iPad size:fontSize];
        }
        if (resultFont == nil && fontName && [fontName length] > 0) {
            resultFont = [UIFont fontWithName:fontName size:fontSize];
        }
    }
    
    //没有当前字体时，使用主字体
    if (resultFont == nil && (mainFontName || mainFontName_iPad)) {
        if (INTERFACE_IS_PAD && mainFontName_iPad && [mainFontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName_iPad size:fontSize];
        }
        if (resultFont == nil  && mainFontName && [mainFontName length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName size:fontSize];
        }
    }
    
    //都没有时，使用系统字体
    if (resultFont == nil) {
        resultFont = [UIFont systemFontOfSize:fontSize];
    }

    return resultFont;
}

+ (UIFont *)boldFontForKey:(id)key
{
    //应用的主字体
    NSDictionary *mainFontDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:kMainFont];
    NSString *mainFontName = [mainFontDic objectForKey:kFontNameKey];
    NSString *mainFontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        mainFontName_iPad = [mainFontDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    
    //当前字体
    NSDictionary *dataDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:key];
    NSString *fontName = [dataDic objectForKey:kFontNameKey];
    NSString *fontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        fontName_iPad = [dataDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    //字体大小
    NSString *fontSizeString = [dataDic objectForKey:kFontSizeKey];
    NSString *fontSizeString_iPad = nil;
    if (INTERFACE_IS_PAD) {
        fontSizeString_iPad = [dataDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontSizeKey, kiPadSuffix]];
    }
    CGFloat fontSize = -1;
    if (INTERFACE_IS_PAD && fontSizeString_iPad && [fontSizeString_iPad length] > 0) {
        fontSize = [fontSizeString_iPad floatValue];
    }
    else if(fontSizeString && [fontSizeString length] > 0)
    {
        fontSize = [fontSizeString floatValue];
    }
    
    if (fontSize < 0) {
        return nil;
    }
    
    
    UIFont *resultFont = nil;
    //优先使用当前字体
    if (fontName || fontName_iPad) {
        if (INTERFACE_IS_PAD && fontName_iPad && [fontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:fontName_iPad size:fontSize];
        }
        if (resultFont == nil && fontName && [fontName length] > 0) {
            resultFont = [UIFont fontWithName:fontName size:fontSize];
        }
    }
    
    //没有当前字体时，使用主字体
    if (resultFont == nil && (mainFontName || mainFontName_iPad)) {
        if (INTERFACE_IS_PAD && mainFontName_iPad && [mainFontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName_iPad size:fontSize];
        }
        if (resultFont == nil  && mainFontName && [mainFontName length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName size:fontSize];
        }
    }
    
    //都没有时，使用系统字体
    if (resultFont == nil) {
        resultFont = [UIFont boldSystemFontOfSize:fontSize];
    }
    
    return resultFont;
}

+ (UIFont *)mainFontOfSize:(CGFloat)fontSize
{
    NSDictionary *mainFontDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:kMainFont];
    NSString *mainFontName = [mainFontDic objectForKey:kFontNameKey];
    NSString *mainFontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        mainFontName_iPad = [mainFontDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    
    UIFont *resultFont = nil;
    
    if (mainFontName || mainFontName_iPad) {
        if (INTERFACE_IS_PAD && mainFontName_iPad && [mainFontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName_iPad size:fontSize];
        }
        if (resultFont == nil  && mainFontName && [mainFontName length] > 0) {
            resultFont = [UIFont fontWithName:mainFontName size:fontSize];
        }
    }
    
    if (resultFont == nil) {
        resultFont = [UIFont systemFontOfSize:fontSize];
    }
    
    return resultFont;
}

+ (UIFont *)mainBoldFontOfSize:(CGFloat)fontSize
{
    NSDictionary *mainFontDic = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:kMainBoldFont];
    NSString *mainBoldFontName = [mainFontDic objectForKey:kFontNameKey];
    NSString *mainBoldFontName_iPad = nil;
    if (INTERFACE_IS_PAD) {
        mainBoldFontName_iPad = [mainFontDic objectForKey:[NSString stringWithFormat:@"%@%@", kFontNameKey, kiPadSuffix]];
    }
    
    UIFont *resultFont = nil;
    
    if (mainBoldFontName || mainBoldFontName_iPad) {
        if (INTERFACE_IS_PAD && mainBoldFontName_iPad && [mainBoldFontName_iPad length] > 0) {
            resultFont = [UIFont fontWithName:mainBoldFontName_iPad size:fontSize];
        }
        if (resultFont == nil  && mainBoldFontName && [mainBoldFontName length] > 0) {
            resultFont = [UIFont fontWithName:mainBoldFontName size:fontSize];
        }
    }
    
    if (resultFont == nil) {
        resultFont = [UIFont systemFontOfSize:fontSize];
    }
    
    return resultFont;
}


@end
