//
//  WSStoreTools.m
//  WinSFA
//
//  Created by yuanji on 2018/9/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStoreTools.h"

@implementation WSStoreTools

+ (NSString *)strChange:(NSString *)str
{
    NSRange range = [str rangeOfString:@"."];
    if (range.location != NSNotFound) {
        if (range.location==1) {
            return str;
        }
        else
        {
            NSInteger num;
            NSString *unit;
            if (str.length>range.location+2) {
                num = [[str substringWithRange:NSMakeRange(0,range.location+2)] integerValue];
                unit = [str substringWithRange:NSMakeRange(range.location+2,str.length-range.location-2)];
                return [NSString stringWithFormat:@"%ld%@",num,unit];
            }
            
            return str;
        }
    }
    else
    {
        return str;
    }
}
+ (UIColor*)getApproveLabColorWithState:(NSString*)approveState{
    if(approveState!=nil){
        if([approveState isEqualToString:@"审批中"]){
            return HColorFromHex(0xFAAD14);
        }if([approveState isEqualToString:@"审批通过"]){
            return HColorFromHex(0x28A707);
        }if([approveState isEqualToString:@"审批无效"]){
            return HColorFromHex(0xFF4D4F);
        }if([approveState isEqualToString:@"审批拒绝"]){
            return [UIColor redColor];
        }
    }
    return HColorFromHex(0xFAAD14);
}
@end
