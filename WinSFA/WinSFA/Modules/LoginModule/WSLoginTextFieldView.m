//
//  WSLoginTextFieldView.m
//  WinSFA
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//


// TODO: 将WSLoginViewController 中重复代码去掉，调用该View即可

#import "WSLoginTextFieldView.h"
@interface WSLoginTextFieldView () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation WSLoginTextFieldView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, k_UserPwdIconHeight)];
 
    UITextField *textField = [[UITextField alloc] init] ;
    textField.frame = CGRectMake(0, k_TextFieldYOffSet, self.width, k_TextFieldHeight);
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    [self addBottomBorderToView:textField];
    
    
    textField.textColor = DETAIL_TEXT_COLOR;
    textField.font = [UIFont systemFontOfSize:UI_Font];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    NSString *placeHolder;
    
    
    textField.placeholder = placeHolder;
    if (INTERFACE_IS_PHONE) {
        textField.backgroundColor = kCLEAR_COLOR_value;
    }
    
    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0,k_UserPwdIconWidth, k_UserPwdIconHeight)];
    [leftView addSubview:self.iconImageView];
    
    //添加事件处理方法
    textField.delegate = self;
    [textField addTarget:self action:@selector(textFieldDidEndEditing:)
        forControlEvents:UIControlEventEditingDidEnd];
    [textField addTarget:self action:@selector(textFieldDidBeginEditing:)
        forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action:@selector(textWatcher:)
        forControlEvents:UIControlEventEditingChanged];

    
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField = textField;

    [self addSubview:textField];
}

#pragma mark - Public Method
- (UITextField *)getTextField {
    return self.textField;
}

#pragma mark - Action
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (void)textWatcher:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChange:)]) {
        [self.delegate textFieldDidChange:textField];
    }
}

#pragma mark - Private Method

- (void)addBottomBorderToView:(UIView *)view {
    CGRect frame = view.frame;
    
    CALayer *bottomLayer = [CALayer layer];
    bottomLayer.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
    UIColor *lineColor = [UIColor colorForKey:@"LoginViewTextFieldLineColor"] ?  [UIColor colorForKey:@"LoginViewTextFieldLineColor"] : DETAIL_SEPERATE_LINE_COLOR;
    bottomLayer.backgroundColor =  lineColor.CGColor;
    [view.layer addSublayer:bottomLayer];
}


#pragma mark - Getters and Setters
- (void)setIconImage:(UIImage *)iconImage {
    [self.iconImageView setImage:iconImage];
}

- (void)setPlaceHolderString:(NSString *)placeHolderString {
    self.textField.placeholder = placeHolderString;
}


@end
