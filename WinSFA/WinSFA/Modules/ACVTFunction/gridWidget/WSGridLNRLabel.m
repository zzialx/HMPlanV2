//
//  WSGridLNRLabel.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridLNRLabel.h"
#import "WSNRLabel.h"

@interface WSGridLNRLabel ()

@property (nonatomic, strong) WSNRLabel *nrLabel;

@end

@implementation WSGridLNRLabel
- (void)setupView {
    WSNRLabel * label = [[WSNRLabel alloc] initWithFrame:CGRectMake(0, 0, self.param.wcol, 29)];
    label.font = [UIFont systemFontOfSize:UI_Font];
    label.textColor = GRID_MAIN_TEXT_COLOR;
    label.textAlignment = NSTextAlignmentCenter;

    // TODO
    label.iRow = (unsigned int)self.iRow;
    label.iColumn = (unsigned int)self.iColumn;
    label.m_col = self.m_col;
    
    
    self.nrLabel = label;
}

- (UIView *)getView {
    return self.nrLabel;
}

- (NSString *)getValue {
    NSString *result = @"";
    if (self.nrLabel.text.length > 0) {
        result = self.nrLabel.text;
    }
    return result;
}

- (void)setValue:(NSString *)value {
    // 判断字符串是否为浮点类型，如果为浮点类型的话就按后台配置的小数点位数来格式化。 lnr类型，不做处理
//    NSScanner* scan = [NSScanner scannerWithString:value];
//    float val;
    
//    if ([scan scanFloat:&val] && [scan isAtEnd]) {
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//
//        if ([self.param.pcs integerValue] > 0) {
//            [numberFormatter setMaximumFractionDigits:[self.param.pcs integerValue]];
//        } else {
//            [numberFormatter setMaximumFractionDigits:0];
//        }
//        [numberFormatter setMinimumIntegerDigits:1];
//        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
//
//        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//
//        double doubleValue;
//        if ([value rangeOfString:@","].location != NSNotFound) {
//            doubleValue = [[numberFormatter numberFromString:value] doubleValue];
//        } else {
//            doubleValue = [value doubleValue];
//        }
//        //应该统一使用self.numberFormatter处理
//        NSString *formatString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
//
//        if ([formatString isEqualToString:@"-0"]) {
//            formatString = @"0";
//        }
//
//        value = formatString;
//    }
    
    self.nrLabel.text = value;
}

- (void)setReadonly:(BOOL)isReadonly {
    if (isReadonly) {
        self.nrLabel.textColor = GRID_MAIN_TEXT_DISABLE_COLOR;
    } else {
        self.nrLabel.textColor = GRID_MAIN_TEXT_COLOR;
    }
}

@end
