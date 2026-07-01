//
//  NSString+Util.m
//  WinCore
//
//  Created by Nemo on 14-1-22.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "NSString+Util.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Util)

+ (NSString *)stringWithValue:(id) value{
    
    @try {
        return [[self class] stringWithValue:value byDefault:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
    return nil;
}

+ (NSString *)stringNotNilWithValue:(id) value{
    @try {
        return [[self class] stringWithValue:value byDefault:@""];
    }
    @catch (NSException *exception) {
        return @"";
    }
    return @"";
}

+(NSString *)stringWithValue:(id) value byDefault:(NSString *) defaultValue{

    @try {
        if(value == defaultValue ||(defaultValue != nil && [value isKindOfClass:[NSString class]] && [value isEqualToString:defaultValue])){
            return value;
        }
        if(value != nil){
            if([value isKindOfClass:[NSString class]]){
                return value;
            }
            if([value isKindOfClass:[NSNull class]]){
                return defaultValue;
            }
            if([value isKindOfClass:[NSNumber class]]){
                return [value stringValue];
            }
            if([value isKindOfClass:[NSObject class]]){
//                LogWarn(@"Wrong Value Type:%@, you want string!",value);
                return [value description];
            }
        }
    }
    @catch (NSException *exception) {
        return defaultValue;
    }
    
    return defaultValue;

}

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*) uniqueString
{
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

- (NSString*) mk_urlEncodedString { // mk_ prefix prevents a clash with a private api
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) self,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    
    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}

// MSTD-7135 按照安卓的逻辑生成短UUID
+ (NSString *)shortUniqueStringByLength:(NSInteger)length {
    NSString *uuid = [NSString uniqueString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSInteger kUUIDLength = 32;
    if (length <= 0 || length >= kUUIDLength) {
        return uuid;
    }
    
    NSInteger num = kUUIDLength / length;
    NSString *shortString = @"";
    NSArray *kShortUUIDChar = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i * num, num);
        NSString *str = [uuid substringWithRange:range];
        
        NSString *hexStr = [NSString convertStringToHexStr:str];
        NSInteger x = [hexStr integerValue];
        
        shortString = [shortString stringByAppendingString:kShortUUIDChar[x % 0x3E]];
    }
    return shortString;
}

+ (NSString *)convertStringToHexStr:(NSString *)str {
    if (!str || [str length] == 0) {
        return @"";
    }
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}


- (NSString*) urlDecodedString {
    
    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef) self,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    
    // We need to replace "+" with " " because the CF method above doesn't do it
    NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

-(NSInteger) indexOfString:(NSString *)text{
    
    NSRange range = [self rangeOfString:text];
    
    if (range.length>0) {
        
        return range.location;
    }else{
    
        return -1;
    }
    
    
}

- (CGSize)stringSizeWithFont:(UIFont *)font width:(CGFloat)width
{
    CGSize stringSize = CGSizeMake(0, 0);
    
    if (width > 0) {
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil].size;
#else
        stringSize = [self  sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
#endif
    }else{
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [self sizeWithAttributes:@{NSFontAttributeName: font}];
#else
        stringSize = [self sizeWithFont:font];
#endif
    }
    
    return stringSize;
}

- (BOOL)isPureNumber {
    NSString *checkedNumString = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}

+ (NSString*) headAppendExtraSourceStr:(NSString*)sourceStr withExtralStr:(NSString*)extralStr
{
    if (!sourceStr) {
        return extralStr;
    }
    
    if (!extralStr) {
        return sourceStr;
    }
    
    if ([sourceStr rangeOfString:extralStr].location == NSNotFound) {
        return [NSString stringWithFormat:@"%@%@", extralStr, sourceStr];
    }
    
    return sourceStr;
}

@end
