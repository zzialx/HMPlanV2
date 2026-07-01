//
//  WSTextFiledWithRangePanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFiledWithRangePanel.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"

@implementation WSTextFiledWithRangePanel
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}

-(void)buildDisplayContent{

    [super buildDisplayContent];
    
    if ([textField.m_length integerValue] <= 0) {
        return;
    }
    
    float xpos = titleLabel.frame.origin.x+titleLabel.frame.size.width+2.0;
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    
//    if (!([[xbuildInfo getQstHint] length] > 0) && [textField.m_length integerValue] > 0) {
//        NSString *readOnly = [xbuildInfo getReadOnly];
//
//        if (!(readOnly && [readOnly isEqualToString:@"1"])) {
//            self.textField.placeholder = [NSString stringWithFormat:NSLocalizedString(@"acvt_type_t_edit_label", nil), textField.m_length];
//        }
//    }
    
    
    NSString *warningString = [NSString stringWithFormat:@"(%lu/%ld)", (unsigned long)[self.textField.text length], (long)[textField.m_length integerValue]];
    
    CGSize size = [warningString ws_sizeWithFont:font constrainedToWidth:self.frame.size.width lineBreakMode:NSLineBreakByCharWrapping];
    
    size.width += 5.0f; /*偏差*/
    
    CGFloat widthReduce = size.width + 10;
    
    if (self.frame.size.width - xpos >= size.width) {
        
        warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(xpos, titleLabel.frame.origin.y, self.frame.size.width, titleLabel.frame.size.height)];
        
        BOOL orientition = NO;
        if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
            orientition = YES;
        }
        if (orientition && (titleLabel.origin.x + titleLabel.width + size.width> self.width/2)) {
//            CGFloat widthReduce = titleLabel.origin.x + titleLabel.width + size.width + 17 - self.width/2;
            
            textField.frame = CGRectMake(titleLabel.origin.x + titleLabel.width + widthReduce, textField.origin.y, textField.size.width - widthReduce, textField.size.height);
        }else {
            CGRect newRect = textField.frame;
            newRect.size.width -= widthReduce;
            newRect.origin.x += widthReduce;
            textField.frame = newRect;
        }
        
     }else{
        
        warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, titleLabel.frame.origin.y+titleLabel.frame.size.height+2.0, self.frame.size.width, titleLabel.frame.size.height)];
  
        textField.frame = CGRectMake(textField.frame.origin.x, warningLabel.frame.origin.y+warningLabel.frame.size.height+2.0, textField.frame.size.width - widthReduce, textField.frame.size.height);
        
    }
    
    warningLabel.backgroundColor = [UIColor clearColor];
    
    warningLabel.font = font;

    [self addSubview:warningLabel];
    
    [textField addTarget:self action:@selector(testRange:) forControlEvents:UIControlEventEditingChanged];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        warningLabel.hidden = YES;
    }else {
        [self setWarningLabelContent:textField];
    }
    
    self.frame =CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width, textField.frame.origin.y + textField.frame.size.height + 5.0);
    
}


- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        warningLabel.hidden = YES;
    }else {
        warningLabel.hidden = NO;
    }
    
}


-(void)testRange:(WSHTextField *)textinput{
    
    [self changeRemainingwordsWithWSHTextField:textinput];
    
}

/**
 *  @brife 把文本类型的 WSHTextField 中的字符数字输入到 UILabel
 *
 *  @param aTextField 要统计字符数 COL_TYPTEXT类型的 WSHTextField
 */
- (void) changeRemainingwordsWithWSHTextField: (WSHTextField *)aTextField
{
    [self setWarningLabelContent:aTextField];
}

- (void)setWarningLabelContent:(WSHTextField *)textfield{
    
    if ( [textfield.m_length length] > 0 && [textField.m_type isEqualToString:COL_TYPTEXT]) {
        
        if (textfield.text
            && [textfield.text length]>0) {
            
            NSInteger remainingCount = [textfield.m_length integerValue] - [textfield.text length];
            if (remainingCount >= 0) {
                warningLabel.textColor = titleLabel.textColor;
            }else{
                NSString *inputStr =[textfield.text substringToIndex:[textfield.m_length integerValue]];
                textfield.text = inputStr;
                //warningLabel.textColor = [UIColor redColor];
            }
            warningLabel.text = [NSString stringWithFormat:@"(%lu/%ld)", (unsigned long)[textfield.text length], (long)[textField.m_length integerValue]];
            
        }else{
            
            warningLabel.textColor = titleLabel.textColor;
            
            warningLabel.text = nil;
            
        }
    }
}


- (void)loadComputeResult:(WSInterAction *)interAction{
    
    currentInterAction = interAction;
    
    [textField setText:(NSString *)[currentInterAction execute_result]];
    
    [self setWarningLabelContent:textField];
    
    [textField becomeFirstResponder];
    
    [textField resignFirstResponder];
    
    
}

/*显示刷新的值*/
- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    if (value && [value isKindOfClass:[NSString class]]) {
        [textField setText:(NSString *)value];
    }
    
}

@end
