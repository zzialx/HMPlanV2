//
//  WCPullUpViewHelper.h
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    keyboard_ChineseType = 0,
    keyboard_EnglishType = 1
}KeyboardType;

@protocol RSPullUpViewHelperDelegate <NSObject>
@optional
- (BOOL)pullUpViewtextFieldShouldBeginEditing:(UITextField *)textField;
- (void)pullUpViewtextFieldDidBeginEditing:(UITextField *)textField;          
- (BOOL)pullUpViewtextFieldShouldEndEditing:(UITextField *)textField;         
- (void)pullUpViewtextFieldDidEndEditing:(UITextField *)textField;            
- (BOOL)pullUpViewtextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;  
- (BOOL)pullUpViewtextFieldShouldClear:(UITextField *)textField;               
- (BOOL)pullUpViewtextFieldShouldReturn:(UITextField *)textField;

@end

@interface WCPullUpViewHelper : NSObject<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    UIScrollView *_handleScrollView;
    NSMutableArray *_textFieldArray;
    UIView *_publicVCObjectView;
    KeyboardType _keyboardType;

    __weak id<RSPullUpViewHelperDelegate> _delegate;
    
    NSInteger _keyboardHeight;
    
    CGRect _lastObjectFrame;
    
    NSMutableArray *_warningImageArray;
}

@property (nonatomic, retain) UIScrollView *handleScrollView;
@property (nonatomic, retain) NSMutableArray *textFieldArray;
@property (nonatomic, retain) UIView *publicVCObjectView;
@property (nonatomic) KeyboardType keyboardType;
@property (nonatomic, weak) id<RSPullUpViewHelperDelegate> delegate;
@property (nonatomic, assign) NSInteger keyboardHeight;

- (UIView *)handleView:(UIView *)vcObject;
- (void)addToScrollView:(UIView *)view;
- (void)traverseAllTextField;
@end
