//
//  WTLanguageManager.h
//  WinTraining
//
//  Created by zhangke on 15/1/19.
//  Copyright (c) 2015年 Winchannel. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - 多语言


#define ZHCN @"zh-CN"
#define ZHHans @"zh-Hans"
#define EN @"en"
#define DE @"de"
#define FR @"fr"
#define IT @"it"
#define ES @"es"


#define AppLanguage @"appLanguage"

#define WSLocalizedString(key, comment)  [WTLanguageManager localizedStringForKey:key]


@interface WTLanguageManager : NSObject

+(NSString*)localizedStringForKey:(NSString*)key;

@end
