//
//  WCHTextField.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSHTextField.h"
#import "WSFuncsBean_other.h"
#import "WSSpecialAcvtViewController.h"
#import "WSTextView.h"
#import "BaseViewController.h"
#import "WSFuncsBean_opt.h"
#import "WSAppDelegate.h"
#import "WSBaseGrideViewController.h"
#import "DataGridComponent.h"
#import "WSProdGrideViewController.h"
#import "WSUpKeyBoardView.h"
#import "WidgetConstant.h"
#import <UIKit/UIKit.h>
#import "WSEnvrionment.h"
#import "WSPopViewController.h"
#import "WSSplitViewController.h"
#import "WSAcvtScrollView.h"
#import "WSAcvtViewForGridPanel.h"
#import "IQKeyboardManager.h"
#import "WSTextViewEditTool.h"
#import "WSGridTextField.h"

#define K_SYSTEM_KEYBORD_HEIGHT 240.0f
#define isIPhone4               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)

static CGFloat firstInterval = 0;
static UIScrollView *moveView;
static CGFloat moveKeyboardHeight;
//================================================================================================================================================================================================

@interface WSHTextField () {
    CGFloat gridY;
    CGFloat gridHeight;
    float interval ;
    float lastInterval;
    BOOL isShow;
    NSString *oldValue;
    BOOL isNeedFormatText;
}

@property (nonatomic, copy, readwrite) NSString *untreatedText;
@property (nonatomic, assign) BOOL iIsObserver;
@property (nonatomic, strong) WSTextView *textView;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

- (void)addTextEidtingDidEndOnExitAction;
- (void)textFieldDoneEditing:(id)sender;

@end
//================================================================================================================================================================================================

@implementation WSHTextField
@synthesize m_max = _m_max;
@synthesize m_min = _m_min;
@synthesize m_pcs = _m_pcs;
@synthesize m_type = _m_type;
@synthesize m_isGride = _m_isGride;
@synthesize m_length = _m_length;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;
@synthesize m_isDepended = _m_isDepended;
@synthesize iNotificationPrefix = _iNotificationPrefix;
@synthesize iRow = _iRow;
@synthesize iColumn = _iColumn;
@synthesize iDataType = _iDataType;
@synthesize iIsObserver = _iIsObserver;
@synthesize iDicNotificationName = _iDicNotificationName;
@synthesize iLogicType = _iLogicType;
@synthesize m_maxValue= _m_maxValue;
@synthesize inputdelegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initTextField];
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam {
    
    return [self initWithFrame:aRect Param:aParam isAcvtGrid:NO];
}

- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam isAcvtGrid:(BOOL)isAcvtGrid {
    
    self = [super initWithFrame:aRect];
    if (self) {
        
        if (aParam == nil) {
            return self;
        }
        
        if (aParam.pcs != nil) {
            _m_pcs = aParam.pcs;
        }
        if (aParam.min != nil) {
            _m_min = aParam.min;
        }
        if (aParam.max != nil) {
            
            _m_max = aParam.max;
            if (![aParam.tpy isEqualToString:COL_TYPNUM]) {
                _m_length = aParam.max;
            }
        }
        if (aParam.tpy != nil) {
            _m_type = aParam.tpy;
        }
        
        self.isAcvtGrid = isAcvtGrid;
        
        [self initTextField];

        if (aParam.coljumpinput && [aParam.coljumpinput isEqualToString:@"1"]) {
            [self initCoverButton];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue {
    
    self = [self initWithFrame:aRect Param:aParam];
    if (self != nil) {
        
        _m_maxValue = maxValue;
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue isLastText:(BOOL)isLastText {
    
    self = [self initWithFrame:aRect Param:aParam maxValue:maxValue];
    if (self != nil) {
        
        _isLastText = isLastText;
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param *)aParam maxValue:(float)maxValue row:(unsigned int)aRow column:(unsigned int)aColumn {
    
    self = [self initWithFrame:aRect Param:aParam maxValue:maxValue];
    if (self != nil) {
        
        _m_nRow = aRow;
        _m_nColumn = aColumn;
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect Qst:(WSAcvtBean_qst*)aQst {
    
    self = [super initWithFrame:aRect];
    if (self) {
        
        if (aQst == nil) {
            return self;
        }
        
        if (aQst.dlen != nil) {
            _m_pcs = aQst.dlen;
        }
        if (aQst.mnum != nil) {
            _m_max = aQst.mnum;
        }
        if (aQst.snum != nil) {
            _m_min = aQst.snum;
        }
        if (aQst.qstType != nil) {
            _m_type  = aQst.qstType;
        }
        if (aQst.mlen != nil) {
            _m_length = aQst.mlen;
        }
        if (aQst.reg != nil) {
            _m_reg = aQst.reg;
        }
        if (aQst.displayMode != nil) {
            _m_displayMode = aQst.displayMode;
        }
        
        [self initTextField];
    }
    return self;
}

- (id)initWithFrame:(CGRect) aRect FuncsOther:(WSFuncsBean_other *)aOther {
    
    self = [super initWithFrame:aRect];
    if (self) {
        
        if (aOther == nil) {
            return self;
        }
        
        if (aOther.pcs != nil) {
            _m_pcs = aOther.pcs;
        }
        if (aOther.max != nil) {
            _m_max = aOther.max;
        }
        if (aOther.min != nil) {
            _m_min = aOther.min;
        }
        if (aOther.tpy != nil) {
            _m_type  = aOther.tpy;
        }
        if (aOther.max != nil) {
            _m_length = aOther.max;
        }
        
        [self initTextField];
    }
    return self;
}

- (void)initTextField {
    
    [self addTextEidtingDidEndOnExitAction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditEnd:) name:UITextFieldTextDidEndEditingNotification
                                               object:self];
    _isNeedValidateText = YES;
    isNeedFormatText = YES;
    firstInterval = 0;
    moveView = nil;
    
    [self initKeyBoard];
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
    
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        if (self.m_pcs && self.m_pcs.length) {
            [numberFormatter setMinimumFractionDigits:[self.m_pcs integerValue]];
            [numberFormatter setMaximumFractionDigits:[self.m_pcs integerValue]];
        }
        else {
            [numberFormatter setMaximumFractionDigits:0];
        }
        [numberFormatter setMinimumIntegerDigits:1];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.numberFormatter = numberFormatter;
    }
}

- (void)initCoverButton {
    
    UIButton *button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

- (void)buttonClick:(id)sender {
    
    WSTextViewEditTool *tool = [[WSTextViewEditTool alloc]initWithFrame:[UIScreen mainScreen].bounds andText:self.text title:_iColumnName];
    tool.textEditBlock = ^(NSString *textStr) {
        [self setText:textStr];
    };
    
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:tool];
}

- (void)setText:(NSString *)text {
    
    NSString *formatString = text;
    if ([text rangeOfString:@","].location == NSNotFound) {
        self.untreatedText = text;
    }
    
    if (isNeedFormatText && [text length] > 0 && [self.m_type isEqualToString:COL_TYPNUM] && self.numberFormatter) {
        
        double doubleValue;
        if ([text rangeOfString:@","].location != NSNotFound) {
            doubleValue = [[self.numberFormatter numberFromString:text] doubleValue];
        }
        else {
            doubleValue = [text doubleValue];
        }

        if ([self.m_displayMode isEqualToString:QST_DISPLAYMODE_QUARTILE] || self.m_isGride) {
            formatString = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
        }
        else {
            
            NSInteger pcs = [self.m_pcs integerValue];
            if (pcs > 0) {
                NSString *pcsString = [NSString stringWithFormat:@"%%.%ldf", pcs];
                formatString = [NSString stringWithFormat:pcsString, doubleValue];
            }
            else {
                formatString = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
            }
        }
        
        if ([formatString isEqualToString:@"-0"]) {
            formatString = @"0";
        }
    }
    
    [super setText:formatString];
}

- (void)updateTextField:(id)sender {
    
    NSNotification *notification = (NSNotification *)sender;
    NSNumber *isEnable = (NSNumber *)notification.object;    
    [self endEditing:[isEnable boolValue]];
}

- (void)initKeyBoard {

    if (!([self.m_type isEqualToString:COL_TYPNUM] || [self.m_type isEqualToString:QST_TYPE_M])) {
        
        for (UIButton* button in self.inputAccessoryView.subviews) {
            
            if (button.tag == 99) {
                button.hidden = NO;
                [button addTarget:self action:@selector(lagerButton:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    self.textAlignment = NSTextAlignmentLeft;
    
    if (self.isLastText == YES) {
        self.returnKeyType = UIReturnKeyDone;
    }
    else if (self.isLastText == NO) {
        self.returnKeyType = UIReturnKeyNext;
    }
    else {
        self.returnKeyType = UIReturnKeyDone;
    }
    
    if (self.m_type != nil && [self.m_type isEqualToString:COL_TYPNUM]) {
        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([self.m_type isEqualToString:QST_TYPE_M] && !([_m_reg length] > 0)){
        self.keyboardType = UIKeyboardTypePhonePad;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)okButton:(id)sender {
    
    @try {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [self endEditing:YES];
        [self resignFirstResponder];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)cancelButton:(id)sender {
    
    @try {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.textView) {
        [self.textView resignFirstResponder];
        [self.textView removeFromSuperview];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    calling_count++;
    
    if (![self isFirstResponder]) {
        return;
    }
    
    NSString * keyBoardIsShow = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyBoardIsShow"];
    if ([keyBoardIsShow isEqualToString:@"1"]) {
        isShow = YES;
    }
    else {
        isShow = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"keyBoardIsShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    
    UIView *toView = nil;
    UIViewController *viewController = [self viewController];
    if ([viewController.parentViewController isKindOfClass:[WSPopViewController class]]) {
        rootViewController = viewController.parentViewController;
        toView = rootViewController.view;
    }
    
    UIView *view = viewController.view;
    CGFloat  contentViewOffsetY = 0;
    for (UIView *subview in viewController.view.subviews) {
        
        if ([subview isKindOfClass:[WSAcvtViewForGridPanel class]]) {
            
            WSAcvtViewForGridPanel *gridPanel = (WSAcvtViewForGridPanel *)subview;
            toView = [gridPanel getCenterView];
            view = [gridPanel getCenterView];
            contentViewOffsetY = view.origin.y + UI_NAVIGATION_BAR_HEIGHT + UI_STATUS_BAR_HEIGHT;
            break;
        }
    }
    
    CGPoint pointInRootVC = [[self superview] convertPoint:self.origin toView:toView];
    UIViewController *transformParentViewController;
    NSInteger transformCount = 0;
    if (INTERFACE_IS_PAD && !IOS7_OR_LATER) {
        
        UIViewController *tempCon = viewController;
        BOOL needFixTransform = YES;
        UIViewController *parentPresenting = viewController.parentViewController.presentingViewController;
        if ([parentPresenting isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nav = (UINavigationController *)parentPresenting;
            if ([[nav viewControllers] count] > 1) {
                needFixTransform = NO;
            }
        }
        
        while (tempCon.parentViewController && needFixTransform) {
            
            if (!CGAffineTransformEqualToTransform(tempCon.parentViewController.view.transform, CGAffineTransformIdentity)) {
                
                transformParentViewController = tempCon.parentViewController;
                tempCon = tempCon.parentViewController;
                transformCount++;
            }
            else {
                tempCon = tempCon.parentViewController;
            }
        }
        
        if (!CGAffineTransformEqualToTransform(transformParentViewController.presentingViewController.view.transform, CGAffineTransformIdentity) &&
            ![transformParentViewController.presentingViewController isKindOfClass:[WSSplitViewController class]]) {
            transformCount++;
        }
    }
    
    CGFloat newHeight = self.frame.size.height;
    if (transformParentViewController && transformCount == 1) {
        
        CGRect rect = [[self superview] convertRect:self.frame toView:rootViewController.view];
        rect = CGRectApplyAffineTransform(rect, transformParentViewController.view.transform);
        pointInRootVC = rect.origin;
        if (pointInRootVC.y < 0) {
            pointInRootVC.y = -pointInRootVC.y - newHeight;
        }
    }
    
    BOOL isNeedFixOrientatin = NO;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        isNeedFixOrientatin = YES;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        isNeedFixOrientatin = NO;
    }
#endif

    keyboardRect = [self changeKeyBordFrame:keyboardRect];
    CGFloat rootViewHeight = rootViewController.view.height;
    if (!CGAffineTransformEqualToTransform(rootViewController.view.transform, CGAffineTransformIdentity)) {
        
        rootViewHeight = rootViewController.view.width;
    }
    
    CGFloat keyBoardHeight = isNeedFixOrientatin ? keyboardRect.size.width : keyboardRect.size.height;
    keyBoardHeight += UI_KEYBOARD_VIEW_HEIGHT;
    interval = (rootViewHeight - keyBoardHeight) - pointInRootVC.y - newHeight - contentViewOffsetY;

    CGFloat mm = 0;
    UIView * tempView = nil;
    for (UIView *temp in view.subviews) {
        
        if ([temp isKindOfClass:[UIScrollView class]]) {
            
            UIScrollView *scrollview = (UIScrollView*)temp;
            if (scrollview.contentOffset.y >= 0) {
                mm = scrollview.contentOffset.y;
                tempView = scrollview;
            }
        }
    }
    
    if (isShow) {
        
        if (keyBoardHeight != moveKeyboardHeight) {
            
            moveView = (UIScrollView *)tempView;
            CGFloat offset = keyBoardHeight - moveKeyboardHeight;
            moveKeyboardHeight = keyBoardHeight;
            
            CGFloat realOffset = interval < 0 ? (lastInterval < 0 ? -offset : interval):0;
            [self moveScrollView:moveView offset:realOffset moveHeight:offset keyboardHeight:moveKeyboardHeight];
        }
        
        lastInterval = interval;
        return;
    }
    
    lastInterval = interval;
    
    if (tempView) {
        
        moveView = (UIScrollView *)tempView;
        if (firstInterval == 0 && interval >= 0) {
            
            moveKeyboardHeight = keyBoardHeight;
            [self moveScrollView:moveView offset:0 moveHeight:keyBoardHeight keyboardHeight:keyBoardHeight];
            return;
        }
        
        if (firstInterval == 0) {
            firstInterval = interval;
        }
        else {
            firstInterval = firstInterval + interval;
        }
        
        moveKeyboardHeight = keyBoardHeight;
        [self moveScrollView:moveView offset:interval moveHeight:keyBoardHeight keyboardHeight:keyBoardHeight];
        return;
    }

    if (interval < 0) {
        
        WSBaseGrideViewController* baseGridVC = nil;
        if ([viewController isKindOfClass:[WSBaseGrideViewController class]]) {
            baseGridVC=(WSBaseGrideViewController*)viewController;
        }
        
        DataGridComponent *compView = nil;
        for (UIView *view in [baseGridVC.contentScrollView subviews]) {
            if ([view isKindOfClass:[DataGridComponent class]]) {
                compView = (DataGridComponent *)view;
                break;
            }
        }
        
        CGRect vcRect = view.frame;
        vcRect.origin.y += interval;
        [UIView animateWithDuration:animationDuration animations:^{
            view.frame = vcRect;
        }
                         completion:^(BOOL finished) {
        }];
        
        [compView reDrawGridViewWithY:-interval];
        
        CGFloat keyboardHeight = 0;
        if (INTERFACE_IS_PHONE) {
            keyboardHeight = keyboardRect.size.height;
        }
        else if (INTERFACE_IS_PAD) {
            keyboardHeight =  (isNeedFixOrientatin ? keyboardRect.size.width : keyboardRect.size.height);
        }

        [compView redrawGridViewWithHeightForKeyboardShow:(view.bounds.size.height -keyboardHeight - 20)];
    }
}

- (CGRect)changeKeyBordFrame:(CGRect)rect {
   
    return rect;
}

- (void)moveScrollView:(UIScrollView *)view offset:(CGFloat)offset moveHeight:(CGFloat)moveHeight keyboardHeight:(CGFloat)keyboardHeight {
    
    if ([IQKeyboardManager sharedManager].enable) {
    }
    else {
        
        CGPoint contentOffset = view.contentOffset;
        contentOffset.y -= offset;
        view.contentOffset = contentOffset;
        
        if ([view isKindOfClass:[WSAcvtScrollView class]]) {
            ((WSAcvtScrollView *)view).scrollViewChangeHeight = keyboardHeight;
        }
        
        CGSize contentSize = view.contentSize;
        contentSize.height += moveHeight;
        view.contentSize = contentSize;
    }
}

- (void)moveView:(UIScrollView *)view offset:(CGFloat)offset {
    
    if ([IQKeyboardManager sharedManager].enable) {
    }
    else {
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeView" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        CGPoint contentOffset = view.contentOffset;
        contentOffset.y -= offset;
        view.contentOffset = contentOffset;
        
        CGSize contentSize = view.contentSize;
        contentSize.height -= offset;
        view.contentSize = contentSize;
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    UIViewController *viewController = [self viewController];
    UIView *view = viewController.view;
    UIView *tempView = nil;
    
    for (UIView *temp in view.subviews) {
        if ([temp isKindOfClass:[UIScrollView class]]) {
            
            UIScrollView *scrollview = (UIScrollView*)temp;
            if (scrollview.contentOffset.y >= 0) {
                tempView = scrollview;
            }
        }
    }
    
    if ([tempView isKindOfClass:[WSAcvtScrollView class]]) {
        ((WSAcvtScrollView *)tempView).scrollViewChangeHeight = 0;
        [tempView setNeedsLayout];
    }
    isShow = NO;

    if (![self isFirstResponder]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"keyBoardIsShow"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (moveView) {
        
        if (moveKeyboardHeight != 0) {
            [self moveScrollView:moveView offset:0 moveHeight:-moveKeyboardHeight keyboardHeight:-moveKeyboardHeight];
            moveKeyboardHeight = 0;
        }
        
        moveView = nil;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    WSBaseGrideViewController* baseGridVC = nil;
    if ([viewController isKindOfClass:[WSBaseGrideViewController class]]) {
        baseGridVC = (WSBaseGrideViewController *)viewController;
    }
    
    DataGridComponent *compView = nil;
    for (UIView *view in [baseGridVC.contentScrollView subviews]) {
        
        if ([view isKindOfClass:[DataGridComponent class]]) {
            compView = (DataGridComponent *)view;
            break;
        }
    }
    
    [compView redrawGridViewWithHeightForKeyboardHide];
}

- (BOOL)shouldReplacementString:(NSString *)string inRange:(NSRange)replaceRange {

    _isValueChange = YES;
    
    if (string.length == 0) {
        return YES;
    }
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {

        BOOL isNum = YES;
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isdigit(c)) {
                isNum = NO;
            }
        }

        if (!isNum && ![string isEqualToString:@"."] && ![string isEqualToString:@"-"]) {
            return NO;
        }
        
        if ([string isEqualToString:@"."]) {
            
            if (_m_pcs.intValue == 0) {
                return NO;
            }
            
            if (self.text.length == 0) {
                return NO;
            }
            else {
                NSRange range = [self.text rangeOfString:@"."];
                if (range.length > 0) {
                    return NO;
                }
            }
        }
        
        NSString *valueString1 = [self.text stringByReplacingCharactersInRange:replaceRange withString:string];
        NSRange range = [valueString1 rangeOfString:@"."];
        if (range.length > 0) {

            NSInteger pcs = [valueString1 length] - range.location - 1;
            if (pcs > _m_pcs.intValue) {
                return NO;
            }
        }
        
        NSString *valueString = [self.text stringByReplacingCharactersInRange:replaceRange withString:string];
        if (self.text != nil && [self.text isEqualToString:@"0"]) {
            if (![valueString isEqualToString:@"0."]) {
                
                    self.text = nil;
                    return YES;
            }
        }

        if (valueString != nil && [valueString length] > 1) {
            if ([valueString hasPrefix:@"0"]) {
                if (![valueString hasPrefix:@"0."]) {
                    return NO;
                }
            }
        }
        
        double value = valueString.doubleValue;
        if ([_m_max length] > 0 && ![_m_max isEqualToString:@"0"] && (value > _m_max.doubleValue && !([_m_max rangeOfString:@"{"].location != NSNotFound))) {
    
            NSString *maxValue = [self formatDoubleValueToString:[_m_max doubleValue] andValueToString:valueString];
            NSString *title = [NSString stringWithFormat:@"%@ %@:%@", self.iColumnName, NSLocalizedString(@"input_number_max", nil), maxValue];
    
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:title tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
        
        if (_m_alert != nil && _m_maxValue > 0) {
            
            float alertValue = [_m_alert floatValue];
            if (value < (1 - alertValue) * _m_maxValue || value > (1 + alertValue) * _m_maxValue) {
                self.textColor = [UIColor redColor];
            }
            else {
                self.textColor = [UIColor blackColor];
            }
        }
    }
    else if ([self.m_type isEqualToString:COL_TYPTEXT]) {
        
        if (self.m_isGride) {
            
            BOOL isAllowInput = YES;
            for (int i = 0; i < string.length; i++) {
                unichar c = [string characterAtIndex:i];
                if (!isnumber(c) && !isalpha(c)) {
                    isAllowInput = NO;
                }
            }
            return isAllowInput;
        }
        else {
            return YES;
        }
    }
    else if ([self.m_type isEqualToString:QST_TYPE_M] && !([_m_reg length] > 0)) {
        
        BOOL isAllowInput = YES;
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isnumber(c)) {
                isAllowInput = NO;
            }
        }
        
        if (replaceRange.location < 1 && ![string isEqualToString:@"1"]) {
            isAllowInput = NO;
        }

        if (replaceRange.location > 10 ) {
            isAllowInput = NO;
        }
        
        return isAllowInput;
    }
    
    return YES;
}

- (BOOL)checkMaxValue:(NSString *)valueString {
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        double value = valueString.doubleValue;
        if ([_m_max length] > 0 && ![_m_max isEqualToString:@"0"] && (value > _m_max.doubleValue && !([_m_max rangeOfString:@"{"].location != NSNotFound))) {
     
            NSString *maxValue = [self formatDoubleValueToString:[_m_max doubleValue] andValueToString:valueString];
            WSGridTextField *text;
            if ([self.delegate isKindOfClass:[WSGridTextField class]]) {
                text = (WSGridTextField*)self.delegate;
            }
            
            NSString *title = [NSString stringWithFormat:@"%@ %@ %@:%@",text.prodName, self.iColumnName, NSLocalizedString(@"input_number_max", nil), maxValue];
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)formatDoubleValueToString:(double)doubleValue  andValueToString:(NSString *)valueString {

    NSString *maxValue = valueString;
    if (self.m_pcs && self.m_pcs.length > 0) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf" , (long)[self.m_pcs integerValue]];
        maxValue = [NSString stringWithFormat:formatString, doubleValue];
    }
    else {
         maxValue = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
    }
    return maxValue;
}

- (BOOL)becomeFirstResponder {
    
    BOOL ret = [super becomeFirstResponder];
    if (self.m_type != nil && [self.m_type isEqualToString:COL_TYPNUM]) {
        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    return ret;
}

- (BOOL)resignFirstResponder {
    
    BOOL ret = [super resignFirstResponder];
    return ret;
}

- (NSString*) generateStr:(int)i {
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:@">"];
    do {
        [str insertString:@"-" atIndex:0];
        --i;
    }
    while (i > 0);
    
    return str;
}

- (void)lagerButton:(id)sender {

    if ([inputdelegate respondsToSelector:@selector(scaleCurrentText:)]) {
        [inputdelegate scaleCurrentText:self];
    }
}

- (NSString *)trimTextLength:(NSString *)text {
    
    if (self.m_length && text.length > self.m_length.integerValue) {
        
        NSString *columName = @"";
        if (self.iColumnName) {
            columName = [NSString stringWithFormat:@"%@:", self.iColumnName];
        }
        
        NSString *title = [NSString stringWithFormat:@"%@%@%@个字", columName, NSLocalizedString(@"最多只能输入", nil), self.m_length];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        if (oldValue.length < self.m_length.integerValue) {
            NSInteger trimToIndex = self.m_length.integerValue;
            return [text substringToIndex:trimToIndex];
        }
        
        return oldValue;
    }
    
    return text;
}

- (BOOL)validateText:(NSString *)text {
    
    if (text.length == 0) {
        return YES;
    }
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        NSInteger numberOfPoint = 0, numberofMinus = 0;
        for (int i = 0; i < text.length; i++) {
            
            unichar c = [text characterAtIndex:i];
            if (!isdigit(c)) {
                
                if (c == '.') {
                    numberOfPoint++;
                }
                else if (c == '-') {
                    numberofMinus++;
                }
                else {
                    return NO;
                }
                
                if ([self.m_pcs integerValue] > 0) {
                    if (numberOfPoint > 1 || numberofMinus > 1) {
                        return NO;
                    }
                }
                else {
                    if (numberOfPoint > 0 || numberofMinus > 1) {
                        return NO;
                    }
                }
                
                if (!([self.m_min floatValue] < 0) && numberofMinus > 0) { //正数不允许输入“-”
                    return NO;
                }
            }
        }
        
        if (numberofMinus > 0) {
            
            NSRange minusRange = [text rangeOfString:@"-"];
            if (minusRange.location != NSNotFound && minusRange.location != 0) {
                return NO;
            }
        }
        
        if (numberOfPoint > 0) {
            
            NSRange pointRange = [text rangeOfString:@"."];
            if (pointRange.location != NSNotFound) {
                if (pointRange.location == 0) {
                    return NO;
                }
                
                NSInteger pcs = [text length] - pointRange.location - 1;
                if (pcs > [_m_pcs integerValue]) {
                    return NO;
                }
            }
        }

        float value = [text floatValue];
        NSString *title = nil;
        if ([self.m_max length] > 0 && ![self.m_max isEqualToString:@"0"] && value > self.m_max.floatValue &&
            !([self.m_max rangeOfString:@"{"].location != NSNotFound && [self.m_max rangeOfString:@"}"].location != NSNotFound)) {
            
            title = [NSString stringWithFormat:@"%@ %@:%.2lf", self.iColumnName, NSLocalizedString(@"input_number_max", nil), [self.m_max floatValue]];
        }

        if (title) {
            
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
        
        if (_m_alert != nil && _m_maxValue > 0) {
            
            float alertValue = [_m_alert floatValue];
            if (value < (1 - alertValue) * _m_maxValue || value > (1 + alertValue) * _m_maxValue) {
                self.textColor = [UIColor redColor];
            }
            else {
                self.textColor = [UIColor blackColor];
            }
        }
    }
    else if ([self.m_type isEqualToString:COL_TYPTEXT]) {
        
        if (self.m_isGride) {
            
            for (int i = 0; i < text.length; i++) {
                unichar c = [text characterAtIndex:i];
                if (!isnumber(c) && !isalpha(c)) {
                    return NO;
                }
            }
        }
    }
    else if ([self.m_type isEqualToString:QST_TYPE_M] && !([_m_reg length] > 0)) {
        
        for (int i = 0; i < text.length; i++) {
            unichar c = [text characterAtIndex:i];
            if (!isnumber(c)) {
                return NO;
            }
        }
      
        if ([text length] > 0 && [text characterAtIndex:0] != '1') {
            return NO;
        }
   
        if ([text length] > 11) {
            return NO;
        }
    }
    
    return YES;
}


- (void)setNotificationPrefix:(NSString *)aNotificationPrefix andRow:(unsigned int)aRow andColumn:(unsigned int)aColumn andDataType:(WSValidateDataDependType)aDataType {
    
    if (aNotificationPrefix == nil) {
        return;
    }
    
    if (aDataType == WSValidateDataDependOtherData) {
        
        self.iNotificationPrefix = aNotificationPrefix;
        self.m_nRow = aRow;
        self.m_nColumn = aColumn;
        self.iDataType = aDataType;
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
    else if (aDataType == WSValidateDataDependOtherDataAndIsDepended) {
        
        self.dNotificationPrefix = aNotificationPrefix;
        self.m_dRow = aRow;
        self.m_dColumn = aColumn;
        self.dDataType = aDataType;
    }
}

- (void)startObservingEntity {
    
    if (self.iDataType == WSValidateDataIsDepended) {
        
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
        NSNumber *number = nil;
        if (self.text && [self.text length] > 0) {
            number = [NSNumber numberWithBool:YES];
        }
        else{
            number = [NSNumber numberWithBool:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
        
        self.iIsObserver = YES;
    }
}

- (void)textChanged:(NSNotification *) notification {
    
    if ([notification object] == self) {
        
        if ([[notification object] isKindOfClass:[WSHTextField class]]) {
            
            WSHTextField *textfield = (WSHTextField *)[notification object];
            if (self.m_length && self.m_length.integerValue) {
                [self.undoManager removeAllActions];
            }
            
            if (textfield.markedTextRange == nil) {
                
                NSNumber *number = nil;
                if (textfield.text && [textfield.text length] > 0) {
                    number = [NSNumber numberWithBool:YES];
                }
                else {
                    number = [NSNumber numberWithBool:NO];
                }
                
                if (self.iDataType == WSValidateDataIsDepended) {
                    
                    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
                }
                else if (self.dDataType == WSValidateDataDependOtherDataAndIsDepended) {
                    
                    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.dNotificationPrefix, self.iRow, self.iColumn];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
                }
                
                if (_isNeedValidateText) {
                    
                    isNeedFormatText = NO;
                    textfield.text = [self trimTextLength:textfield.text];
                    if (![self validateText:textfield.text] ) {
                        textfield.text = oldValue;
                    }
                    isNeedFormatText = YES;
                }
                
                oldValue = textfield.text;
            }
        }   
    }
}

- (BOOL)isValueChange {
    
    return _isValueChange;
}

- (void)updateState:(NSNotification *)sender {
    
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && sender.name.length > 0) {
        if (![sender.name isEqualToString:notifyName]) {
            notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.dNotificationPrefix, self.m_dRow, self.m_dColumn];
        }
    }
    
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        if (!isEnable) {
            self.text = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
        }
        [self setEnabled:isEnable];
        
        _isValueChange = YES;
    }
}

- (BOOL)entityIsEnable {
    
    return [self isEnabled];
}

- (NSString *)getTextValue {
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        NSString *text = [self.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        if ([text length] > 0 || self.isAcvtGrid) {
            return text;
        }
        else {
            return @"0";
        }
    }
    else {
        return self.text;
    }
}

- (BOOL)isValueLegal {
    
    return self.text != nil && [self.text length] > 0;
}

- (void)addTextEidtingDidEndOnExitAction {
    
    [self addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)textFieldDoneEditing:(id)sender {
    
    [sender resignFirstResponder];
}

- (BOOL)textCheck {
    
    if ([self isNullText]) {
        return YES;
    }

    if (![self validateText:[self getTextValue]]) {
        [self becomeFirstResponder];
        return NO;
    }
    
    if (![self textContentRegularCheck]) {
        [self becomeFirstResponder];
        return NO;
    }

    return YES;
}

- (BOOL) textContentRegularCheck {
    
    if (!self.m_reg || [self.m_reg length] < 1) {
        return YES;
    }
    
    @try {
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.m_reg];
        if (![pred evaluateWithObject:self.text]) {
            
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            
            NSString *title = [NSString stringWithFormat:@"%@", self.m_regname];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    @catch (NSException *exception) {
        
        NSString *title = NSLocalizedString(@"reg_error", nil);
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }

    return  YES;
}

- (BOOL)isNullText {
    
    BOOL old = self.isNeedValidateText;
    self.isNeedValidateText = NO;
    self.text =  [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.isNeedValidateText = old;
    
    if (!self.text || [self.text length] < 1) {
        return YES;
    }
    return NO;
}

- (NSString *)m_length {
    
    return [_m_length integerValue] > 0 ? _m_length : nil ;
}

- (void)textEditEnd:(id)sender {
 
    NSString *text = self.text;
    [self setText:text];
    
    if ([inputdelegate respondsToSelector:@selector(endCurrentEdit:)]) {
        [inputdelegate endCurrentEdit:self];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(cut:)) {
        return YES;
    }
    else if (action == @selector(copy:)) {
        return YES;
    }
    else if (action == @selector(paste:)) {
        return YES;
    }
    else if (action == @selector(select:)) {
        return YES;
    }
    else if (action == @selector(selectAll:)) {
        return YES;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)clearTextOldValue {
    
    oldValue = @"";
}

@end
//================================================================================================================================================================================================
