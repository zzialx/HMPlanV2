//
//  WSStoreKPICell.m
//  WinSFA
//
//  Created by Alicia on 17/2/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreKPICell.h"
#import "I_W_BuildInfo.h"
#import "WSDefaultStringDisplayValue.h"

#define upTitleLabelTopMagin 15
#define upTitleLabelHeight 21

#define upTitleLabelFontSize 20
#define downTitleLabelFontSize 12

static NSString *kStoreKPICellServerRedisValueSegmentedMark = @"@jumpUrl@"; //分割标示

@interface WSStoreKPICell ()

@property (nonatomic, strong) UILabel *upTitleLabel;
@property (nonatomic, strong) UILabel *downTitleLabel;
@property (nonatomic, copy) NSString *segmentedStr; //分割字符

@end

@implementation WSStoreKPICell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.upTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, upTitleLabelTopMagin, self.width - 0.5, upTitleLabelHeight)];
        self.upTitleLabel.font =FONT_SIZE_PINGFANG_MEDIUM(upTitleLabelFontSize);
        self.upTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.upTitleLabel];
        
        self.downTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.upTitleLabel.bottom +  5, self.width - 0.5, upTitleLabelTopMagin)];
        
        UIColor * downtitleColor = [UIColor colorForKey:@"StoreKPIDownTitleColor"] ? [UIColor colorForKey:@"StoreKPIDownTitleColor"] : [UIColor whiteColor];;
        self.downTitleLabel.textColor = downtitleColor;
        self.downTitleLabel.font =FONT_SIZE_PINGFANG_MEDIUM(downTitleLabelFontSize);
        self.downTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.downTitleLabel];
    
        // 中可使用的颜色为 191,143,158
        UIColor *bgColor = [UIColor colorForKey:@"StoreKPIBackgroundColor"] ? [UIColor colorForKey:@"StoreKPIBackgroundColor"] : [MAIN_TINT_COLOR colorWithAlphaComponent:0.5];
        [self.contentView setBackgroundColor:bgColor];
        
        self.separatorLable = [[UILabel alloc]initWithFrame:CGRectMake(self.upTitleLabel.right, 10, 0.5, 55)];
        self.separatorLable.backgroundColor = MAIN_SEPERATE_LINE_COLOR;
        [self.contentView addSubview:self.separatorLable];
    }
    
    return self;
}

- (void)setBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    [self.downTitleLabel setText:[buildInfo getQuestName]];
   
    NSString *colorString = [buildInfo getTextColor];
    UIColor * textColor;
    if (colorString) {
        textColor = [UIColor colorWithHexString:colorString];
    }else{
        textColor = MAIN_TINT_COLOR;
    }
    
    NSObject<I_W_DisplayValue> *displayValue = [[WSDefaultStringDisplayValue alloc] init];
    NSObject *obj = [displayValue getServerRedisValue:buildInfo];
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *value = (NSString *)obj;
        //MMSH-7467
        self.segmentedStr = nil;
        if ([value containsString:kStoreKPICellServerRedisValueSegmentedMark]) {
            NSArray *array = [value componentsSeparatedByString:kStoreKPICellServerRedisValueSegmentedMark];
            if (array.count >= 2) {
                value = [array firstObject];
                self.segmentedStr = [NSString stringWithFormat:@"%@", [array lastObject]];
            }
        }
        [self setUpTitleLabelAttributeString:value andColor:textColor];
    } else {
        [self.upTitleLabel setText:@"--"];
    }
}

#pragma mark - 获取分割结果方法
- (NSString *)getSegmentedResult {
    return self.segmentedStr;
}

-(void)setUpTitleLabelAttributeString:(NSString *)text andColor:(UIColor *)textColor{
    NSArray * textArray = [text componentsSeparatedByString:@"@"];
    if (textArray.count == 2) {
        NSString * numberString = [textArray firstObject];
        NSString * unitString = [textArray lastObject];
        NSMutableAttributedString * attriStrig = [[NSMutableAttributedString alloc]initWithString:numberString attributes:@{NSForegroundColorAttributeName:textColor,
                         NSFontAttributeName: FONT_SIZE_PINGFANG_MEDIUM(upTitleLabelFontSize)                                                                                                }];
        NSAttributedString * unitAttriString = [[NSAttributedString alloc]initWithString:unitString attributes:@{NSForegroundColorAttributeName:textColor,
              NSFontAttributeName: FONT_SIZE_PINGFANG_MEDIUM(downTitleLabelFontSize -2)                                                                                                  }];
        [attriStrig appendAttributedString:unitAttriString];
        
        self.upTitleLabel.attributedText = attriStrig;
        
    }else{
        self.upTitleLabel.text = text;
    }

}
@end
