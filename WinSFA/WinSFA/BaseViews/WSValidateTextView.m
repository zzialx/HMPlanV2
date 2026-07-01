//
//  WSValidateTextView.m
//  WinSFA
//
//  Created by Stephanie on 16/6/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSValidateTextView.h"
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
#import "WSSplitViewController.h"
#import "WSAcvtScrollView.h"
#import "WSPopViewController.h"

#define K_SYSTEM_KEYBORD_HEIGHT 240.0f


#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)

static CGFloat firstInterval = 0;
static UIScrollView *moveScrollView;
static UIView *moveView;
static CGFloat moveKeyboardHeight;

@interface WSValidateTextView (){
    CGFloat gridY;
    CGFloat gridHeight;
    float interval;
    float lastInterval;
    BOOL isShow;
    NSString *oldValue;
}

@property (nonatomic, assign)BOOL iIsObserver;
@property (nonatomic, strong) WSTextView* textView;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

- (void)addTextEidtingDidEndOnExitAction;

-(void)textFieldDoneEditing:(id)sender;

@end

@implementation WSValidateTextView

@synthesize m_max = _m_max;
@synthesize m_min = _m_min;
@synthesize m_pcs = _m_pcs;
@synthesize m_type = _m_type;
//@synthesize m_numberKeyPad = _m_numberKeyPad;
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
//@synthesize inputdelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self initTextField];
    }
    return self;
}


-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam
{
    self = [super initWithFrame:aRect];
    if(self != nil)
    {
        if(aParam== nil)
            return self;
        if(aParam.pcs != nil)
            _m_pcs = aParam.pcs;
        if(aParam.min != nil)
            _m_min = aParam.min;
        if(aParam.max != nil)
            _m_max = aParam.max;
        if(aParam.tpy != nil)
            _m_type = aParam.tpy;
        
        [self initTextField];
        
        return self;
    }
    return nil;
}

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue
{
    self = [super initWithFrame:aRect];
    if(self != nil)
    {
        if(aParam== nil)
            return self;
        if(aParam.pcs != nil)
            _m_pcs = aParam.pcs;
        if(aParam.min != nil)
            _m_min = aParam.min;
        if(aParam.max != nil)
            _m_max = aParam.max;
        if(aParam.tpy != nil)
            _m_type = aParam.tpy;
        if (aParam.col != nil) {
            _m_col = aParam.col;
        }
        
        _m_maxValue=maxValue;
        
        if (aParam.alert != nil) {
            _m_alert = aParam.alert;
        }
        
        [self initTextField];
        
        return self;
    }
    return nil;
}

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue isLastText:(BOOL)isLastText{
    self = [super initWithFrame:aRect];
    if(self != nil)
    {
        if(aParam== nil)
            return self;
        if(aParam.pcs != nil)
            _m_pcs = aParam.pcs;
        if(aParam.min != nil)
            _m_min = aParam.min;
        if(aParam.max != nil)
            _m_max = aParam.max;
        if(aParam.tpy != nil)
            _m_type = aParam.tpy;
        _isLastText = isLastText;
        if (aParam.alert != nil) {
            _m_alert = aParam.alert;
        }
        _m_maxValue=maxValue;
        
        [self initTextField];
        
        return self;
    }
    return nil;
    
}
- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param *)aParam maxValue:(float)maxValue row:(unsigned int)aRow column:(unsigned int)aColumn{
    self = [super initWithFrame:aRect];
    if(self != nil)
    {
        if(aParam== nil)
            return self;
        if(aParam.pcs != nil)
            _m_pcs = aParam.pcs;
        if(aParam.min != nil)
            _m_min = aParam.min;
        if(aParam.max != nil)
            _m_max = aParam.max;
        if(aParam.tpy != nil)
            _m_type = aParam.tpy;
        
        _m_nRow = aRow;
        _m_nColumn = aColumn;
        
        [self initTextField];
        
        return self;
    }
    return nil;
    
}
-(id)initWithFrame:(CGRect)aRect Qst:(WSAcvtBean_qst*)aQst
{
    self = [super initWithFrame:aRect];
    if(self)
    {
        if(aQst==nil)
            return self;
        if(aQst.dlen != nil)
            _m_pcs = aQst.dlen;
        if(aQst.mnum != nil) //最大值
            _m_max = aQst.mnum;
        if(aQst.snum != nil) //最小值
            _m_min = aQst.snum;
        if(aQst.qstType != nil)
            _m_type  = aQst.qstType;
        if(aQst.mlen != nil)
            _m_length = aQst.mlen;
        
        [self initTextField];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect) aRect FuncsOther:(WSFuncsBean_other *)aOther
{
    self = [super initWithFrame:aRect];
    if(self)
    {
        if(aOther==nil)
            return self;
        if(aOther.pcs != nil)
            _m_pcs = aOther.pcs;
        if(aOther.max != nil) //最大值
            _m_max = aOther.max;
        if(aOther.min != nil) //最小值
            _m_min = aOther.min;
        if(aOther.tpy != nil)
            _m_type  = aOther.tpy;
        if(aOther.max != nil) {
            _m_length = aOther.max;
        }
        
        [self initTextField];
        
    }
    return self;
}

- (void)initTextField
{
    
    [self addTextEidtingDidEndOnExitAction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    //
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textEditEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textEditBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];

    _isNeedValidateText = YES;
    
    firstInterval = 0;
    moveKeyboardHeight = 0;
    moveScrollView = nil;
    [self initKeyBoard];
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        NSMutableString *formatStr;
        if ([self.m_pcs integerValue] > 0) {
            formatStr = [NSMutableString stringWithString:@"0."];
            for (int i = 0; i < [self.m_pcs integerValue]; i++) {
                [formatStr appendString:@"0"];
            }
        }else {
            formatStr = [NSMutableString stringWithString:@"0"];
        }
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        [numberFormatter setPositiveFormat:formatStr];
        
        self.numberFormatter = numberFormatter;
        
    }
    
    //MN-2208 2018-04-27
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, MAIN_CELL_HEIGHT)];
//    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.textAlignment = NSTextAlignmentRight;
    self.placeholderLabel.textColor = PLACEHOLDER_COLOR;
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = self.text.length;
    
    [self addSubview:self.placeholderLabel];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self.placeholderLabel setFont:font];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self.placeholderLabel setTextAlignment:textAlignment];
}

- (void)setText:(NSString *)text
{
    NSString *formatString = text;
    
    if ([text length] > 0 && [self.m_type isEqualToString:COL_TYPNUM] && self.numberFormatter) {
        
        double doubleValue;
        if ([text rangeOfString:@","].location != NSNotFound) {
            doubleValue = [[self.numberFormatter numberFromString:text] doubleValue];
        }else {
            doubleValue = [text doubleValue];
        }
        
        formatString = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
    }
    
    //SFA-21349
    if([self isFirstResponder] == NO)
        (text.length <= 0) ? (_placeholderLabel.hidden = NO) : (_placeholderLabel.hidden = YES);
    
    [super setText:formatString];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;
    if (!placeholder) {
        _placeholderLabel.hidden = YES;
    }
}


- (void)updateTextField:(id)sender
{
    NSNotification *notification = (NSNotification *)sender;
    NSNumber *isEnable = (NSNumber *)notification.object;
    [self endEditing:[isEnable boolValue]];
}

- (void)initKeyBoard {
    
//    WSUpKeyBoardView *keyBoradView =[[WSUpKeyBoardView alloc] initWithFrame:CGRectMake(0, 0, self.width, UI_KEYBOARD_VIEW_HEIGHT)];
//    
//    self.upKeyBoardView = keyBoradView;
//    
//    UIButton* cButton = keyBoradView.cancelButton;
//    
//    if([self.viewController isKindOfClass:[BaseViewController class]]){
//        [cButton addTarget:self.viewController action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }else{
//        [cButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }
//    UIButton* oButton = keyBoradView.finishButton;
//    if([self.viewController isKindOfClass:[BaseViewController class]]){
//        [oButton addTarget:self.viewController action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }else{
//        [oButton addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }
//    
//    
//    [keyBoradView.zoomInButton removeFromSuperview];
//    
//    self.inputAccessoryView= self.upKeyBoardView;
    
//    if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
//        for(UIButton* button in self.inputAccessoryView.subviews){
//            switch (button.tag) {
//                case 99:
//                    [button setTitle:NSLocalizedString(@"zoom_in", nil) forState:UIControlStateNormal];
//                    break;
//                case 100:
//                    [button setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
//    
    /**
     *  数字类型，手机电话号码类型不显示放大按钮。
     */
    if(!([self.m_type isEqualToString:COL_TYPNUM] || [self.m_type isEqualToString:QST_TYPE_M]) ){
        for(UIButton* button in self.inputAccessoryView.subviews){
            if(button.tag==99){
                button.hidden=NO;
                [button addTarget:self action:@selector(lagerButton:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    self.textAlignment = NSTextAlignmentLeft;
    
    if (self.m_type != nil && [self.m_type isEqualToString:COL_TYPNUM]) {
        //支持小数和负数
        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }else if ([self.m_type isEqualToString:QST_TYPE_M]){
        
        self.keyboardType = UIKeyboardTypePhonePad;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)okButton:(id)sender
{
    LogTrace();
    @try {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    @catch (NSException *exception) {
        LogError(@"=MY EXCEPTION=>>>> %@",exception);
    }
    @finally {
        
    }
    
    
    
}

-(void)cancelButton:(id)sender{
    
    
    @try {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"=MY EXCEPTION=>>>> %@",exception);
    }
    @finally {
        
    }
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if(self.textView){
        [self.textView resignFirstResponder];
        [self.textView removeFromSuperview];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    calling_count++;
    
    if (![self isFirstResponder]) {
        return;
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
    CGPoint pointInRootVC = [[self superview] convertPoint:self.origin toView:toView];
    
    // SFA-5966
//    if (INTERFACE_IS_PAD && IOS7_OR_LATER && !IOS9_OR_LATER) {
//        pointInRootVC = CGPointMake(pointInRootVC.y, pointInRootVC.x);
//    }
    
    UIViewController *transformParentViewController;
    NSInteger transformCount = 0;
    if (INTERFACE_IS_PAD && !IOS7_OR_LATER) {
        UIViewController *tempCon = viewController;
        
        //        if ([viewController.parentViewController isKindOfClass:[WSPopViewController class]]) {
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
//                break;
            }else {
                tempCon = tempCon.parentViewController;
            }
        }
        
        if (!CGAffineTransformEqualToTransform(transformParentViewController.presentingViewController.view.transform, CGAffineTransformIdentity) && ![transformParentViewController.presentingViewController isKindOfClass:[WSSplitViewController class]]) {
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
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
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
    
    interval =  (rootViewHeight - keyBoardHeight) - pointInRootVC.y - newHeight;
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME object:self userInfo:@{WS_KEYBORD_HEIGTH:[NSNumber numberWithFloat:keyBoardHeight],WS_ACVT_VIEW_MOVE_HEIGHT:[NSNumber numberWithFloat:interval]}];
    
    /*需要优化*/
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
    
    if ([tempView isKindOfClass:[WSAcvtScrollView class]]) {
        WSAcvtScrollView *acvtScrollView = (WSAcvtScrollView *)tempView;
        WSAcvtScrollView *subScrollView = [acvtScrollView getSubScrollView];
        if (subScrollView) {
            tempView = subScrollView;
        }
    }
    
    
    if (isShow) {
        if (tempView) {
            if (keyBoardHeight != moveKeyboardHeight) {
                moveScrollView = (UIScrollView *)tempView;
                CGFloat offset = keyBoardHeight - moveKeyboardHeight;
                moveKeyboardHeight = keyBoardHeight;
                
                CGFloat realOffset = interval < 0 ? (lastInterval < 0 ? -offset : interval):0;
                
                
                [self moveScrollView:moveScrollView offset:realOffset moveHeight:offset keyboardHeight:moveKeyboardHeight];
            }
            lastInterval = interval;
        }  else if (moveView) {
            CGRect vcRect = view.frame;
            vcRect.origin.y += interval;
            moveView = view;
            
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 view.frame = vcRect;
                             } completion:nil];
            
            lastInterval = interval + lastInterval;
        }
        
        return;
    }
    
    lastInterval = interval;
    
    isShow = YES;
    
    if (tempView) {
        moveScrollView = (UIScrollView *)tempView;
        if(firstInterval == 0 && interval >=0 ){
            moveKeyboardHeight = keyBoardHeight;
            [self moveScrollView:moveScrollView offset:0 moveHeight:keyBoardHeight keyboardHeight:keyBoardHeight];

            return;
        }
       
        if (firstInterval == 0) {
            firstInterval = interval;
        }else{
            firstInterval = firstInterval + interval;
        }
        moveKeyboardHeight = keyBoardHeight;
        [self moveScrollView:moveScrollView offset:interval moveHeight:keyBoardHeight keyboardHeight:keyBoardHeight];

        return;
    }
//        else if (mm >= 0 && tempView){
//        if (interval<0) {
//            moveView = (UIScrollView *)tempView;
//            if (firstInterval == 0) {
//                firstInterval = interval;
//            }else{
//                firstInterval = firstInterval + interval;
//            }
//            [self moveView:moveView offset:interval];
//        }
//        return;
//        
//    }
    
    //   NSLog(@"textfield = %@ interval = %f" ,self,interval);
    
    if (interval < 0) {
        
        WSBaseGrideViewController* baseGridVC=nil;
        if([viewController isKindOfClass:[WSBaseGrideViewController class]]){
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
        moveView = view;
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             view.frame = vcRect;
                         } completion:^(BOOL finished) {
                             
                         }];
        [compView reDrawGridViewWithY:-interval];
        CGFloat keyboardHeight = 0;
        if (INTERFACE_IS_PHONE) {
            keyboardHeight = keyboardRect.size.height;
        } else if (INTERFACE_IS_PAD) {
            keyboardHeight =  (isNeedFixOrientatin ? keyboardRect.size.width : keyboardRect.size.height);
        }
        // 虚拟键盘上的自定义工具栏高度需要也要减去。
        [compView redrawGridViewWithHeightForKeyboardShow:(view.bounds.size.height -keyboardHeight - 20)];
    }
}

-  (CGRect)changeKeyBordFrame:(CGRect)rect {

    return  rect;
}

// MN-427 改用 IQKeyboardManager
-(void)moveScrollView:(UIScrollView *)view offset:(CGFloat)offset moveHeight:(CGFloat)moveHeight keyboardHeight:(CGFloat)keyboardHeight {
    /*
    CGPoint contentOffset = view.contentOffset;
    contentOffset.y -= offset;
    view.contentOffset = contentOffset;

    if ([view isKindOfClass:[WSAcvtScrollView class]]) {
        ((WSAcvtScrollView *)view).scrollViewChangeHeight = keyboardHeight;
    }
    
    CGSize contentSize = view.contentSize;
    contentSize.height += moveHeight;
    view.contentSize = contentSize;
     */
}

// MN-427 改用 IQKeyboardManager
-(void)moveView:(UIScrollView *)view offset:(CGFloat)offset {
    /*
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGSize contentSize = view.contentSize;
    contentSize.height -= offset;
    view.contentSize = contentSize;
    
    CGPoint contentOffset = view.contentOffset;
    contentOffset.y -= offset;
    view.contentOffset = contentOffset;
    
    [view setContentOffset:contentOffset animated:YES];

    [UIView commitAnimations];
     */
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    isShow = NO;
    
    if (![self isFirstResponder]) {
        return;
    }
    
    if (moveScrollView) {
        
        if (moveKeyboardHeight != 0) {
            [self moveScrollView:moveScrollView offset:0 moveHeight:-moveKeyboardHeight keyboardHeight:-moveKeyboardHeight];
            moveKeyboardHeight = 0;
        }

        moveScrollView = nil;
    } else if (moveView) {
        NSDictionary *userInfo = [notification userInfo];
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        CGRect vcRect = moveView.frame;
        vcRect.origin.y -= lastInterval;
      
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             moveView.frame = vcRect;
                         } completion:nil];

        moveView = nil;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    
    UIViewController *viewController = [self viewController];
    
    WSBaseGrideViewController* baseGridVC=nil;
    
    if([viewController isKindOfClass:[WSBaseGrideViewController class]]){
        baseGridVC=(WSBaseGrideViewController*)viewController;
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


- (BOOL)shouldReplacementString:(NSString *)string inRange:(NSRange)replaceRange{
    
    _isValueChange = YES;
    
    
    if (string.length == 0) {
        return YES;
    }
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        //判断是否为数字
        BOOL isNum = YES;
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isdigit(c)) {
                isNum = NO;
            }
        }
        
        // 支持显示负数与小数
        if (!isNum && ![string isEqualToString:@"."] && ![string isEqualToString:@"-"]) {
            return NO;
        }
        
        if ([string isEqualToString:@"."]) {
            if (_m_pcs.intValue == 0) { //整数
                return NO;
            }
            if (self.text.length == 0) {
                return NO;
            } else {
                NSRange range = [self.text rangeOfString:@"."];
                if (range.length > 0) {
                    return NO;
                }
            }
        }
        
        NSString *valueString1 = [self.text stringByReplacingCharactersInRange:replaceRange withString:string];
        NSRange range = [valueString1 rangeOfString:@"."];
        if (range.length > 0) {
            
            //            NSInteger pcs = self.text.length - range.location - 1;
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
        
        //判断先输入数字然后前面插入0,在输入小数点或者其它整数的问题
        if (valueString != nil && [valueString length] > 1) {
            if ([valueString hasPrefix:@"0"]) {
                if (![valueString hasPrefix:@"0."]) {
                    return NO;
                }
            }
        }
        
        float value = valueString.floatValue;
        NSLog(@"_m_max.floatValue---%f",_m_max.floatValue);
        /*且_m_max配置的不是表达式*/
        if ([_m_max length] > 0 && ![_m_max isEqualToString:@"0"] && value > _m_max.floatValue && !([_m_max rangeOfString:@"{"].location != NSNotFound)) {
            // 最大输入数字的提示根据服务端配置的m_max来显示的
            NSString *title = [NSString stringWithFormat:@"%@ %@:%.2lf", self.iColumnName, NSLocalizedString(@"input_number_max", nil), [self.m_max floatValue]];
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

            return NO;
        }
        
        if (_m_alert != nil && _m_maxValue > 0) {
            float alertValue = [_m_alert floatValue];
            if (value < (1 - alertValue) * _m_maxValue || value > (1 + alertValue) * _m_maxValue) {
                self.textColor = [UIColor redColor];
            }
            else
            {
                self.textColor = [UIColor blackColor];
            }
        }
        
    }else if ([self.m_type isEqualToString:COL_TYPTEXT]){
        
        if(self.m_isGride){
            BOOL isAllowInput = YES;
            for (int i = 0; i < string.length; i++) {
                unichar c = [string characterAtIndex:i];
                if (!isnumber(c) && !isalpha(c)) {
                    isAllowInput = NO;
                }
            }
            return isAllowInput;
        }else{
            return YES;
        }
        
    }else if([self.m_type isEqualToString:QST_TYPE_M]){
        
        BOOL isAllowInput = YES;
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isnumber(c)) {
                isAllowInput = NO;
            }
        }
        //手机电话号码首位数字必须是1 跟随android规则
        if (replaceRange.location < 1
            && ![string isEqualToString:@"1"]) {
            
            isAllowInput = NO;
        }
        //手机电话号码长度大于11位不许输入 跟随android规则
        if (replaceRange.location > 10 ) {
            
            isAllowInput = NO;
        }
        
        return isAllowInput;
    }
    
    
    return YES;
}

- (BOOL)becomeFirstResponder
{
    BOOL ret = [super becomeFirstResponder];
    if (self.m_type != nil && [self.m_type isEqualToString:COL_TYPNUM]) {
        // 支持小数点 和负数
        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
        //        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        
    }
    return ret;
}


- (NSString*) generateStr:(int) i
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:@">"];
    do {
        [str insertString:@"-" atIndex:0];
        --i;
    } while (i > 0);
    
    return str;
}

- (void)lagerButton:(id)sender {
    
}

- (BOOL)validateText:(NSString *)text
{
    
    if (text.length == 0) {
        return YES;
    }
    
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        
        NSInteger numberOfPoint = 0, numberofMinus = 0;
        
        for (int i = 0; i < text.length; i++) {
            unichar c = [text characterAtIndex:i];
            
            if (!isdigit(c) ) {
                
                if (c == '.') {
                    numberOfPoint++;
                }else if (c == '-') {
                    numberofMinus++;
                }else {
                    return NO;
                }
                
                if ([self.m_pcs integerValue] > 0) {  //小数
                    if (numberOfPoint > 1 || numberofMinus > 1) {
                        return NO;
                    }
                }else {   //整数
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
        /*self.m_max不能是表达式*/
        if ([self.m_max length] > 0 && ![self.m_max isEqualToString:@"0"] && value > self.m_max.floatValue  && !([self.m_max rangeOfString:@"{"].location != NSNotFound && [self.m_max rangeOfString:@"}"].location != NSNotFound)) {
            // 最大输入数字的提示根据服务端配置的m_max来显示的
            title = [NSString stringWithFormat:@"%@ %@:%.2lf", self.iColumnName, NSLocalizedString(@"input_number_max", nil), [self.m_max floatValue]];
        }
//        SFA-21618
//        【diageo】本月截至至今销售--当前月填写多次，第二次不得小于第一次填写
//        else if (value < self.m_min.floatValue) {
//            title = [NSString stringWithFormat:@"%@ %@:%.2lf", self.iColumnName, NSLocalizedString(@"input_number_min", nil), [self.m_min floatValue]];
//        }
        
        if (title) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
        
        if (_m_alert != nil && _m_maxValue > 0) {
            float alertValue = [_m_alert floatValue];
            if (value < (1 - alertValue) * _m_maxValue || value > (1 + alertValue) * _m_maxValue) {
                self.textColor = [UIColor redColor];
            }
            else
            {
                self.textColor = [UIColor blackColor];
            }
        }
        
    }else if ([self.m_type isEqualToString:COL_TYPTEXT]){
        
        if(self.m_isGride){
            for (int i = 0; i < text.length; i++) {
                unichar c = [text characterAtIndex:i];
                if (!isnumber(c) && !isalpha(c)) {
                    return NO;
                }
            }
        }
        
    }else if([self.m_type isEqualToString:QST_TYPE_M]){
        
        for (int i = 0; i < text.length; i++) {
            unichar c = [text characterAtIndex:i];
            if (!isnumber(c)) {
                return NO;
            }
        }
        //手机电话号码首位数字必须是1 跟随android规则
        if ([text length] > 0 && [text characterAtIndex:0] != '1') {
            return NO;
        }
        //手机电话号码长度大于11位不许输入 跟随android规则
        if ([text length] > 11 ) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - WSValidateData protocal
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
    
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
    
    if (self.iDataType == WSValidateDataIsDepended) {
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
        NSNumber *number = nil;
        if (self.text && [self.text length] > 0) {
            number = [NSNumber numberWithBool:YES];
        }else{
            number = [NSNumber numberWithBool:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
        
        self.iIsObserver = YES;
    }
    
    
}

- (void)textChanged:(NSNotification *) notification
{
    if ([notification object] == self) {
        if ([[notification object] isKindOfClass:[WSHTextField class]]) {
            WSHTextField *textfield = (WSHTextField *)[notification object];
            
            if (self.iDataType == WSValidateDataIsDepended) {
                NSNumber *number = nil;
                if (textfield.text && [textfield.text length] > 0) {
                    number = [NSNumber numberWithBool:YES];
                }else{
                    number = [NSNumber numberWithBool:NO];
                }
                
                NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
            }
            
            if (_isNeedValidateText && ![self validateText:textfield.text]) {
                textfield.text = oldValue;
            }
            
            oldValue = textfield.text;
        }
    }
}

- (BOOL)isValueChange {
    return _isValueChange;
}


- (void)updateState:(NSNotification *)sender
{
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        if (!isEnable) {
            self.text = nil;
        }
        [self setEnabled:isEnable];
        
    }
}

- (void)setEnabled:(BOOL)enabled{
    [self setUserInteractionEnabled:enabled];
}

- (BOOL)isEnabled {
    return self.userInteractionEnabled;
}

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}

- (NSString *)getTextValue
{
    if ([self.m_type isEqualToString:COL_TYPNUM]) {
        return [self.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }else {
        return self.text;
    }
}

- (BOOL)isValueLegal
{
    return self.text != nil && [self.text length] > 0;
}

// 点击键盘done/完成  键盘消失
- (void)addTextEidtingDidEndOnExitAction {
//    [self addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
}


-(void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


-(BOOL)textCheck
{
    if ([self isNullText]) {
        return YES;
    }
    
    //校验数据
    if (![self validateText:self.text]) {
        [self becomeFirstResponder];
        return NO;
    }
    
    //正则校验
    if (![self textContentRegularCheck]) {
        [self becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

/**
 *  正则校验
 *
 *  @return
 */
- (BOOL) textContentRegularCheck
{
    if (!self.m_reg
        || [self.m_reg length] < 1) {
        return YES;
    }
    
    @try {
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.m_reg];
        
        if(![pred evaluateWithObject:self.text] ){
            
            // 最大输入数字的提示根据服务端配置的m_max来显示的
            NSString *title = [NSString stringWithFormat:@"%@", self.m_regname];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    @catch (NSException *exception) {
        LogError(@"exception = %@" ,exception);
        NSString *title = NSLocalizedString(@"reg_error", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
    
    return  YES;
    
}

/**
 *  最大最小值校验
 *
 *  @return
 */
//经查svn记录此方法在2015年10月就把原来调用此方法的地方屏蔽了，现在也没有地方调用，所以先屏蔽掉如果有项目调用可以再打开
//- (BOOL) textContentMaxAndMinCheck
//{
//
//    if ([self.m_type isEqualToString:COL_TYPNUM]) {
//
//        if (self.m_max
//            && [self.m_max length] > 0
//             && ![self.m_max isEqualToString:@"0"] && [self.text floatValue] > [self.m_max floatValue]) {
//
//            NSString *title = NSLocalizedString(@"input_number_max", nil);
//            // 最大输入数字的提示根据服务端配置的m_max来显示的
//            title = [NSString stringWithFormat:@"%@:%.2lf", title, [self.m_max floatValue]];
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            return NO;
//        }
//
//        if (self.m_min
//            && [self.m_min length] > 0
//            && [self.text floatValue] < [self.m_min floatValue]) {
//
//            NSString *title = NSLocalizedString(@"input_number_min", nil);
//            // 最小输入数字的提示根据服务端配置的m_mix来显示的
//            title = [NSString stringWithFormat:@"%@:%.2lf", title, [self.m_min floatValue]];
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            return NO;
//        }
//    }
//
//    return YES;
//
//}

/**
 *  是否为空文本,对非必填空文本不做任何校验
 *
 *  @return
 */
-(BOOL) isNullText
{
    //去除字符串左右空格
    BOOL old = self.isNeedValidateText;
    self.isNeedValidateText = NO;
    self.text =  [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.isNeedValidateText = old;
    
    //空串或者nil则直接返回
    if (!self.text
        || [self.text length] < 1) {
        return YES;
    }
    
    return NO;
}

- (NSString *)m_length
{
    return [_m_length integerValue] > 0 ? _m_length : nil ;
}

-(void)textEditEnd:(id)sender{
    
//    if ([inputdelegate respondsToSelector:@selector(endCurrentEdit:)]) {
//        
//        
//        [inputdelegate endCurrentEdit:self];
//    }
    
    if (!self.text || [self.text length] == 0) {
        _placeholderLabel.hidden = NO;
    }
    self.editing = NO;

}

-(void)textEditBegin:(id)sender {
    _placeholderLabel.hidden = YES;
    self.editing = YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
//    NSLog(@"action:%@", NSStringFromSelector(action));
    
    if (action == @selector(cut:)) {
        return YES;
    } else if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(paste:)) {
        return YES;
    } else if (action == @selector(select:)) {
        return YES;
    } else if (action == @selector(selectAll:)) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end

