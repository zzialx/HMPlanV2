//
//  WSGridDatePickerLabel.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridDatePickerLabel.h"
#import "WSDatePickerLabel.h"


@interface WSGridDatePickerLabel() <WSDatePickerLabelDelegate>

@property (nonatomic, strong) WSDatePickerLabel *datePickerLabel;

@end

@implementation WSGridDatePickerLabel


- (void)setupView {
    WSDatePickerLabel *datePickerLabel = [[WSDatePickerLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100) param:self.param];
    
    // TODO
    datePickerLabel.iRow = (int)self.iRow;
    datePickerLabel.iColumn = (int)self.iColumn;
    datePickerLabel.m_col = self.param.col;

    WSDatePickerLabelMode datePickLabelMode;
    if ([self.param.tpy isEqualToString:COL_TYPDATE]) {
        [datePickerLabel createDatePickerIconWith:WSDatePickerLabelModeDate];
        datePickLabelMode = WSDatePickerLabelModeDate;
    } else if ([self.param.tpy isEqualToString:COL_TYPYM]) {
        datePickLabelMode = WSDatePickerLabelModeYM;
        [datePickerLabel createDatePickerIconWith:WSDatePickerLabelModeYM];
    } else if ([self.param.tpy isEqualToString:COL_TYPTIME]) {
        [datePickerLabel createDatePickerIconWith:WSDatePickerLabelModeTime];
        datePickLabelMode = WSDatePickerLabelModeTime;
        // TODO
        //      view.textAlignment = NSTextAlignmentCenter;

    } else {
        [datePickerLabel createDatePickerIconWith:WSDatePickerLabelModeDate];
        datePickLabelMode = WSDatePickerLabelModeDate;
    }
    datePickerLabel.datePickerLaberMode = datePickLabelMode;
    
    datePickerLabel.delegate = self;
    
    self.datePickerLabel = datePickerLabel;

}

- (UIView *)getView {
    return self.datePickerLabel;
}

- (NSString *)getValue {
    return (self.datePickerLabel.text ? self.datePickerLabel.text : @"");
}

- (void)setValue:(NSString *)value {
    [_datePickerLabel setTimeText:value];
    if (!value) {
        [self.datePickerLabel addTimeImageToView];
    } else {
        [self.datePickerLabel changeStyle];
    }
}

- (void)setMaxValue:(NSString *)maxValue {
    [_datePickerLabel setMaxValue:maxValue];
}

- (void)setMinValue:(NSString *)minValue {
    [_datePickerLabel setMinValue:minValue];
}

#pragma mark - WSDatePickerLabelDelegate
- (void)didSelectedDatePickerLabel:(WSDatePickerLabel *)datePickerLabel {
    if (self.delegate) {
        [self.delegate dataSourceRunScriptWithWidgetKey:self.widgetKey];
    }
}

- (void)datePickerLabel:(WSDatePickerLabel *)datePickerLabel valueChanged:(NSString *)value {
    
}


@end
