//
//  WSGridNumberTextField.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridNumberTextField.h"

@implementation WSGridNumberTextField

- (void)setupView {
    [super setupView];
    
    WSHTextField * textfield = (WSHTextField *)[self getView];
    
    // TODO 重构从 WSAcvtDataGridComponentDataSource 挪动过来的代码应该有问题
    if (self.param.pcs && [self.param.pcs length] > 0 && [textfield.text length] > 0 ) {
        CGFloat  contentFloat = [textfield.text floatValue];
        NSString *contentString = [NSString stringWithFormat:@"%lf",contentFloat];
        NSArray *contenArray = [contentString componentsSeparatedByString:@"."];
        NSString *headPart = [contenArray firstObject];
        NSString *endPart = [contenArray lastObject];
        if ([self.param.pcs integerValue] < [endPart length]) {
            endPart = [endPart substringToIndex:[self.param.pcs integerValue]];
        }
        if (endPart && [endPart length] > 0) {
            textfield.text = [NSString stringWithFormat:@"%@.%@",headPart,endPart];
        } else {
            textfield.text = headPart;
        }
    }
}

- (NSString *)getValue {
    WSHTextField * textfield = (WSHTextField *)[self getView];
    NSString *text = [textfield.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    return text;
}


- (NSString *)getUploadValue {
    NSString *value = [super getUploadValue];
    value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    WSHTextField * textfield = (WSHTextField *)[self getView];
    //YIHAIKERRY-4705
    if ([textfield.m_pcs integerValue] > 0 && value.length > 0) {
        NSString *formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[textfield.m_pcs integerValue]];
        value = [NSString stringWithFormat:formatStirng, value.doubleValue];
    }
    
    return value;
}
@end
