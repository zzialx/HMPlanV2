//
//  WSNumberTextFiledPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSNumberTextFiledPanel.h"
#import "I_W_BuildInfo.h"
#import "I_M_ViewDelegate.h"
#import "I_M_View.h"

@interface WSNumberTextFiledPanel ()

@property (nonatomic, weak) UIButton *leftButton;   //输入框左按键(弱引用)
@property (nonatomic, weak) UIButton *rightButton;  //输入框右按键(弱引用)
@property (nonatomic, weak) UIView *upLineView;     //上方线视图(弱引用)
@property (nonatomic, weak) UIView *downLineView;   //下方线视图(弱引用)

- (void)leftButtonClick:(id)sender; //输入框左按键响应方法
- (void)rightButtonClick:(id)sender;//输入框右按键响应方法

@end

@interface WSNumberTextFiledPanel (Tools)

- (void)setupAuxiliaryTextFiledControl;                                 //设置辅助文本输入框控件方法
- (void)setupAuxiliaryTextFiledControlFrameByIsHidden:(BOOL)isHidden;   //设置辅助文本输入框控件边框方法
- (void)setupAuxiliaryTextFiledControlHidden:(BOOL)isHidden;            //输入框隐藏

@end


///数字录入
@implementation WSNumberTextFiledPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        return self;
    }
    return nil;
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:kDisplayModeAddSub]) {

        [self setupAuxiliaryTextFiledControl];
        // MSTD-7092 只读隐藏加减框
        if (!textField.enabled) {
            [self setupAuxiliaryTextFiledControlHidden:YES];
        }
    }
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    if ([[buildInfo getReadOnly] intValue]) {
        textField.enabled = NO;
        textField.textColor = [UIColor grayColor];
        textField.placeholder = @"";
    }
    [textField addTarget:self action:@selector(textFieldTextDidChange: ) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:kDisplayModeAddSub])
    {
        BOOL isHidden = !textField.enabled;
        [self setupAuxiliaryTextFiledControlFrameByIsHidden:isHidden];
    }
}

- (void)setReadonly:(NSString *)isReadonly {
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:kDisplayModeAddSub]) {
        // MSTD-7092 只读隐藏加减框
        if ([[xbuildInfo getReadOnly] intValue]) {
            [self setupAuxiliaryTextFiledControlHidden:YES];
        } else {
            [self setupAuxiliaryTextFiledControlHidden:NO];
        }
    }
}


/*刷新当前widget显示的值*/
- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString *valueString = (NSString *)value;
        
        // MN-1183 取消默认值显示，为空显示空
        if (valueString.length > 0) {
            NSString *formatStirng = nil;
            if(textField.m_pcs
               && [textField.m_pcs length] > 0
               && [textField.m_pcs integerValue] > 0){
                
                formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[textField.m_pcs integerValue]];
            }
            if (formatStirng) {
                textField.text = [NSString stringWithFormat:formatStirng,[valueString floatValue]];
            }else{
                textField.text = [NSString stringWithFormat:@"%f",[valueString floatValue]];
            }
        }else{
            textField.text = @"";
        }
        
    }
}

- (void) textFieldTextDidChange:(id)sender
{
    // 解决是数字键盘的时候 当输入是","时 把其替换为"."
 
        WSHTextField *currentTextFiled = (WSHTextField *)sender;
        if (currentTextFiled.keyboardType == UIKeyboardTypeDecimalPad) {
            NSRange range = [currentTextFiled.text rangeOfString:@","];
            if (range.location != NSNotFound) {
                
                [self setCurrentValueWithPresentation:[currentTextFiled.text stringByReplacingCharactersInRange:range withString:@"."]];

            }
        
        }
    
}

- (BOOL)textField:(UITextField *)textFieldin shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    
    if(![self limitedInputLength:textFieldin shouldChangeCharactersInRange:range replacementString:string])
    {
        return NO;
    }
    return YES;
}

- (BOOL)limitedInputLength:(UITextField *)textFieldin shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if([textFieldin isKindOfClass:[WSHTextField class]])
    {
        
        WSHTextField* i_tf = (WSHTextField*)textFieldin;
        
        return [i_tf shouldReplacementString:string inRange:range];
    }
    return YES;
}


#pragma mark -
#pragma mark I_M_ViewDelegate method

-(void)MessageView:(NSObject<I_M_View> *)messageView clickAtButtonIndex:(NSInteger)index{
    
    NSLog(@"===>>>>>>>数字验证代理回调");
    
}

-(void)MessageViewClickAtCancel:(NSObject<I_M_View> *)messageView{
    
    
}

#pragma mark - 输入框左按键响应方法
- (void)leftButtonClick:(id)sender
{
    [textField resignFirstResponder];
    // MSTD-7109 使用 untreatedText 避免获取到被千分位格式化的文本
    double oldNumber = [textField.untreatedText doubleValue];
    double newNumber = oldNumber - 1;
    NSString *newNumberStr;
    if ([textField.m_pcs integerValue] > 0) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf" , (long)[textField.m_pcs integerValue]];
        newNumberStr = [NSString stringWithFormat:formatString, newNumber];
    } else {
        newNumberStr = [NSString stringWithFormat:@"%ld", (long)newNumber];
    }
    if ([textField validateText:newNumberStr]){
        [self setCurrentValueWithPresentation:newNumberStr];
    }
}

#pragma mark - 输入框右按键响应方法
- (void)rightButtonClick:(id)sender
{
    [textField resignFirstResponder];
    // MSTD-7109 使用 untreatedText 避免获取到被千分位格式化的文本
    double oldNumber = [textField.untreatedText doubleValue];
    double newNumber = oldNumber + 1;
    NSString *newNumberStr;
    if ([textField.m_pcs integerValue] > 0) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf" , (long)[textField.m_pcs integerValue]];
        newNumberStr = [NSString stringWithFormat:formatString, newNumber];
    } else {
        newNumberStr = [NSString stringWithFormat:@"%ld", (long)newNumber];
    }
    if ([textField validateText:newNumberStr]){
        [self setCurrentValueWithPresentation:newNumberStr];
    }
}

@end

@implementation WSNumberTextFiledPanel (Tools)

#pragma mark - 设置辅助文本输入框控件方法 orientition:方向
- (void)setupAuxiliaryTextFiledControl
{
    
    NSString *tempString = textField.m_max;
    //    CGFloat textStrWidth = [tempString ws_sizeWithFont:textField.font constrainedToHeight:CGRectGetHeight(textField.frame)].width + MAIN_PADDING;
    tempString = NSLocalizedString(@"please_fill_in", nil);
    CGFloat maxStrWidth = [tempString ws_sizeWithFont:textField.font constrainedToHeight:CGRectGetHeight(textField.frame)].width + MAIN_BIG_PADDING;
    //    CGFloat maxStrWidth = (textStrWidth >= inputStrWidth ? textStrWidth : inputStrWidth) + MAIN_PADDING;
    CGFloat itemFrame = CGRectGetHeight(textField.frame);

    CGFloat labelStrWidth = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToHeight:CGRectGetHeight(self.titleLabel.frame)].width + MAIN_BIG_PADDING;

    // MN-702 单价去掉加减btn,因为单价有多个字段表示，所以暂用qstName匹配查找
    if ([[xbuildInfo getQuestName] isEqualToString:@"单价/元"]) {
        
        [textField setFrame:CGRectMake(labelStrWidth + MAIN_PADDING, (CGRectGetHeight(self.frame) - itemFrame) / 2, maxStrWidth - MAIN_PADDING, itemFrame)];
        textField.layer.borderColor = [UIColor colorWithHexString:@"#d8d8d8"].CGColor;
        textField.layer.borderWidth = 1.0;
        
    }else{
        CGFloat drawWidth = maxStrWidth + (itemFrame * 2);
        
        CGFloat x = CGRectGetWidth(self.frame) - drawWidth - (MAIN_PADDING / 2);
        CGFloat y = (CGRectGetHeight(self.frame) - itemFrame) / 2;
        CGFloat w = itemFrame;
        CGFloat h = itemFrame;
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_minus_blue"] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_minus_grey"] forState:UIControlStateDisabled];
        [leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.frame = CGRectMake(x, y, w, h);
        //    leftButton.enabled = textField.enabled;
        [self addSubview:leftButton];
        self.leftButton = leftButton;
        
        x = CGRectGetMaxX(self.leftButton.frame);
        y = CGRectGetMinY(self.leftButton.frame);
        w = maxStrWidth;
        h = 1.0f;
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        upView.backgroundColor = [UIColor colorWithHexString:@"#d8d8d8"];
        [self addSubview:upView];
        self.upLineView = upView;
        
        x = CGRectGetMaxX(self.leftButton.frame);
        y = CGRectGetMaxY(self.leftButton.frame) - 1.0f;
        w = maxStrWidth;
        h = 1.0f;
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        downView.backgroundColor = [UIColor colorWithHexString:@"#d8d8d8"];
        [self addSubview:downView];
        self.downLineView = downView;
        
        x = CGRectGetMaxX(self.leftButton.frame) + MAIN_PADDING / 2;
        y = CGRectGetMinY(self.leftButton.frame);
        w = maxStrWidth - MAIN_PADDING;
        h = itemFrame;
        [textField setFrame:CGRectMake(x, y, w, h)];
        
        x = CGRectGetMaxX(self.upLineView.frame);
        y = CGRectGetMinY(self.leftButton.frame);
        w = itemFrame;
        h = itemFrame;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.backgroundColor = [UIColor clearColor];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_plus_blue"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_plus_grey"] forState:UIControlStateDisabled];
        [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.frame = CGRectMake(x, y, w, h);
        // MN-3035
        //装车预估修改数量框的+号不可点击
        //备注：因为在初始化时如果表格是只读会把所有不隐藏的问题设置成只读，但是如果问题上配有脚本设置成不只读就不能再通过判断表格是否只读还设置了，所有注释掉
        //rightButton.enabled = textField.enabled;
        [self addSubview:rightButton];
        self.rightButton = rightButton;
    }
}

- (void)setupAuxiliaryTextFiledControlHidden:(BOOL)isHidden {
    [self.leftButton setHidden:isHidden];
    [self.rightButton setHidden:isHidden];
    [self.upLineView setHidden:isHidden];
    [self.downLineView setHidden:isHidden];
    
    [self setupAuxiliaryTextFiledControlFrameByIsHidden:isHidden];
}
//SFA-24166 IOS：SFA立白【经销商】订单添加产品优化需求——添加产品页面数量子数量优化
//立白添加产品页面走这个布局
- (void)resetFrameWithAddProd {
    
    NSString *tempString = textField.m_max;
    tempString = NSLocalizedString(@"please_fill_in", nil);
    CGFloat maxStrWidth = [tempString ws_sizeWithFont:textField.font constrainedToHeight:CGRectGetHeight(textField.frame)].width + MAIN_BIG_PADDING;
    CGFloat itemFrame = CGRectGetHeight(textField.frame); //高度
    CGFloat itemFrameWidth = CGRectGetHeight(textField.frame); //加减按钮的宽度
    
    CGFloat drawWidth =  maxStrWidth + (itemFrame * 2);

    if (self.frame.size.width < drawWidth ) {
        itemFrameWidth = itemFrame*4/5;
        maxStrWidth = self.frame.size.width - itemFrameWidth*2 ;
    }
    
    CGFloat x = 0;
    CGFloat y = (CGRectGetHeight(self.frame) - itemFrame) / 2;
    CGFloat w = itemFrameWidth;
    CGFloat h = itemFrame;
 
    self.leftButton.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.leftButton.frame);
    y = CGRectGetMinY(self.leftButton.frame);
    w = maxStrWidth;
    h = 1.0f;
    self.upLineView.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.leftButton.frame);
    y = CGRectGetMaxY(self.leftButton.frame) - 1.0f;
    w = maxStrWidth;
    h = 1.0f;
    self.downLineView.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.leftButton.frame);
    y = CGRectGetMinY(self.leftButton.frame);
    w = maxStrWidth;
    h = itemFrame;
    textField.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.upLineView.frame);
    y = CGRectGetMinY(self.leftButton.frame);
    w = itemFrameWidth;
    h = itemFrame;
    self.rightButton.frame = CGRectMake(x, y, w, h);
    textField.textAlignment = NSTextAlignmentCenter;
    
    self.leftButton.backgroundColor = [UIColor whiteColor];
    self.rightButton.backgroundColor = [UIColor whiteColor];
    textField.backgroundColor = [UIColor whiteColor];

}
#pragma mark - 设置辅助文本输入框控件边框方法 orientition:方向
- (void)setupAuxiliaryTextFiledControlFrameByIsHidden:(BOOL)isHidden
{
    //SFA-24166  IOS：SFA立白【经销商】订单添加产品优化需求——添加产品页面数量子数量优化  走新逻辑，
    if (self.isfillAll) {
        [self resetFrameWithAddProd];
        return;
    }
    
    if (!isHidden) {
        NSString *tempString = textField.m_max;
//        CGFloat textStrWidth = [tempString ws_sizeWithFont:textField.font constrainedToHeight:CGRectGetHeight(textField.frame)].width + MAIN_BIG_PADDING;
        tempString = NSLocalizedString(@"please_fill_in", nil);
        // MSTD-7260 MSTD-6627
        CGFloat maxStrWidth = [tempString ws_sizeWithFont:textField.font constrainedToHeight:CGRectGetHeight(textField.frame)].width + MAIN_BIG_PADDING;
//        CGFloat maxStrWidth = (textStrWidth >= inputStrWidth ? textStrWidth : inputStrWidth) + MAIN_BIG_PADDING;
        CGFloat itemFrame = CGRectGetHeight(textField.frame);
        CGFloat itemFrameWidth = CGRectGetHeight(textField.frame);
        
        CGFloat drawWidth = 0.0;
        
        if (self.leftButton && self.rightButton) {
            drawWidth = maxStrWidth + (itemFrame * 2);
        }else{
            drawWidth = maxStrWidth + MAIN_PADDING * 3;
        }
        
        if (self.frame.size.width < drawWidth + MAIN_BIG_PADDING) {
            itemFrameWidth = itemFrame*2/3;
            maxStrWidth = self.frame.size.width - itemFrameWidth*2 - MAIN_BIG_PADDING - MAIN_HORIZONTAL_GROUP_SPACE;
            drawWidth = maxStrWidth + itemFrame*2 + MAIN_BIG_PADDING*3;
        }
        
        CGFloat x = CGRectGetWidth(self.frame) - drawWidth - MAIN_BIG_PADDING;
        CGFloat y = (CGRectGetHeight(self.frame) - itemFrame) / 2;
        CGFloat w = itemFrameWidth;
        CGFloat h = itemFrame;
        
        CGFloat offset = 0;
        // MSTD-6627 操作框和标题重叠，横向则标题位置改变，纵向则操作框下移一行
        if (x < CGRectGetMaxX(self.titleLabel.frame)) {
            if ([self getOrientiton]) {
                CGRect titleFrame = self.titleLabel.frame;
                
//                CGFloat titleWidth = x - MAIN_BIG_PADDING - titleFrame.origin.x;
                CGFloat titleWidth = self.titleLabel.frame.size.width;

                CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:titleWidth];
                titleSize = [self.titleLabel labelResize:titleSize];
                
                offset = titleSize.height - titleFrame.size.height;
//                titleFrame.size.width = titleWidth;
                titleFrame.size.height = titleSize.height;
                
                self.titleLabel.frame = titleFrame;
                
                // MENGNIU-1834 修正title被加减输入框遮挡的问题，后期可再调整
                x = titleFrame.origin.x + titleFrame.size.width;

            } else {
                CGFloat newlineY = CGRectGetMaxY(self.titleLabel.frame);
                offset  = newlineY - y;
                y = newlineY;
            }
        }
        
        if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
            x = MAIN_HORIZONTAL_GROUP_SPACE;
        }
        
        self.leftButton.frame = CGRectMake(x, y, w, h);
        
        x = CGRectGetMaxX(self.leftButton.frame);
        y = CGRectGetMinY(self.leftButton.frame);
        w = maxStrWidth;
        h = 1.0f;
        self.upLineView.frame = CGRectMake(x, y, w, h);
        
        x = CGRectGetMaxX(self.leftButton.frame);
        y = CGRectGetMaxY(self.leftButton.frame) - 1.0f;
        w = maxStrWidth;
        h = 1.0f;
        self.downLineView.frame = CGRectMake(x, y, w, h);
        
        x = CGRectGetMaxX(self.leftButton.frame);
        y = CGRectGetMinY(self.leftButton.frame);
        w = maxStrWidth;
        h = itemFrame;
        textField.frame = CGRectMake(x, y, w, h);
        
        x = CGRectGetMaxX(self.upLineView.frame);
        y = CGRectGetMinY(self.leftButton.frame);
        w = itemFrameWidth;
        h = itemFrame;
        self.rightButton.frame = CGRectMake(x, y, w, h);
        
        textField.textAlignment = NSTextAlignmentCenter;
        
        // 需要父视图重置样式
        if (offset > 0) {
            CGRect originFrame = self.frame;
            originFrame.size.height += offset;
            self.frame = originFrame;
            [self.superview setNeedsLayout];
        }
        
        //CGFloat labelStrWidth = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToHeight:CGRectGetHeight(self.titleLabel.frame)].width + MAIN_BIG_PADDING;
        
        // MN-702 单价去掉加减btn，调整frame
        if ([[xbuildInfo getQuestName] isEqualToString:@"单价/元"])
        {
            //MNXHJH-69 2018-03-30
            [self resetTitleTextFieldFrame];
            [self setTextFieldAlignment];
            
//            [textField setFrame:CGRectMake(labelStrWidth + MAIN_PADDING, (CGRectGetHeight(self.frame) - itemFrame) / 2, maxStrWidth - MAIN_PADDING, itemFrame)];
//
//            CGFloat rightBtnWidth = 0.0;
//
//            if (self.rightButton) {
//                rightBtnWidth = self.rightButton.frame.size.width;
//            }
//
//            CGFloat panelRealWidth = textField.frame.origin.x + textField.frame.size.width + rightBtnWidth;
//
//            if (panelRealWidth < self.frame.size.width) {
//                CGRect frame = self.frame;
//                frame.size.width = panelRealWidth;
//                self.frame = frame;
//                [self.superview layoutIfNeeded];
//            }
            
        }
        
    } else {
        [self resetTitleTextFieldFrame];
        [self setTextFieldAlignment];
    }
    
}

@end
