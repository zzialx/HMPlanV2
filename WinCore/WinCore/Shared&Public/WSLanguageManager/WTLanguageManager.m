//
//  WTLanguageManager.m
//  WinTraining
//
//  Created by zhangke on 15/1/19.
//  Copyright (c) 2015年 Winchannel. All rights reserved.
//

#import "WTLanguageManager.h"

@implementation WTLanguageManager


+(NSString*)localizedStringForKey:(NSString*)key
{
    NSString* applang= [[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage];
    NSString* path=[[NSBundle mainBundle] pathForResource:applang ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:nil];
}

@end
