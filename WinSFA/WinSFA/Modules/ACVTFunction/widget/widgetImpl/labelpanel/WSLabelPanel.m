//
//  WSLabelPanel.m
//  WinSFA
//
//  Created by yang on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSLabelPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "UICopyLabel.h"
#import "UILabel+Additional.h"
#import "NSString+Additions.h"


#define kLabelGap 10.0f

@interface WSLabelPanel ()

@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation WSLabelPanel

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    NSString *text = [xbuildInfo getDefaultValue];
    if (text == nil) {
        text = [NSString stringWithFormat:@"%@",[xbuildInfo getQuestName]];
    }
    [self reloadSubViewsWithText:text];

}
- (void)reloadSubViewsWithText:(NSString *)text{
    
    NSString* l_dis = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if(l_dis != nil && [l_dis length] > 0)
    {
        _originalValue = l_dis;
        //        text = [NSString stringWithFormat:@"%@%@",[xbuildInfo getQuestName],l_dis];
        
        self.infoLabel = [[UICopyLabel alloc] initWithFrame:CGRectZero];
        self.infoLabel.font = titleLabel.font;
        self.infoLabel.textAlignment = NSTextAlignmentRight;
        self.infoLabel.textColor = PanelTextFieldColor;
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel.numberOfLines = 0;
        [self addSubview: self.infoLabel];
        self.infoLabel.text = l_dis;
    }
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.infoLabel.textColor = [UIColor grayColor];
    }
    
    CGFloat titleWidth = self.width - 2 * MAIN_CELL_PADDING;
    //字符转换
    text = [text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    CGSize size  = [text ws_sizeWithFont:titleLabel.font constrainedToWidth:titleWidth];
    
    size = [titleLabel labelResize:size];
    
    titleLabel.text = text;
    
    titleLabel.frame = CGRectMake(titleLabel.origin.x, titleLabel.origin.y, titleWidth, size.height);
    
    if([xbuildInfo getTextColor] && [[xbuildInfo getTextColor] getCharLength] > 2)
    {
        titleLabel.textColor = [UIColor colorWithHexString:[[xbuildInfo getTextColor] substringFromIndex:2]];
    }

    CGFloat infoX = self.width/2;
    if (size.width < (titleWidth/2 - GROUP_CELL_PADDING)) {
        infoX = titleLabel.origin.x + size.width + GROUP_CELL_PADDING;
    }
    CGFloat infoWidth = self.width - infoX - MAIN_CELL_PADDING;
    if (self.infoLabel) {
        self.infoLabel.frame = CGRectMake(infoX, titleLabel.origin.y, infoWidth, size.height);
        
        CGSize infoSize  = [l_dis ws_sizeWithFont:self.infoLabel.font constrainedToWidth:CGFLOAT_MAX];
        if (infoSize.width > infoWidth) {
            self.infoLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        }
    }
    
    UIColor *bgColor = nil;
    NSString *bgColorStr = [xbuildInfo getBgColor];
    if (bgColorStr.length > 0) {
        
        bgColor = [UIColor colorWithHexString:bgColorStr];
        [self setBackgroundColor:bgColor];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, titleLabel.origin.y + size.height);
}

- (NSObject *)getResultDirectly
{
    if (_originalValue) {
        return _originalValue;
    }
    
    return nil;
}

- (NSObject *)getResultPresentation
{
    if (_originalValue) {
        return _originalValue;
    }
    
    return nil;
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.infoLabel.textColor = PanelTextFieldColorReadonly;
    }else {
        self.infoLabel.textColor = PanelTextFieldColor;
    }
}
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation{
    [self reloadSubViewsWithText:valuePresentation];
    
}

@end
