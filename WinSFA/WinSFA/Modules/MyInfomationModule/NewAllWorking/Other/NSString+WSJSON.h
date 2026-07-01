//
//  NSString+WSJSON.h
//  WinSFA
//
//  Created by admin on 15/11/4.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WSJSON)

+(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString;

@end
