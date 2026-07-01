//
//  NSString+WSJSON.m
//  WinSFA
//
//  Created by admin on 15/11/4.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "NSString+WSJSON.h"

@implementation NSString (WSJSON)

+(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return responseJSON;
}

@end
