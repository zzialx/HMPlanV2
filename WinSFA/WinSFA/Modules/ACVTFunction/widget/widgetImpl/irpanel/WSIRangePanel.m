//
//  WSIRangePanel.m
//  WinSFA
//
//  Created by Alicia on 2018/4/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSIRangePanel.h"

#define kTextFieldWidth     60

@interface WSIRangePanel()

@property (nonatomic, strong) UITextField *lowerTextField;
@property (nonatomic, strong) UITextField *upperTextField;

@end

@implementation WSIRangePanel

- (void)buildDisplayContent {
     [super buildDisplayContent];
    
    UITextField *lowerTextField = [self createTextField];
    [self addSubview:lowerTextField];
    self.lowerTextField = lowerTextField;
    
    UITextField *upperTextField = [self createTextField];
    [self addSubview:upperTextField];
    self.upperTextField = upperTextField;
    
    UILabel *lineLabel = [[UILabel alloc] init];
    [self addSubview:lineLabel];
    [lineLabel setText:@" - "];
    [lineLabel setTextColor:DETAIL_TEXT_COLOR];
    [lineLabel sizeToFit];
    
    
    CGFloat height = MAIN_CELL_HEIGHT;
    
    CGFloat offsetX = self.width - MAIN_CELL_PADDING - (kTextFieldWidth * 2) - CGRectGetWidth(lineLabel.frame);
    CGFloat offsetY = (height - MAIN_TEXTFIELD_HEIGHT ) / 2;
    CGRect lowerFrame = CGRectMake(offsetX, offsetY, kTextFieldWidth, MAIN_TEXTFIELD_HEIGHT);
    [lowerTextField setFrame:lowerFrame];
    CGRect lineFrame = CGRectMake(CGRectGetMaxX(lowerFrame) , offsetY, CGRectGetWidth(lineLabel.frame), MAIN_TEXTFIELD_HEIGHT);
    [lineLabel setFrame:lineFrame];
    CGRect upperFrame = CGRectMake(CGRectGetMaxX(lineFrame) , offsetY, kTextFieldWidth, MAIN_TEXTFIELD_HEIGHT);
    [upperTextField setFrame:upperFrame];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
}

- (UITextField *)createTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont systemFontOfSize:UI_Font];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.placeholder = NSLocalizedString(@"please_fill_in", nil);
    return textField;
}


- (NSObject *)getResultDirectly {
    if ([self.lowerTextField.text length] > 0 || [self.upperTextField.text length] > 0) {
        return [NSString stringWithFormat:@"%@,%@", self.lowerTextField.text, self.upperTextField.text];
    } else {
        return nil;
    }
}

- (NSObject *)getSearchCondition {
    if ([self.lowerTextField.text length] > 0 || [self.upperTextField.text length] > 0) {
        return [NSString stringWithFormat:@"%@%@%@", self.lowerTextField.text, QST_SEARCH_RANGE_SEPARATOR, self.upperTextField.text];
    } else {
        return nil;
    }
}

@end
