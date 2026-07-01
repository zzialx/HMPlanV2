//
//  WCPullUpViewHelper.m
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCPullUpViewHelper.h"

@implementation WCPullUpViewHelper
@synthesize
handleScrollView = _handleScrollView,
textFieldArray = _textFieldArray,
publicVCObjectView = _publicVCObjectView,
keyboardType = _keyboardType,
delegate = _delegate,
keyboardHeight = _keyboardHeight;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (id)init
{
    self = [super init];
    if (self) {
        
        _warningImageArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        _handleScrollView = [[UIScrollView alloc] init];
        _handleScrollView.contentSize = CGSizeMake(320, [[UIScreen mainScreen] applicationFrame].size.height+35);
        _textFieldArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//#ifdef __IPHONE_5_0
//        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//        if (version >= 5.0) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
//        }
//#endif
    }
    return self;
}

- (UIView *)handleView:(UIView *)vcObjectView
{
    _handleScrollView.frame = CGRectMake(vcObjectView.frame.origin.x, vcObjectView.frame.origin.y, 320, [[UIScreen mainScreen] applicationFrame].size.height);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(disMissKeyboard)];
    
    gestureRecognizer.delegate = self;
    
    [_handleScrollView addGestureRecognizer:gestureRecognizer];
    

    for (UIView *v in vcObjectView.subviews)
    {
        if(v.frame.origin.y > _lastObjectFrame.origin.y)
        {
            _lastObjectFrame = v.frame; //留住页面中y轴最大的控件frame
        }
        
        [_handleScrollView addSubview:v];
        
        if ([v isMemberOfClass:[UITextField class]]) {
            
            UITextField *tf = (UITextField *)v;
            
            UIImageView *failureImage;
            failureImage = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"item_failure"]];
            failureImage.backgroundColor = [UIColor clearColor];
            failureImage.frame = CGRectMake(0, 0, 15, 15);
            failureImage.center = CGPointMake(tf.frame.size.width - 15.5, tf.frame.size.height/2 + 0.5);
            failureImage.hidden = YES;
            [_warningImageArray addObject:failureImage];
            [tf addSubview:failureImage];

            tf.delegate = self;
            
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [_textFieldArray addObject:tf];
        }
        
        if([v isKindOfClass:[UIButton class]] || [v isMemberOfClass:[UIButton class]])
        {
            UIButton *b = (UIButton *)v;
            [b addTarget:self action:@selector(disMissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    [vcObjectView addSubview:_handleScrollView];
    
    _publicVCObjectView = vcObjectView;
    
    return vcObjectView;
}

- (void)addToScrollView:(UIView *)view
{
    [_handleScrollView addSubview:view];
    
    for (UIView *v in view.subviews)
    {
        if ([v isMemberOfClass:[UITextField class]]) {
            
            UITextField *tf = (UITextField *)v;
            
            UIImageView *failureImage;
            failureImage = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"item_failure"]];
            failureImage.backgroundColor = [UIColor clearColor];
            failureImage.frame = CGRectMake(0, 0, 15, 15);
            failureImage.center = CGPointMake(tf.frame.size.width - 15.5, tf.frame.size.height/2 + 0.5);
            failureImage.hidden = YES;
            [_warningImageArray addObject:failureImage];
            [tf addSubview:failureImage];

            tf.delegate = self;
            
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [_textFieldArray addObject:tf];
        }
    }
    _lastObjectFrame = CGRectMake(_lastObjectFrame.origin.x, _lastObjectFrame.origin.y, _lastObjectFrame.size.width, _lastObjectFrame.size.height + view.frame.size.height);
}

- (void)disMissKeyboard
{
    _handleScrollView.frame = CGRectMake(_handleScrollView.frame.origin.x, _handleScrollView.frame.origin.y, 320, [[UIScreen mainScreen] applicationFrame].size.height);
    for (UITextField *tField in _textFieldArray) {
        [tField resignFirstResponder];
    }
    _handleScrollView.contentSize = CGSizeMake(320, [[UIScreen mainScreen] applicationFrame].size.height+35);
}
- (void)disMissKeyboardWithoutResign
{
    _handleScrollView.frame = CGRectMake(_handleScrollView.frame.origin.x, _handleScrollView.frame.origin.y, 320, [[UIScreen mainScreen] applicationFrame].size.height);
    _handleScrollView.contentSize = CGSizeMake(320, [[UIScreen mainScreen] applicationFrame].size.height+35);
}
- (void)traverseAllTextField
{
    for (UITextField *textField in _textFieldArray) {
        if(textField.text.length <= 0)
        {
            for (UIView *v in textField.subviews) {
                if([v isKindOfClass:[UIImageView class]])
                {
                    v.hidden = NO;
                }
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    NSLog(@"textFieldFrame is %@",NSStringFromCGRect(textField.frame));
    CGRect textFieldFrame = [[textField superview] convertRect:textField.frame toView:_handleScrollView];
//    NSLog(@"textFieldFrame is %@",NSStringFromCGRect(textFieldFrame));
    if( (textFieldFrame.origin.y + textFieldFrame.size.height/2 - 100) > 0)
    {
        [_handleScrollView setContentOffset: CGPointMake(_handleScrollView.contentOffset.x,textFieldFrame.origin.y + textFieldFrame.size.height/2 - 100 + 40) animated:YES];
    }
    if([_delegate respondsToSelector:@selector(pullUpViewtextFieldDidBeginEditing:)])
    {
        [_delegate pullUpViewtextFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([_delegate respondsToSelector:@selector(pullUpViewtextFieldDidEndEditing:)])
    {
        [_delegate pullUpViewtextFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    for (UIImageView *imageView in _warningImageArray) {
        imageView.hidden = YES;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([_delegate respondsToSelector:@selector(pullUpViewtextFieldShouldReturn:)])
    {
        [_delegate pullUpViewtextFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark - UIKeyboardNotificationHandler

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    if(keyboardRect.size.height == 216.0f)
    {
        self.keyboardType = keyboard_EnglishType;
    }
    else if(keyboardRect.size.height == 252.0f)
    {
        self.keyboardType = keyboard_ChineseType;
    }
    
    self.keyboardHeight = keyboardRect.size.height;
    
    if((_lastObjectFrame.origin.y + _lastObjectFrame.size.height + 10) <= [[UIScreen mainScreen] applicationFrame].size.height-44-self.keyboardHeight)
    {
        _handleScrollView.contentSize = CGSizeMake(320, [[UIScreen mainScreen] applicationFrame].size.height - 44 - self.keyboardHeight + 10);
    }
    else
    {
        _handleScrollView.contentSize = CGSizeMake(320, _lastObjectFrame.origin.y + _lastObjectFrame.size.height + 10);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _handleScrollView.frame = CGRectMake(_handleScrollView.frame.origin.x, _handleScrollView.frame.origin.y, 320, [[UIScreen mainScreen] applicationFrame].size.height-44-keyboardRect.size.height);
    }];
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self disMissKeyboardWithoutResign];
}
#pragma mark - GestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if([[[UIDevice currentDevice] systemVersion] intValue] <= 4.0)
//    {
//        if ([touch.view isKindOfClass:[UIControl class]]) {
//            return NO;
//        }
//    }
//    else
//    {
//        if ([touch.view isKindOfClass:[UIButton class]]) {
//            
//            return NO;
//        }
//    }
    if ([touch.view isKindOfClass:[UIControl class]] || [[touch.view superview] isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    return YES;
}
@end
