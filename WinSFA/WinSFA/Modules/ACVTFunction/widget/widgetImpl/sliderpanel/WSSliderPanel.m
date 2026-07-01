//
//  WSSliderPanel.m
//  WinSFA
//
//  Created by Alicia on 17/1/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSliderPanel.h"
#import "I_W_BuildInfo.h"
#import "WSSlider.h"

#define kSliderReverse      @"reverse"      // 反向，如果是反向

@interface WSSliderPanel ()

@property (nonatomic, strong) WSSlider *slider;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) NSString *descString;

@end

@implementation WSSliderPanel


- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    WSSlider *slider = [[WSSlider alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, CGRectGetMaxY(self.titleLabel.frame) + MAIN_PADDING, self.frame.size.width - 2 * MAIN_CELL_PADDING, MAIN_CELL_HEIGHT)];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    self.slider = slider;
    
    NSString *mnum = [xbuildInfo getMumx];
    [slider setMaximumValue:[mnum floatValue]];
    
    NSString *snum = [xbuildInfo getSnumx];
    [slider setMinimumValue:[snum floatValue]];
    
    NSString *memo = [xbuildInfo getAcvtMemo];
    NSArray *hintArray = [self getHintArray];
    self.descString = hintArray.count > 1 ? [hintArray lastObject] : @"";
    
    if ([memo length] == 0) {
        [slider setIsDistance:YES];
        memo = NSLocalizedString(@"km", nil);
        self.descString = NSLocalizedString(@"in_range", nil);
        [slider setMultiplier:1000];
    }
    [slider setValueLabelMemo:memo];
    
    [slider setDLen:[xbuildInfo getDlen]];
    
    if ([[xbuildInfo getAcvtMemo4] isEqualToString:kSliderReverse]) {
        [slider setIsReverse:YES];
    }
   
  
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + MAIN_PADDING, 0, self.width - CGRectGetWidth(self.titleLabel.frame), MAIN_CELL_HEIGHT)];
    [descLabel setTextColor:MAIN_TINT_COLOR];
    [descLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [self addSubview:descLabel];
    self.descLabel = descLabel;
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAIN_CELL_HEIGHT * 2+ MAIN_PADDING)];
    [self sliderValueChanged:_slider];
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    if (valuePresentation) {
        [self.slider setValue:[valuePresentation floatValue]];
    } else {
        [self.slider setValue:0];
    }
    [self sliderValueChanged:self.slider];
}

- (NSObject *)getResultDirectly {
    return [self.slider getResultDirectly];
}

- (NSObject *)getSearchCondition {
     return [self.slider getSearchCondition];
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    if ([[xbuildInfo getReadOnly] intValue]) {
        self.slider.userInteractionEnabled = NO;
    }else {
        self.slider.userInteractionEnabled = YES;
    }
}


#pragma mark self loadFinish Method
- (void)widgetDidLoadFinish {
    /*
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)] ) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
            
        }
    }
     */
}

#pragma mark - Private Method

- (void)sliderValueChanged:(WSSlider *)slider {
    NSString *valueString = [slider getDisplayValueWithIsMultiply:NO isSearch:NO];
    
    [self.descLabel setText:[NSString stringWithFormat:@"%@%@%@", valueString, slider.valueLabelMemo, self.descString]];
    
    if (FLOAT_IS_EQUAL(slider.value, 0)) {
        if ([[xbuildInfo getAcvtMemo] length] == 0) {
            [self.descLabel setText:NSLocalizedString(@"unlimited_distance", nil)];
        } else {
            NSArray *hintArray = [self getHintArray];
            [self.descLabel setText:hintArray.count > 1 ? [hintArray firstObject] : NSLocalizedString(@"unlimited_memo", nil)];
        }
    }
}
- (NSArray *)getHintArray{
    NSArray *hintArray = nil;
    if ([xbuildInfo getQstHint].length > 0) {
        hintArray = [[xbuildInfo getQstHint] componentsSeparatedByString:@"@"];
    }
    return hintArray ;
}


@end
