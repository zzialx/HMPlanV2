//
//  NSDictionary+Additional.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additional)

- (NSString *)getStringValueWithKeyName:(NSString *)aKey;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
