//
//  NSMutableAttributedString+Addtions.m
//  WinSFA
//
//  Created by admin on 2022/12/16.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "NSMutableAttributedString+Addtions.h"

#define FONT_SIZE  10.0

@implementation NSMutableAttributedString (Addtions)

+ (NSMutableAttributedString*)getCustomAttributeWithContent:(NSString*)content{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange range = NSMakeRange(0, 0);
   if ([content rangeOfString:@" : "].location != NSNotFound) {
        range = [content rangeOfString:@" : "];
   }
    [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FONT_SIZE] range:NSMakeRange(0, content.length)];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x31EA00) range:NSMakeRange(range.location+2, [content length] - range.location - 2)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x8E8E8E) range:NSMakeRange(0,range.location)];
    
    return attributedText;
}


@end
