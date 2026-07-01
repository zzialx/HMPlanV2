//
//  WSTextFiledPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFiledPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "I_Lua_Target_Operator.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "I_W_DisplayValue.h"
#import "WSStringValueChangeChecker.h"

#define TextLengthMax           19
#define TEXT_PLACEHOLDER_OFFSET 18.0f
#define TEXT_FRAME_OFFSET       1.0f
#define kTextFieldColor         ([UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIColor colorForKey:@"WorkFlowSectionHeaderViewTitle"] : MAIN_TEXT_COLOR)
#define kTextFieldFont          ([UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : [UIFont systemFontOfSize:UI_Font])

@interface WSTextFiledPanel () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL isBackPrepareSaveData;//是否返回准备保存的数据

@end

@implementation WSTextFiledPanel
@synthesize textField;

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        return self;
    }
    
    return nil;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
}

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    _isNeedResetTitleTextFieldFrame = YES;
    
    UIFont *font = [xbuildInfo getValueSize] ? [UIFont systemFontOfSize:[[xbuildInfo getValueSize] floatValue]] : PanelTextFieldFont;
    BOOL orientition = [self getOrientiton];
    CGRect textFieldFrame = [self getTextFieldFrameByOrientition:orientition];
    UITextView *tempViewForGetHeight = [[UITextView alloc] init];
    tempViewForGetHeight.font = font;
    CGSize fitSize =  [tempViewForGetHeight sizeThatFits:CGSizeMake(textFieldFrame.size.width, CGFLOAT_MAX)];
    textFieldFrame.size.height = fitSize.height;
    
    textField = [[WSHTextField alloc] initWithFrame:textFieldFrame Qst:(WSAcvtBean_qst *)xbuildInfo];

    [self resetSelfHeightWithOrientition:orientition];

    NSString *placeholder;
    if ([[xbuildInfo getQstHint] length] > 0) {
        placeholder = [xbuildInfo getQstHint];
    }
    else {
        placeholder = NSLocalizedString(@"please_fill_in", nil);
    }
    
    textField.placeholder = placeholder;
    textField.font = font;
    textField.backgroundColor = [UIColor clearColor];
    [self setTextFieldAlignment];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:textField];
    
    textField.delegate = self;
    textField.inputdelegate = self;
    textField.tag = [[xbuildInfo getAcvtQstId] intValue];
    textField.iColumnName = [xbuildInfo getQuestName];
    
    NSString *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    _originalValue = displayValue;
    
    BOOL old = textField.isNeedValidateText;
    textField.isNeedValidateText = NO;
    textField.text = displayValue;
    textField.isNeedValidateText = old;
    
    if (textField.text) {
        if ([textField.text length] > TextLengthMax && INTERFACE_IS_PHONE) {
            [textField setFont:[UIFont systemFontOfSize:12]];
        }
    }
    
    if ([[xbuildInfo getReadOnly] intValue]) {
        textField.enabled = NO;
        textField.textColor = [xbuildInfo getValueReadColor] ? [UIColor colorWithHexString:[xbuildInfo getValueReadColor]] : PanelTextFieldColorReadonly;
        textField.placeholder = @"";
    }
    else {
        textField.textColor = PanelTextFieldColor;

    }
    
    [self addSubview:textField];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - 获取Orientiton设置方法
- (BOOL)getOrientiton {
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    return orientition;
}

#pragma mark - 设置输入框Alignment属性方法
- (void)setTextFieldAlignment {
    
    BOOL orientition = [self getOrientiton];
    if (orientition) {
        textField.textAlignment = NSTextAlignmentRight;
        textField.contentMode = UIViewContentModeRight;
    }
    else {
        textField.textAlignment = NSTextAlignmentLeft;
        textField.contentMode = UIViewContentModeLeft;
    }
    
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

#pragma mark - 获取文本框位置，高度返回 0，调用者根据需要自行设置高度
- (CGRect)getTextFieldFrameByOrientition:(BOOL)orientition {
    
    int elementSpace = 2.0f;
    int twidth = orientition ? ((self.width - MAIN_HORIZONTAL_GROUP_SPACE * 2) - titleLabel.width - elementSpace) :(self.width - titleLabel.frame.origin.x * 2);
    int i_xPosition = orientition ? (CGRectGetMaxX(titleLabel.frame) + elementSpace) : titleLabel.frame.origin.x;
    int ty = orientition ? 0 : titleLabel.frame.origin.y + titleLabel.frame.size.height + 10.0;
    return CGRectMake(i_xPosition, ty, twidth, 0);
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (_isNeedResetTitleTextFieldFrame) {
        [self resetTitleTextFieldFrame];
    }
}

#pragma mark - 调整输入框边框尺寸方法
- (void)resetTitleTextFieldFrame {
    
    BOOL orientition = [self getOrientiton];
    CGRect originRect = [self getTextFieldFrameByOrientition:orientition];
    [self resetSelfHeightWithOrientition:orientition];
    
    if (orientition) {
        
        CGRect textFieldRect = textField.frame;
        [textField setFrame:CGRectMake(originRect.origin.x, (self.frame.size.height - textFieldRect.size.height)/2 +1 , originRect.size.width, textFieldRect.size.height)];
        CGRect labelFrame = self.titleLabel.frame;
        [self.titleLabel setFrame:CGRectMake(labelFrame.origin.x, (self.frame.size.height - labelFrame.size.height)/2 , labelFrame.size.width, labelFrame.size.height)];
    }
}

#pragma mark - 重载自身高度方法
- (void)resetSelfHeightWithOrientition:(BOOL)orientition {
    
    CGFloat frameHeight =  textField.frame.origin.y + textField.frame.size.height;
    if (frameHeight < MAIN_CELL_HEIGHT) {
        frameHeight = MAIN_CELL_HEIGHT;
    }
    
    CGFloat titleHeight = self.titleLabel.height;
    if (frameHeight < titleHeight) {
        frameHeight = titleHeight;
    }
    
    if (!orientition) {
        frameHeight += 10;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frameHeight)];
}

#pragma mark - 重写getResultDirectly方法
- (NSObject *)getResultDirectly {
    
    if ([textField text] && [[textField text] length] > 0) {
        
        NSString *value = [textField text];
        if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_N] && _isBackPrepareSaveData == NO) {
            value = [[textField text] stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        
        if ([textField.m_type isEqualToString:QST_TYPE_N] && [textField.m_pcs integerValue] > 0) {
            NSString *formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[textField.m_pcs integerValue]];
            value = [NSString stringWithFormat:formatStirng, value.doubleValue];
        }
        
        return value;
    }
   
    return nil;
}

#pragma mark - 重写getPrepareSaveData方法
- (NSObject *)getPrepareSaveData {
    
    _isBackPrepareSaveData = YES;
    return [self getResultDirectly];
}

#pragma mark - 重写setCurrentValueWithPresentation:方法
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    textField.text = valuePresentation;
    self.resultCheck = valuePresentation;
    
    [self textChange];
    [self runScript];
}

#pragma mark - 重写getResultPresentation方法
- (NSObject *)getResultPresentation {
    
    NSString *value = [textField text];
    if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_N]) {
        value = [[textField text] stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    return value;
}

#pragma mark - 重写setReadonly方法
- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] intValue]) {
        textField.enabled = NO;
        textField.textColor = PanelTextFieldColorReadonly;
        textField.placeholder = @"";
    }
    else {
        textField.enabled = YES;
        textField.textColor = PanelTextFieldColor;
        textField.placeholder = NSLocalizedString(@"please_fill_in", nil);
    }
}

#pragma mark - 重写widgetDidLoadFinish方法
- (void)widgetDidLoadFinish {

}

#pragma mark - 重写setViewAnswerColor:方法
- (void)setViewAnswerColor:(UIColor *)color {
    
    textField.textColor = color;
}

#pragma mark - 执行额外编辑方法
- (void)doEditOnEnd {
    
    if ([delegate respondsToSelector:@selector(executeEditOnEnd:widget:)]) {
        [delegate executeEditOnEnd:xbuildInfo widget:self];
    }
}

#pragma mark - 重写becomeFirstResponseder方法
- (void)becomeFirstResponseder {
    
    [super becomeFirstResponseder];
    [textField becomeFirstResponder];
}

#pragma mark - 重写resignFirstResponseder方法
- (void)resignFirstResponseder{
    
    [super resignFirstResponseder];
    [textField resignFirstResponder];
}

#pragma mark - 实现textFieldDidBeginEditing:协议
- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
    
    NSString *select_all_on_focus = [[NSUserDefaults standardUserDefaults] objectForKey:SELECT_ALL_ON_FOCUS];
    if (select_all_on_focus.length > 0 && [select_all_on_focus isEqualToString:@"1"]) {
        [aTextField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
    }
}

#pragma mark - 实现textFieldDidEndEditing:协议
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self runScript];
}

#pragma mark - 实现textFieldShouldReturn:协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self doEditOnEnd];
    return NO;
}

#pragma mark - 文本变化方法
- (void)textChange {
    
    [self checkValueChange];
}

#pragma mark - 运行脚本方法(.h方法 子类可重写逻辑)
- (void)runScript {
    
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}

- (void)scaleCurrentText:(WSHTextField *)currentField {
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        WSInterAction *interAction =[[WSInterAction  alloc] init];
        [interAction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
        [interAction setExecute_class_param:[textField text]];
        [interAction setExecute_class:@"WSInputTextFieldWithMagnify"];
        [interAction setDirect_type:DIRECT_TYPE_SHOW_IN_MAINVIEW];
        [delegate executeInterAction:interAction];
    }
}

- (void)endCurrentEdit:(WSHTextField *)currentField {

}

- (void)cancelCurrentEdit:(WSHTextField *)currentField {

}

@end
