//
//  WSGridCheckBox.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridCheckBox.h"
#import "WSCheckBox.h"

@interface WSGridCheckBox ()

@property (nonatomic, strong) WSCheckBox *checkBox;

@end

@implementation WSGridCheckBox


- (void)setupView {
    WSCheckBox *checkButton = [WSCheckBox buttonWithType:UIButtonTypeCustom];
    
    // TODO
    checkButton.iRow = (unsigned int)self.iRow;
    checkButton.iColumn = (unsigned int)self.iColumn;
    checkButton.m_col = self.m_col;
    
    
//    checkButton.frame = CGRectMake(0, 0, 0, 0);
    [checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
    [checkButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
    [checkButton setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
    [checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    
   
    if (self.param.idefault && self.param.idefault.length > 0) {
        checkButton.isClicked = YES;
    }
    if (self.param.readonly == 1) {
        checkButton.userInteractionEnabled = NO;
    }
    if (self.param.isNotUploadEmpty) {
        checkButton.isNotUploadEmpty = YES;
    }
    
    // TODO 作用
    checkButton.tpy = self.param.tpy;
    
    
    self.checkBox = checkButton;
}

- (UIView *)getView {
    return self.checkBox;
}

- (NSString *)getValue {
    NSString *result;
    if (self.checkBox.isSelected) {
        result = @"1";
    } else {
        if (!self.checkBox.isClicked || self.checkBox.isNotUploadEmpty) {
            result = @"";
        } else {
            result = @"0";
        }
    }
    return result;
}

- (NSString *)getUploadValue {
    NSString *value;
    BOOL isNoValue = YES;
    BOOL isSelected = [self.checkBox isSelected];
    if (!isSelected) {
        // isNotUploadEmpty 为 YES 则忽略是否点击过
        BOOL isNotUploadEmpty = [self.checkBox isNotUploadEmpty];
        if (!isNotUploadEmpty) {
            isNoValue = [self.checkBox isClicked];
        }
    } else {
        isNoValue = NO;
    }
    if (!isNoValue) {
        NSNumber *nValue = [NSNumber numberWithInteger:isSelected];
        value = [nValue stringValue];
    } else {
        value = @"";
    }
    return value;
}


- (void)setValue:(NSString *)value {
    if ([value length] > 0) {
        [self.checkBox setIsClicked:YES];
    }
    
    if (value.length > 0 && [value isEqualToString:@"null"]) {
        self.checkBox.selected = NO;
    } else {
        self.checkBox.selected = [value boolValue];
    }
}

- (void)setReadonly:(BOOL)isReadonly {
    [self.checkBox setEnabled:!isReadonly];
}

- (CGFloat)getSum {
    return [[self getValue] doubleValue];
}

#pragma mark - Actions
- (void)checkBoxPressed:(WSCheckBox *)sender {
    if (self.delegate) {
        [self.delegate dataSourceSetIsValueChanged:YES];
        [self.delegate dataSourceDidChange:sender];
    }
    WSCheckBox *checkBoxSelected = (WSCheckBox *)sender;
    if (checkBoxSelected.selected) {
        [checkBoxSelected setSelected:NO];
    } else {
        [checkBoxSelected setSelected:YES];
    }
    
    if ([self.param.tpy isEqualToString:COL_TYPCHECKBOX]) {
        if (sender.selected) {
//    SFA-25187 董宏
            [self checkMutex];
        }
    }
    if (self.delegate) {
        [self.delegate dataSourceRunScriptWithWidgetKey:self.widgetKey];
    }
}


#pragma mark - Private Method
- (void)checkMutex {
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
        if (otherWidget.param.isMutex && [otherWidget.m_col isEqualToString:clickCol]) {
            WSCheckBox *checkBox = (WSCheckBox *)view;
            [checkBox setSelected:NO];
        }
    }
}

@end
