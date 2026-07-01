//
//  WSTextViewEditTool.m
//  WinSFA
//
//  Created by zhangmin on 2018/8/27.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTextViewEditTool.h"

@interface WSTextViewEditTool ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView                *textView;
@property (nonatomic, strong) UILabel                   *placeholderLabel;
@property (nonatomic, strong) UILabel                   *titleLabel;

@end
@implementation WSTextViewEditTool

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text title: (NSString *)title
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self initTextFieldWithText:text title:title];
    }
    return self;
}

- (void)initTextFieldWithText:(NSString *)text title: (NSString *)title
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
   
    CGFloat width = SCREEN_WIDTH * POP_VIEW_WIDTH_RATIO;
    CGFloat hight = 180;
    
    CGFloat margin = 10;
    CGFloat TopPadding = SCREEN_HEIGHT * 0.14;
    CGFloat contentW =width -  margin *2 ;
    
    CGFloat titleH = 50;
    CGFloat textviewH = 80;
    CGFloat paddingX = (SCREEN_WIDTH - width) / 2;
    
    UIView *alert = [[UIView alloc]init];
    alert.backgroundColor =[UIColor whiteColor] ;
    alert.frame = CGRectMake(paddingX, TopPadding , width,hight );
    [self addSubview: alert];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, contentW, titleH)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textColor = GRID_MAIN_TEXT_COLOR;
    self.titleLabel.font = kAlertViewButtonFont;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = title;
    [alert addSubview: self.titleLabel];
    
    self.textView = [[UITextView alloc]init];
    self.textView.frame = CGRectMake(margin, titleH, contentW, textviewH);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = RGBCOLOR(51, 51, 51);
    self.textView.text = text;
    self.textView.font = kAlertViewButtonFont;
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];

    [alert addSubview: self.textView];
    
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin*2, titleH, contentW, 35)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.textColor = PLACEHOLDER_COLOR;
    self.placeholderLabel.font = kAlertViewButtonFont;;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = text.length;
    self.placeholderLabel.text =  NSLocalizedString(@"please_fill_in", nil);
    
    [alert addSubview:self.placeholderLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, titleH +textviewH, alert.frame.size.width/2, titleH)];
    [cancelBtn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:(kAlertViewButtonTextColor ? kAlertViewButtonTextColor : [UIColor darkGrayColor]) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = kAlertViewButtonFont;
    
    CALayer *RightBorder = [CALayer layer];
    RightBorder.frame = CGRectMake(cancelBtn.frame.size.width, 0, 1, cancelBtn.frame.size.height);
    RightBorder.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [cancelBtn.layer addSublayer:RightBorder];
    
    [alert addSubview:cancelBtn];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(alert.frame.size.width/2, titleH +textviewH, alert.frame.size.width/2, titleH)];
    [confirmBtn setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(comfirm:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:(kAlertViewButtonTextColor ? kAlertViewButtonTextColor : [UIColor darkGrayColor]) forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = kAlertViewButtonFont;
    
    [alert addSubview:confirmBtn];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor =DETAIL_SEPERATE_LINE_COLOR ;
    line.frame = CGRectMake(0, titleH +textviewH, alert.frame.size.width, 1);
    [alert addSubview: line];
    
}

- (void)comfirm:(id)sender {
    [self removeFromSuperview];
    if (self.textEditBlock) {
        self.textEditBlock(self.textView.text);
    }
}

- (void)cancelBtnClicked:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length > 0)  {
        _placeholderLabel.hidden = YES;
    }else {
        _placeholderLabel.hidden = NO;
    }
}
@end
