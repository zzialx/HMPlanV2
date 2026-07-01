//
//  WSTextViewWithRangePanel.m
//  WinSFA
//
//  Created by Stephanie on 16/6/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTextViewWithRangePanel.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "WSValidateTextView.h"
#import "WSDropListView.h"

const static CGFloat kPadding = 2.0f;
//=======================================================================================================================================

@implementation WSTextViewWithRangePanel

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        return self;
    }
    return nil;
}

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    if ([self.textView.m_length integerValue] <= 0) {
        return;
    }
    
    warningLabel = [[UILabel alloc] init];
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.font = [UIFont systemFontOfSize:UI_Font];
    [self addSubview:warningLabel];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        warningLabel.hidden = YES;
    }
    else {
        [self setWarningLabelContent:self.textView];
    }

    [self refreshSelfFrame];
}

#pragma mark - 设置警示标签内容方法
- (void)setWarningLabelContent:(WSValidateTextView *)textfield {
    
    if ([textfield.m_length length] > 0 && [textfield.m_type isEqualToString:COL_TYPTEXT]) {
        
        if (textfield.text && [textfield.text length] > 0) {
            
            NSInteger remainingCount = [textfield.m_length integerValue] - [textfield.text length];
            if (remainingCount >= 0) {
                warningLabel.textColor = titleLabel.textColor;
            }
            else {
                warningLabel.textColor = [UIColor redColor];
            }
            warningLabel.text = [NSString stringWithFormat:@"(%lu/%ld)", (unsigned long)[textfield.text length], (long)[textfield.m_length integerValue]];
        }
        else {
            
            warningLabel.textColor = titleLabel.textColor;
            warningLabel.text = nil;
        }
    }
    
    [self reloadTextViewFrame];
}

#pragma mark - 重载 文本视图边框尺寸方法
- (void)reloadTextViewFrame {
    
    CGSize warningSize = [warningLabel.text ws_sizeWithFont:warningLabel.font constrainedToWidth:self.frame.size.width lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat widthReduce = warningSize.width + kPadding;
    CGSize titleSize = [titleLabel.text ws_sizeWithFont:titleLabel.font constrainedToWidth:self.titleLabel.size.width lineBreakMode:NSLineBreakByCharWrapping];

    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    float xpos = titleLabel.frame.origin.x + titleSize.width + kPadding;
    if (warningLabel.hidden) {
       
        if (!titleLabel.isHidden) {
            
            CGFloat x = xpos + MAIN_CELL_PADDING;
            CGFloat width = self.frame.size.width - x - MAIN_CELL_PADDING;
            CGFloat textHeight = [self getTextHeightByWidth:width];
            if (orientition) {
                self.textView.frame = CGRectMake(x, self.textView.origin.y,  width, textHeight);
            }
        }
        else {

            if (orientition) {
                
                CGFloat x = titleLabel.frame.origin.x;
                CGFloat width = self.frame.size.width - x;
                CGFloat textHeight = [self getTextHeightByWidth:width];
                self.textView.frame = CGRectMake(x, self.textView.origin.y, width, textHeight);
            }
        }
    }
    else {
        
        if (self.frame.size.width - xpos >= warningSize.width) {
            
            [warningLabel setFrame:CGRectMake(xpos, titleLabel.frame.origin.y, self.frame.size.width, titleLabel.frame.size.height)];
            
            CGFloat x = titleLabel.origin.x + titleLabel.size.width + widthReduce;
            CGFloat width = self.frame.size.width - x - MAIN_CELL_PADDING;
            CGFloat textHeight = [self getTextHeightByWidth:width];
            if (orientition) {
                self.textView.frame = CGRectMake(x, self.textView.origin.y,  width, textHeight);
            }
        }
        else {
            
            [warningLabel setFrame:CGRectMake(titleLabel.origin.x, titleLabel.frame.origin.y+titleLabel.frame.size.height, self.frame.size.width, MAIN_TEXTFIELD_HEIGHT)];
            if (warningLabel && ![warningLabel.text isEqualToString:@""] && warningLabel.text) {
                self.textView.frame = CGRectMake(self.textView.frame.origin.x, warningLabel.frame.origin.y+warningLabel.frame.size.height, self.textView.frame.size.width, self.textView.frame.size.height);
            }
        }
    }
    
    [self refreshSelfFrame];
}

#pragma mark - 刷新自身边框尺寸方法
- (void)refreshSelfFrame {
    
    CGFloat height = self.textView.frame.origin.y + self.textView.frame.size.height;
    CGFloat paddingY = self.frame.origin.y;
    if (height < MAIN_CELL_HEIGHT) {
    }
    else if (self.textView.frame.origin.y == MAIN_CELL_HEIGHT) {
        CGFloat originHeight = self.height;
        height += (originHeight - height);
    }
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    if (!orientition && self.textView.frame.size.height < MAIN_CELL_HEIGHT) {
        height = self.textView.frame.origin.y + MAIN_CELL_HEIGHT;
    }
    CGFloat titleHeight = self.titleLabel.height;
    if (height < titleHeight) {
        height = titleHeight;
    }
    if (height < MAIN_CELL_HEIGHT) {
        height = MAIN_CELL_HEIGHT;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, paddingY, self.frame.size.width, height);
    [self.xbuildInfo setLayOutInfo:self.frame];
}

#pragma mark - 重写setRequest:方法
- (void)setRequest:(NSString *)isRequest{
    
    [super setRequest:isRequest];
    [self reloadTextViewFrame];
}

#pragma mark - 重写setReadonly:方法
- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        warningLabel.hidden = YES;
    }
    else {
        warningLabel.hidden = NO;
    }
}

#pragma mark - 文本改变设置文本输入框
- (void)changeRemainingwordsWithWSHTextField:(WSValidateTextView *)aTextField {
    
    [self setWarningLabelContent:aTextField];
}

#pragma mark - 重写loadComputeResult:方法
- (void)loadComputeResult:(WSInterAction *)interAction{
    
    currentInterAction = interAction;
    
    [self.textView setText:(NSString *)[currentInterAction execute_result]];
    [self setWarningLabelContent:self.textView];
    
    [self.textView becomeFirstResponder];
    [self.textView resignFirstResponder];
}

#pragma mark - 重写reloadCurrentWidgetWithValue:方法
- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    
    if (value && [value isKindOfClass:[NSString class]] && ((NSString *)value).length > 0) {
        [self.textView setText:(NSString *)value];
    }
    [self reloadTextViewFrame];
}

#pragma mark - 获取文本高度方法
- (CGFloat)getTextHeightByWidth:(CGFloat)width {
    
    CGFloat textHeight = self.textView.size.height;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    if (textHeight < textSize.height ) {
        textHeight = textSize.height;
    }
    return textHeight;
}

#pragma mark - 重写refreshQstByServer:方法
- (void)refreshQstByServer:(NSArray *)resultArray {
    
    if (resultArray && resultArray.count > 0) {
        
        for (NSDictionary *dict in resultArray) {
            [self.textView setText:[dict objectForKey:@"name"]];
        }
    }
    else {
        [self.textView setText:@""];
    }
}

#pragma mark - 重写textChange方法(UITextViewTextDidChangeNotification 通知响应方法)
- (void)textChange {
    
    [super textChange];
    [self changeRemainingwordsWithWSHTextField:self.textView];
}

@end
//=======================================================================================================================================
