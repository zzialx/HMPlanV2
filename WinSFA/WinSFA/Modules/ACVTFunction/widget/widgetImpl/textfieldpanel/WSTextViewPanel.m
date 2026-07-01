//
//  WSTextViewPanel.m
//  WinSFA
//
//  Created by Stephanie on 16/6/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTextViewPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "I_Lua_Target_Operator.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "I_W_DisplayValue.h"
#import "WSStringValueChangeChecker.h"
#import "WSValidateTextView.h"
#import "NSString+Additions.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"

#define kTextViewMaxHeight 300
//================================================================================================================================================================================================

@interface WSTextViewPanel () <UITextViewDelegate>

@property (assign, nonatomic) CGFloat emptyTextViewHeight;
@property (assign, nonatomic) CGFloat lastTextViewHeight;
@property (nonatomic,copy) NSString * checkLuaState;
@end
//================================================================================================================================================================================================

@implementation WSTextViewPanel

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
    }
    return self;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.textView];
}

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    NSString *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if ([xbuildInfo.getQstCode isEqualToString:@"parentFc"]) {
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        displayValue = model.realParentFuncsCode;
    }
    
    UIFont *font = PanelTextFieldFont;
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    int twidth = orientition ? (self.width - CGRectGetMaxX(titleLabel.frame) - MAIN_CELL_PADDING) :(self.width - titleLabel.frame.origin.x * 2);
    int i_xPosition = orientition ? (CGRectGetMaxX(titleLabel.frame)) : titleLabel.frame.origin.x;
    UITextView *tempViewForGetHeight = [[UITextView alloc] init];
    tempViewForGetHeight.font = font;
    if (displayValue && ![displayValue isEqualToString:@""]) {
        tempViewForGetHeight.text = displayValue;
    }
    CGSize fitSize =  [tempViewForGetHeight sizeThatFits:CGSizeMake(twidth, CGFLOAT_MAX)];
    CGFloat theight = fitSize.height;
    if (displayValue && ![displayValue isEqualToString:@""]) {
        
        UITextView *emptyTextView = [[UITextView alloc] init];
        emptyTextView.font = font;
        CGSize displayStrSize = [displayValue stringSizeWithFont:font width:self.width];
        if (xbuildInfo.getGroupName.length > 0 && [xbuildInfo.getGroupName rangeOfString:@"horizontal_group"].location != NSNotFound && titleLabel.frame.size.width <= 0) {
            twidth = displayStrSize.width + MAIN_CELL_PADDING*2;
            i_xPosition = 0.0;
        }
        CGSize fitSize =  [emptyTextView sizeThatFits:CGSizeMake(twidth, CGFLOAT_MAX)];
        CGFloat emptyHeight = fitSize.height;
        self.emptyTextViewHeight = emptyHeight;
    }
    else {
        self.emptyTextViewHeight = theight;
    }
    self.lastTextViewHeight = theight;
    
    int ty = orientition ? 0 : (titleLabel.frame.origin.y + titleLabel.frame.size.height);
    self.textView = [[WSValidateTextView alloc] initWithFrame:CGRectMake(i_xPosition, ty, twidth, theight) Qst:(WSAcvtBean_qst *)xbuildInfo];
    self.textView.font = PanelTextFieldFont;
    self.textView.backgroundColor = [UIColor clearColor];
    if (orientition) {
        self.textView.textAlignment = NSTextAlignmentRight;
        self.textView.contentMode = UIViewContentModeRight;
    }
    else {
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.contentMode = UIViewContentModeLeft;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:self.textView];

    self.textView.delegate = self;
    self.textView.tag = [[xbuildInfo getAcvtQstId] intValue];
    self.textView.iColumnName = [xbuildInfo getQuestName];

    _originalValue = displayValue;
    
    BOOL old = self.textView.isNeedValidateText;
    self.textView.isNeedValidateText = NO;
    self.textView.text = displayValue;
    self.textView.isNeedValidateText = old;
    [self setTextViewContentInset];
    [self addSubview:self.textView];
    
    [self setReadonly:[xbuildInfo getReadOnly]];
    [self refreshTextAndHeight:self.textView.text];
    [self refreshFrame];
    
    if (orientition) {
        CGRect textFieldRect = self.textView.frame;
        [self.textView setFrame:CGRectMake(textFieldRect.origin.x, (self.frame.size.height - textFieldRect.size.height)/2 , textFieldRect.size.width, textFieldRect.size.height)];
    }
}

#pragma mark - 刷新文本框高度方法
- (void)refreshTextAndHeight:(NSString *)text {
    
    CGFloat padding = self.textView.textContainer.lineFragmentPadding;
    CGSize size = [text ws_sizeWithFont:self.textView.font constrainedToWidth:self.textView.frame.size.width - padding * 2];
    //处理 IQKeyboardManager 与嵌套滚动视图的冲突是一个常见问题。当你有 ScrollView 包含 TableView 的嵌套结构时，IQKeyboardManager 可能会错误地调整 TableView 而不是外层的 ScrollView。
    //输入框被遮挡以后，self.textView.contentInset.bottom有bug，之前用这种方法就会引起嵌套问卷的高度计算有问题
//    LogDebug(@"self.textView.contentInset.bottom--->%lf",self.textView.contentInset.bottom);
    CGFloat borderHeight = (self.textView.contentInset.top + 0 + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
    
    size.height += borderHeight;
    if (!FLOAT_IS_EQUAL(size.height, self.lastTextViewHeight)) {
        
        BOOL isPostNotification = NO;
        isPostNotification = YES;
        CGFloat changedHeight = size.height - self.lastTextViewHeight;
        CGFloat height = self.textView.frame.size.height + changedHeight;
        CGRect newFrame = self.textView.frame;
        
        if ([text isEqualToString:@""]) {
            
            height = self.emptyTextViewHeight;
            if (newFrame.origin.y == 0) {
                newFrame.origin.y = (MAIN_CELL_HEIGHT - self.emptyTextViewHeight) / 2;
            }
            isPostNotification = NO;
        }
        newFrame.size.height = height;
        self.textView.frame = newFrame;
        
        if (isPostNotification && self.textView.isFirstResponder) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSNotification *notification = [NSNotification notificationWithName:CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION object:self
                                                                           userInfo:@{WSTEXTVIEWPANEL_CHANGED_HEIGHT:[NSNumber numberWithFloat:changedHeight]}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
        }
    }
    
    self.lastTextViewHeight = size.height;
}

#pragma mark - 刷新边框尺寸方法
- (void)refreshFrame {
    
    CGFloat height = self.textView.frame.origin.y + self.textView.frame.size.height;
    CGFloat paddingY = self.frame.origin.y;
    if (height < MAIN_CELL_HEIGHT) {
        
        if (self.frame.size.height < MAIN_CELL_HEIGHT) {
            paddingY += (MAIN_CELL_HEIGHT - height) / 2;
        }
        height = MAIN_CELL_HEIGHT;
    }
    CGFloat titleHeight = self.titleLabel.height;
    if (height < titleHeight) {
        height = titleHeight;
    }
    if (!([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"])) {
        height += 10;
    }
    
    if ([xbuildInfo isNoInset] && ([[xbuildInfo getAcvtQstType] isEqualToString:@"BO"] ||[[xbuildInfo getAcvtQstType] isEqualToString:@"BQ"] )) {
        
        CGFloat reduceHeight = (self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
        height -= reduceHeight;
        CGRect textFrame = self.textView.frame;
        textFrame.size.height = height;
        self.textView.frame = textFrame;

        if ([self.textView.text length] > 0) {
            [self.textView scrollRangeToVisible:NSMakeRange(0, [self.textView.text length])];
        }
        
        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.size.height = height;
        self.titleLabel.frame = titleFrame;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, paddingY, self.frame.size.width, height)];
}

#pragma mark - 重写getResultDirectly方法
- (NSObject *)getResultDirectly {
    
    if ([self.textView text] && [[self.textView text] length] > 0) {
        
        if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_N]) {
            return [[self.textView text] stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        else {
            return [self.textView text];
        }
    }
    
    return nil;
}

#pragma mark - 重写getResultPresentation方法
- (NSObject *)getResultPresentation {
    
    NSString *value = [self.textView text];
    if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_N]) {
        value = [[self.textView text] stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    return value;
}

#pragma mark - 重写setCurrentValueWithPresentation:方法
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    self.textView.text = valuePresentation;
    
    if (valuePresentation == nil) {
        valuePresentation = @"";
    }
    [self refreshTextAndHeight:valuePresentation];
    [self textChange];
}
#pragma mark - 重写setEndEditCheckLuaState:方法
- (void)setEndEditCheckLuaState:(NSString*)value{
    self.checkLuaState = value;
}
#pragma mark - 重写setReadonly:方法
- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] intValue]) {
        
        self.textView.userInteractionEnabled = NO;
        [self setTextColorStrByHex:[xbuildInfo getAnswerColor] ? [xbuildInfo getAnswerColor] : [xbuildInfo getTextColor]];
        self.textView.placeholder = @"";
    }
    else {
        
        self.textView.userInteractionEnabled = YES;
        self.textView.textColor = PanelTextFieldColor;
        NSString *placeholder;
        if ([[xbuildInfo getQstHint] length] > 0) {
            placeholder = [xbuildInfo getQstHint];
        }
        else {
            placeholder = NSLocalizedString(@"please_fill_in", nil);
        }
        self.textView.placeholder = placeholder;
    }
}

#pragma mark - 设置文本颜色方法 colorStr:16进制颜色
- (void)setTextColorStrByHex:(NSString *)colorStr {
    
    if (colorStr && [colorStr length] > 0) {
        self.textView.textColor = [UIColor colorWithHexString:colorStr];
    }
    else {
        self.textView.textColor = PanelTextFieldColorReadonly;
    }
}

#pragma mark - 重写widgetDidLoadFinish方法
- (void)widgetDidLoadFinish {

//    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0 && [self.textView.text length] > 0) {
//
//        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)] ) {
//            [self.delegate executeLuaScript:xbuildInfo widget:self];
//        }
//    }
}

#pragma mark - 重写becomeFirstResponseder方法
- (void)becomeFirstResponseder {
    
    [super becomeFirstResponseder];
    [self.textView becomeFirstResponder];
}

#pragma mark - 设置当前比例文本方法
- (void)scaleCurrentText:(WSHTextField *)currentField {
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        WSInterAction *interAction = [[WSInterAction alloc] init];
        [interAction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
        [interAction setExecute_class_param:[self.textView text]];
        [interAction setExecute_class:@"WSInputTextFieldWithMagnify"];
        [interAction setDirect_type:DIRECT_TYPE_SHOW_IN_MAINVIEW];
        [delegate executeInterAction:interAction];
    }
}

#pragma mark - 结束当前编辑方法
- (void)endCurrentEdit:(WSHTextField *)currentField {

}

#pragma mark - 取消设置当前编辑方法
- (void)cancelCurrentEdit:(WSHTextField *)currentField {

}

#pragma mark - 结束编辑时执行
- (void)doEditOnEnd {
    
    if ([delegate respondsToSelector:@selector(executeEditOnEnd:widget:)]) {
        [delegate executeEditOnEnd:xbuildInfo widget:self];
    }
}

#pragma mark - 实现textViewDidBeginEditing:协议 开始编辑时响应
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self.textView.placeholderLabel setHidden:YES];
    
    NSString *select_all_on_focus = [[NSUserDefaults standardUserDefaults] objectForKey:SELECT_ALL_ON_FOCUS];
    if (select_all_on_focus.length > 0 && [select_all_on_focus isEqualToString:@"1"]) {
        [textView performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0f];
    }
}

#pragma mark - 实现textViewDidChange:协议 文本变化时响应
- (void)textViewDidChange:(UITextView *)textView {
    
    if (self.textView.m_length && self.textView.m_length > 0) {
        
        [textView.undoManager removeAllActions];
        
        NSString *inputMode = [[self.nextResponder textInputMode] primaryLanguage];
        if ([inputMode isEqualToString:@"zh-Hans"] || [inputMode isEqualToString:@"ja-JP"]) {
            
            UITextRange *selectedRange = [textView markedTextRange];
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            if (!position){
                [self checkTextView:textView];
            }
        }
        else {
            [self checkTextView:textView];
        }
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if ([self.checkLuaState isEqualToString:@"1"]) {
        if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
            if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                self.resultCheck = self.textView.text;
                [delegate executeLuaScript:xbuildInfo widget:self];
            }
        }
    }
}

#pragma mark - 实现textView:shouldChangeTextInRange:replacementText:协议
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *memo1 = [xbuildInfo getAcvtMemo1];
    if ([memo1 isEqualToString:@"kh"]) {
        
        if ([text isEqualToString:@" "] || [text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 检查文本方法
- (void)checkTextView:(UITextView *)textView {
    
    NSInteger maxLength = self.textView.m_length.integerValue;
    NSInteger number = [textView.text length];
    if (number > maxLength) {
        
        [textView resignFirstResponder];
        
        NSString *title = NSLocalizedString(@"text_exceed_max_length", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        textView.text = [textView.text substringToIndex:maxLength];
    }
}

#pragma mark - UITextViewTextDidChangeNotification通知响应方法 - 文本变化执行
- (void)textChange {
    
    [self checkValueChange];
    [self refreshTextAndHeight:self.textView.text];
    [self refreshFrame];
    
    if (![self.checkLuaState isEqualToString:@"1"]) {
        if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
            if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                self.resultCheck = self.textView.text;
                [delegate executeLuaScript:xbuildInfo widget:self];
            }
        }
    }
    
    [self setTextViewContentInset];
    [self.superview setNeedsLayout];
}

#pragma mark - 设置文本内容插入边框方法
- (void)setTextViewContentInset {
    
    if (self.textView.text.length > 0) {
        self.textView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0);
    }
    else {
        self.textView.contentInset = UIEdgeInsetsZero;
    }
}

@end
//================================================================================================================================================================================================
