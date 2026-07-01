//
//  WSGridRadioButton.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridRadioButton.h"
#import "WSRadioButton.h"

@interface WSGridRadioButton ()

@property (nonatomic, strong) WSRadioButton *radioButton;

@end

@implementation WSGridRadioButton


- (void)setupView {
    WSRadioButton *radioButton = [WSRadioButton buttonWithType:UIButtonTypeCustom];

    // TODO
    radioButton.iRow = (unsigned int)self.iRow;
    radioButton.iColumn = (unsigned int)self.iColumn;
    radioButton.m_col = self.m_col;
 
//    radioButton.frame = CGRectMake(0, 0, 0, 0);
    [radioButton addTarget:self action:@selector(radioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [radioButton setImage:[UIImage imageNamed:@"selected_yes_radio"] forState:UIControlStateSelected];
    [radioButton setImage:[UIImage imageNamed:@"selected_yes_radio"] forState:UIControlStateHighlighted];
    [radioButton setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
    

    if (self.param.idefault && self.param.idefault.length > 0) {
        radioButton.isClicked = YES;
    }
    
    if (self.param.readonly == 1) {
        radioButton.userInteractionEnabled = NO;
    }
    self.radioButton = radioButton;
}


- (UIView *)getView {
    return self.radioButton;
}

- (NSString *)getValue {
    NSString *result;
    if (self.radioButton.isSelected) {
        result = @"1";
    } else {
        if (!self.radioButton.isClicked) {
            result = @"";
        } else {
            result = @"0";
        }
    }
    return result;
}

- (NSString *)getUploadValue {
    NSString *value;
    BOOL isSelected = [self.radioButton isSelected];
    if (isSelected) {
        NSNumber *nValue = [NSNumber numberWithInteger:isSelected];
        value = [nValue stringValue];
    } else {
        value = @"";
    }
    return value;
}


- (void)setValue:(NSString *)value {
    if ([value length] > 0) {
        [self.radioButton setIsClicked:YES];
    }
    
    if (value.length > 0 && [value isEqualToString:@"null"]) {
        self.radioButton.selected = NO;
    } else {
        self.radioButton.selected = [value boolValue];
    }
}

- (void)setReadonly:(BOOL)isReadonly {
    [self.radioButton setEnabled:!isReadonly];
}

- (CGFloat)getSum {
    return [[self getValue] doubleValue];
}

#pragma mark - Actions
- (void)radioButtonPressed:(WSRadioButton *)sender {
    if (self.delegate) {
        [self.delegate dataSourceSetIsValueChanged:YES];
    }
    [self resetGroupViews];
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        [self.delegate dataSourceRunScriptWithWidgetKey:self.widgetKey];
    }
}

#pragma mark - Private Method
- (void)resetGroupViews {
    if (!self.delegate) {
        return;
    }
    
    NSInteger iRow = self.iRow;
    NSString *clickCol = self.m_col;
    
    WSGridWidget *widgetGroup = [self.delegate dataSourceGetGroupViewByType:self.groupName];
    for (NSString *key in [widgetGroup getGridWidgetAllKeys]) {
        WSGridWidget *otherWidget = [widgetGroup getGridWidgetByKey:key];
        UIView *view = [otherWidget getView];
        // 忽略当前控件
        if (otherWidget.iRow == iRow && [otherWidget.m_col isEqualToString:clickCol]) {
            continue;
        }

        // MMSH-4853 只需要设置之前被选中的列
        WSRadioButton *otherRadio = (WSRadioButton *)view;
        if (otherWidget.iRow == iRow && ![otherWidget.m_col isEqualToString:clickCol] && [otherRadio isSelected]) {
            [otherRadio setSelected:NO];
            [self.delegate dataSourceRunScriptWithWidgetKey:otherWidget.widgetKey];
        }
    }
}

@end
