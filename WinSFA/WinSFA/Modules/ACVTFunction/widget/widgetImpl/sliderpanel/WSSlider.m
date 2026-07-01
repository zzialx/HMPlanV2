//
//  WSSlider.m
//  WinSFA
//
//  Created by Alicia on 17/1/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSlider.h"
#import "NSString+Additions.h"


@interface WSSlider ()

@property (strong, nonatomic) UILabel *valueLabel;

@end

@implementation WSSlider

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.multiplier = 1;
    
    UILabel *valueLabel = [[UILabel alloc] init];
    [valueLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [valueLabel setTextColor:MAIN_TINT_COLOR];
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
    
    self.minimumTrackTintColor = MAIN_TINT_COLOR;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateValueLabel];
}

#pragma mark - Public Method
- (void)isHideValueLabel:(BOOL)isHideValueLabel {
    _isHideValueLabel = isHideValueLabel;
    [self.valueLabel setHidden:isHideValueLabel];
}

- (NSString *)getResultDirectly {
    return [self getDisplayValueWithIsMultiply:YES isSearch:NO];
}

- (NSString *)getDisplayValueWithIsMultiply:(BOOL)isMultiply isSearch:(BOOL)isSearch {
    if (!FLOAT_IS_EQUAL(self.value, 0)) {
        float value = self.value;
        if (isMultiply) {
            value = value * self.multiplier;
        }
        
        // 搜索条件的字符串是 isReverse 为 NO，查询小于5的值 即 @#5，isReverse 为 YES，则查询大于5 的值 即 5@#
        NSString *distanceSeprator = @"";
        NSString *lowerSeprator = @"";
        NSString *upperSeprator = @"";
        if (isSearch) {
            if (self.isDistance) {
                distanceSeprator = QST_SEARCH_DISTANCE;
            } else {
                if (!self.isReverse) {
                    lowerSeprator = QST_SEARCH_RANGE_SEPARATOR;
                } else {
                    upperSeprator = QST_SEARCH_RANGE_SEPARATOR;
                }
            }
        }
        if (![self.dLen isEqualToString:@"0"]) {
            NSString *formatString = [NSString stringWithFormat:@"%@%@%%.%ldf%@", distanceSeprator, lowerSeprator, (long)[self.dLen integerValue], upperSeprator];
            return [NSString stringWithFormat:formatString, value];
        } else {
            return [NSString stringWithFormat:@"%@%@%ld%@", distanceSeprator, lowerSeprator, (long)value, upperSeprator];
        }
    } else {
        return nil;
    }
}

- (NSString *)getSearchCondition {
    return [self getDisplayValueWithIsMultiply:YES isSearch:YES];
}


#pragma mark - Private method

- (CGRect)thumbRect {
    return  [self thumbRectForBounds:self.bounds
                           trackRect:[self trackRectForBounds:self.bounds]
                               value:self.value];
}

- (void)updateValueLabel {
    if (self.isHideValueLabel) {
        return;
    }
    if (self.value) {
        [self.valueLabel setHidden:NO];
    } else {
        [self.valueLabel setHidden:YES];
    }
    
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    NSString *memo = [self.valueLabelMemo length] > 0 ? self.valueLabelMemo : @"";
    NSString *valueString = [NSString stringWithFormat:@"%@%@", [self getDisplayValueWithIsMultiply:NO isSearch:NO], memo];
    [self.valueLabel setText:valueString];
    
    CGSize valueSize = [valueString ws_sizeWithFont:self.valueLabel.font constrainedToWidth:self.width];
    CGRect labelRect = CGRectInset(thumbRect, (thumbW - valueSize.width)/2, (thumbH - valueSize.height)/2);
    labelRect.origin.y = thumbRect.origin.y - valueSize.height;
    [self.valueLabel setFrame:labelRect];
}



@end
