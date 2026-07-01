//
//  HZHSearchBar.m
//  HZHTestProject
//
//  Created by HZH on 2017/9/8.
//  Copyright © 2017年 HZH. All rights reserved.
//

#import "HZHSearchBar.h"

#define hTextFieldLeftMargin    0.0
#define hTextFieldRightMargin   0.0
#define hTextFieldTopMargin     0.0
#define hTextFieldBottomMargin  0.0

@interface HZHSearchBar() <UITextFieldDelegate>
{
    UITextField *_textField;
    UIImageView *_leftIconView;
    UIImageView *_rightIconView;
    UIView *_leftIconBackgroundView;
    UIView *_rightIconBackgroundView;
    UIButton    *_cancelButton;
    HZHSearchBarContentAlign _contentAlignTemp;
}
@end

@implementation HZHSearchBar

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(hTextFieldLeftMargin, hTextFieldTopMargin, self.bounds.size.width - hTextFieldLeftMargin - hTextFieldRightMargin, self.bounds.size.height - hTextFieldTopMargin - hTextFieldBottomMargin)];
    _textField.delegate = self;
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.layer.masksToBounds = YES;
    _textField.layer.cornerRadius = 2.5;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:_textField];
    
    _leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    _leftIconView.contentMode = UIViewContentModeScaleAspectFit;
    _leftIconBackgroundView = [[UIView alloc] initWithFrame:_leftIconView.frame];
    [_leftIconBackgroundView addSubview:_leftIconView];
    
    _textField.leftView = _leftIconBackgroundView;
    _textField.leftViewMode =  UITextFieldViewModeAlways;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(self.frame.size.width -60, 0, 60, self.bounds.size.height);
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_cancelButton addTarget:self
                     action:@selector(cancelButtonTouched)
           forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self addSubview:_cancelButton];
    
    _cancelButton.hidden = YES;
}

- (void)setTextFieldLeftMargin:(CGFloat)textFieldLeftMargin
{
    _textFieldLeftMargin = textFieldLeftMargin;
    
    CGRect textFieldFrame = _textField.frame;
    textFieldFrame.origin.x = textFieldLeftMargin;
    textFieldFrame.size.width = textFieldFrame.size.width - textFieldLeftMargin;
    _textField.frame = textFieldFrame;
}

- (void)setTextFieldRightMargin:(CGFloat)textFieldRightMargin
{
    _textFieldRightMargin = textFieldRightMargin;
    
    CGRect textFieldFrame = _textField.frame;
    textFieldFrame.size.width = textFieldFrame.size.width - textFieldRightMargin;
    _textField.frame = textFieldFrame;
    
    _cancelButton.frame = CGRectMake(self.frame.size.width - 60 - textFieldRightMargin, 0, 60, self.bounds.size.height);

}

- (void)setTextFieldTopMargin:(CGFloat)textFieldTopMargin
{
    _textFieldTopMargin = textFieldTopMargin;
    
    CGRect textFieldFrame = _textField.frame;
    textFieldFrame.origin.y = textFieldTopMargin;
    textFieldFrame.size.height = textFieldFrame.size.height - textFieldTopMargin;
    _textField.frame = textFieldFrame;
}

- (void)setTextFieldBottomMargin:(CGFloat)textFieldBottomMargin
{
    _textFieldBottomMargin = textFieldBottomMargin;
    
    CGRect textFieldFrame = _textField.frame;
    textFieldFrame.size.height = textFieldFrame.size.height - textFieldBottomMargin;
    _textField.frame = textFieldFrame;
}

- (void)setLeftIconLeftMargin:(CGFloat)leftIconLeftMargin
{
    _leftIconLeftMargin = leftIconLeftMargin;
    
    CGRect leftIconViewFrame = _leftIconView.frame;
    leftIconViewFrame.origin.x = leftIconLeftMargin;
    _leftIconView.frame = leftIconViewFrame;
    
    CGRect leftIconBackgroundViewFrame = _leftIconBackgroundView.frame;
    leftIconBackgroundViewFrame.size.width = leftIconBackgroundViewFrame.size.width + leftIconLeftMargin;
    _leftIconBackgroundView.frame = leftIconBackgroundViewFrame;
}

- (void)setLeftIconRightMargin:(CGFloat)leftIconRightMargin
{
    _leftIconRightMargin = leftIconRightMargin;

    CGRect leftIconBackgroundViewFrame = _leftIconBackgroundView.frame;
    leftIconBackgroundViewFrame.size.width = leftIconBackgroundViewFrame.size.width + leftIconRightMargin;
    _leftIconBackgroundView.frame = leftIconBackgroundViewFrame;
}

- (void)setLeftIcon:(UIImage *)leftIcon
{
    _leftIcon = leftIcon;
    [_leftIconView setImage:leftIcon];
}

- (void)setRightIcon:(UIImage *)rightIcon
{
    _rightIcon = rightIcon;
    [_rightIconView setImage:rightIcon];
}

- (void)setTextBackgroundColor:(UIColor *)textBackgroundColor
{
    _textBackgroundColor = textBackgroundColor;
    _textField.backgroundColor = textBackgroundColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _textField.placeholder = placeholder;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6.0)
    {
        [_textField setValue:_placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    else
    {
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    }
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6.0)
    {
        [_textField setValue:_placeholderFont forKeyPath:@"_placeholderLabel.font"];
    }
    else
    {
        NSMutableAttributedString *attributedPlaceholderMString = [[NSMutableAttributedString alloc] initWithAttributedString:_textField.attributedPlaceholder];
        
        NSMutableParagraphStyle *style = [_textField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
        style.minimumLineHeight = _textField.font.lineHeight - (_textField.font.lineHeight - placeholderFont.lineHeight) / 2.0;
        
        if (placeholderFont) {
            [attributedPlaceholderMString addAttribute:NSFontAttributeName value:placeholderFont range:NSMakeRange(0, attributedPlaceholderMString.length)];
        }
        
        [attributedPlaceholderMString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedPlaceholderMString.length)];
        
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithAttributedString:attributedPlaceholderMString];
    }
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    
    _textField.font = textFont;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    _textField.text = text;
}

- (NSString *)getText
{
    return _text;
}

- (void)setCancelButtonIcon:(UIImage *)cancelButtonIcon
{
    _cancelButtonIcon = cancelButtonIcon;
    
    [_cancelButton setBackgroundImage:cancelButtonIcon forState:UIControlStateNormal];
    
    CGRect cancelButtonFrame = _cancelButton.frame;
    cancelButtonFrame.size = cancelButtonIcon.size;
    
    [_cancelButton setFrame:cancelButtonFrame];
    
}

- (void)setCancelButtonText:(NSString *)cancelButtonText
{
    _cancelButtonText = cancelButtonText;
    
    [_cancelButton setTitle:cancelButtonText forState:UIControlStateNormal];
    
    [self resetCancelButtonFrame];

}

- (void)setCancelButtonTextColor:(UIColor *)cancelButtonTextColor
{
    _cancelButtonTextColor = cancelButtonTextColor;
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6.0)
    {
        [_cancelButton setValue:_cancelButtonTextColor forKeyPath:@"_titleLabel.textColor"];
    }
    else
    {
        [_cancelButton setTitleColor:_cancelButtonTextColor forState:UIControlStateNormal];
    }
    
}

- (void)setCancelButtonTextFont:(UIFont *)cancelButtonTextFont
{
    _cancelButtonTextFont = cancelButtonTextFont;
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6.0)
    {
        [_cancelButton setValue:_cancelButtonTextFont forKeyPath:@"_titleLabel.font"];
    }
    else
    {
        NSMutableAttributedString *attributedTitleMString = [[NSMutableAttributedString alloc] initWithAttributedString:_cancelButton.currentAttributedTitle];
        [attributedTitleMString addAttribute:NSFontAttributeName value:cancelButtonTextFont range:NSMakeRange(0, attributedTitleMString.length)];

        [_cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithAttributedString:attributedTitleMString] forState:UIControlStateNormal];
    }
    
    [self resetCancelButtonFrame];
}

- (void)setCancelButtonLeftMargin:(CGFloat)cancelButtonLeftMargin
{
    _cancelButtonLeftMargin = cancelButtonLeftMargin;
    

}

- (void)resetCancelButtonFrame
{
    if (_cancelButtonText && _cancelButtonText.length > 0 && _cancelButtonTextFont) {
        NSDictionary *attributedsDic = [[NSDictionary alloc] initWithObjectsAndKeys: _cancelButtonTextFont, NSFontAttributeName, nil];
        CGSize cancelButtonSize = [_cancelButtonText sizeWithAttributes:attributedsDic];
        
        CGRect cancelButtonFrame = _cancelButton.frame;
        cancelButtonFrame.size.width = cancelButtonSize.width + 4.0;
        
        [_cancelButton setFrame:cancelButtonFrame];
    }
}

- (void)cancelButtonTouched
{
    
    _textField.text = @"";
    [_textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

#pragma --mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(_contentAlign == HZHSearchBarContentAlignCenter){
        self.contentAlign = HZHSearchBarContentAlignLeft;
    }
    [UIView animateWithDuration:0.1 animations:^{
        _cancelButton.hidden = NO;
        CGRect textFieldFrame = _textField.frame;
        textFieldFrame.size.width = textFieldFrame.size.width - _cancelButton.frame.size.width;
        _textField.frame = textFieldFrame;
        
        CGRect cancelButtonFrame = _cancelButton.frame;
        cancelButtonFrame.origin.x = _textField.frame.origin.x + _textField.frame.size.width + _cancelButtonLeftMargin;
        
        [_cancelButton setFrame:cancelButtonFrame];
        
        //        _textField.transform = CGAffineTransformMakeTranslation(-_cancelButton.frame.size.width,0);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
    {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)])
    {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_contentAlign == HZHSearchBarContentAlignCenter){
        self.contentAlign = HZHSearchBarContentAlignCenter;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        _cancelButton.hidden = YES;
        CGRect textFieldFrame = _textField.frame;
        textFieldFrame.size.width = textFieldFrame.size.width - _cancelButton.frame.size.width;
        _textField.frame = textFieldFrame;
        
        _textField.frame = CGRectMake(_textFieldLeftMargin, _textFieldTopMargin, self.bounds.size.width - _textFieldLeftMargin - _textFieldRightMargin, self.bounds.size.height - _textFieldTopMargin - _textFieldBottomMargin);
        //        _textField.transform = CGAffineTransformMakeTranslation(-_cancelButton.frame.size.width,0);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [self.delegate searchBarTextDidEndEditing:self];
    }
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        _text = textField.text;
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)])
    {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:@""];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
    {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}

- (void)setReturnKeyboardTypeWithReturnKey :(UIReturnKeyType)returnKeyBoardType{
    _textField.returnKeyType = returnKeyBoardType;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
