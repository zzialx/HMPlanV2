//
//  WSGridTextField.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridTextField.h"
#import "WSHTextField.h"


// TODO 可以去掉
#import "IQKeyboardManager.h"


@interface WSGridTextField () <UITextFieldDelegate>

@property (nonatomic, strong) WSHTextField *textField;

@end

@implementation WSGridTextField


- (void)setupView {
    WSHTextField *textfield = [[WSHTextField alloc] initWithFrame:CGRectMake(3, 3, self.param.wcol, 24) Param:self.param isAcvtGrid:YES];
    
    // TODO
    textfield.iRow = (unsigned int)self.iRow;
    textfield.iColumn = (unsigned int)self.iColumn;
    textfield.m_col = self.m_col;
    textfield.iColumnName = self.iColumnName;
    
    textfield.backgroundColor = [UIColor clearColor];
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.delegate = self;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    // 添加placeholder提示颜色
    // MN-2439 产品管理界面UI优化
    if (self.param.hints && self.param.hints.length > 0) {
        //            NSDictionary *attrDicColor = @{NSForegroundColorAttributeName:HColorFromHex(0x999999)};
        NSDictionary *attrDicColor = @{NSForegroundColorAttributeName:HColorFromHex(0x949494),NSFontAttributeName:[UIFont systemFontOfSize:17]};
        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.param.hints attributes:attrDicColor];
        [textfield setAttributedPlaceholder:attributedPlaceholder];
    }
    
    self.textField = textfield;
    
    [self setReadonly:self.param.readonly];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.textField];
}

#pragma mark - 实现基类中的方法
- (UIView *)getView {
    return self.textField;
}

- (NSString *)getValue {
   return self.textField.text;
}

- (void)setValue:(NSString *)value{
    if (value.length > 0 && [value isEqualToString:@"null"]) {
        self.textField.text = @"";
    } else {
        if ([self.textField checkMaxValue:value]) {
            self.textField.text = value;
        }
        else
        {
            self.textField.text = @"";

        }
    }
}

- (void)setMaxValue:(NSString *)maxValue {
    self.textField.m_max = maxValue;
}

- (void)setMinValue:(NSString *)minValue {
    self.textField.m_min = minValue;
}

- (void)setRequest:(BOOL)isRequest {
     self.textField.isReq = [NSString stringWithFormat:@"%d", isRequest];
}

- (void)setReadonly:(BOOL)isReadonly {
    [self.textField setEnabled:!isReadonly];
    if (isReadonly) {
        self.textField.textColor = GRID_MAIN_TEXT_DISABLE_COLOR;
    } else {
        self.textField.textColor = GRID_MAIN_TEXT_COLOR;
    }
}

- (void)setTextColorHexString:(NSString *)colorHexString {
   self.textField.textColor = [UIColor colorWithHexString:colorHexString];
}

- (CGFloat)getSum {
    return [[self getValue] doubleValue];
}

- (void)setWidgetKey:(NSString *)widgetKey {
    [super setWidgetKey:widgetKey];
    
    self.textField.gridWidgetKey = widgetKey;
}

#pragma mark -  UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
    // TODO MSTD-7881 不合理的位置，应该移动走
    [[IQKeyboardManager sharedManager] setEnable:NO];

    [aTextField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isKindOfClass:[WSHTextField class]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        
        NSString *textFieldColumnTip = self.param.tip;
        
        BOOL willValidatedMaxValue = NO;
        if (self.param.max && [self.param.max rangeOfString:@"{"].location != NSNotFound) {
            willValidatedMaxValue = YES;
        }
        
        if (![string isEqualToString:@""] && willValidatedMaxValue) {
            if (self.delegate) {
                WSGridDataSourceReplaceStatus replaceStatus =  [self.delegate dataSourceReplaceStatus:(WSHTextField *)textField replacementString:string columnTip:textFieldColumnTip];
                if (replaceStatus == WSGridDataSourceReplaceStatusNo) {
                    return NO;
                } else if (replaceStatus == WSGridDataSourceReplaceStatusYES) {
                    return YES;
                }
            }
        }
        
        WSHTextField *view = (WSHTextField *)textField;
        
        // TODO 数字类型 不应该在这里
        // SFA-7237
        if (![view.text isEqualToString:@""] && textFieldColumnTip &&
            [view.m_type isEqualToString:COL_TYPNUM]) {
            NSString *validatedString = [NSString stringWithFormat:@"%@%@",textField.text,string];
            if ([validatedString floatValue] > [view.m_max floatValue]) {
                view.isNeedValidateText = NO;
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:textFieldColumnTip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return YES;
            }
        }
        
        return [view shouldReplacementString:string inRange:range];
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    WSHTextField *textFieldView =(WSHTextField *)textField;
    [textFieldView resignFirstResponder];
    
    NSInteger iRow = self.iRow;
    NSInteger iColumn = self.iColumn;
    
    WSGridWidget *widgetGroup = [self.delegate dataSourceGetGroupViewByType:self.groupName];
    for (NSString *key in [widgetGroup getGridWidgetAllKeys]) {
        WSGridWidget *otherWidget = [widgetGroup getGridWidgetByKey:key];
        UIView *view = [otherWidget getView];
        if ((otherWidget.iRow == iRow && otherWidget.iColumn > iColumn) ||
            otherWidget.iRow > iRow) {
            WSHTextField *textFieldOpt = (WSHTextField *)view;
            if (textFieldOpt.enabled && !textFieldOpt.isHidden) {
                [textFieldOpt becomeFirstResponder];
                return NO ;
            }
        }
    }
    return YES;
}

- (void)textFieldTextDidChange:(id)sender {

    if (sender && [sender isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)sender;
        if (notification.object && [notification.object isKindOfClass:[WSHTextField class]]) {
            WSHTextField *tempTextField = (WSHTextField *)notification.object;
            if (tempTextField == self.textField) {
                if (self.delegate) {
                    [self.delegate dataSourceDidChange:sender];
                    [self textDidChangeForTextField:notification.object];
                    /*执行列的脚本*/
                    [self.delegate dataSourceRunScriptWithWidgetKey:self.widgetKey];
                }

            }
        }
        
    }
    
}

- (void)textDidChangeForTextField:(WSHTextField *)textFiled {
    if (self.delegate) {
        [self.delegate dataSourceTextFieldDidChanged:textFiled];
    }
}

@end
