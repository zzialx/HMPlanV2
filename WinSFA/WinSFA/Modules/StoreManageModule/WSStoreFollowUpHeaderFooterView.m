//
//  WSStoreFollowUpHeaderFooterView.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSStoreFollowUpHeaderFooterView.h"

static CGFloat const kStoreFollowUpViewHeaderViewOffset    = 10;

@interface WSStoreFollowUpHeaderFooterView ()
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *noFollowUpLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSStoreFollowUpHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

#pragma mark - Controls
- (void)addControls {
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *planLabel = [[UILabel alloc] init];
    planLabel.font = [UIFont systemFontOfSize:15];
    planLabel.textColor = [UIColor blackColor];
    planLabel.text =  @"计划：15";
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.font = [UIFont systemFontOfSize:15];
    endLabel.textColor = [UIColor blackColor];
    endLabel.text =  @"已随访：15";
    endLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *noFollowUpLabel = [[UILabel alloc] init];
    noFollowUpLabel.font = [UIFont systemFontOfSize:15];
    noFollowUpLabel.textColor = [UIColor blackColor];
    noFollowUpLabel.text =  @"未随访：15";
    noFollowUpLabel.textAlignment = NSTextAlignmentRight;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    
    [self.contentView addSubview:planLabel];
    [self.contentView addSubview:endLabel];
    [self.contentView addSubview:noFollowUpLabel];
    [self.contentView addSubview:view];
    
    
    self.planLabel = planLabel;
    self.endLabel = endLabel;
    self.noFollowUpLabel = noFollowUpLabel;
    self.linView = view;
    
}
- (void)setWithPlanNum:(NSInteger)planNum endNum:(NSInteger)endNum noFollowUpNum:(NSInteger)noFollowUpNum
{
    self.planLabel.text = [NSString stringWithFormat:@"计划:%ld",planNum];
    self.endLabel.text = [NSString stringWithFormat:@"已随访:%ld",endNum];
    self.noFollowUpLabel.text = [NSString stringWithFormat:@"未随访:%ld",noFollowUpNum];
    
}
- (void)layoutControls {
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat offsetX = kStoreFollowUpViewHeaderViewOffset;
    CGFloat offsetY = 0;
    self.planLabel.frame = CGRectMake(offsetX, offsetY , viewWidth / 3 - offsetX , viewHeight);
    self.endLabel.frame = CGRectMake(viewWidth / 3, offsetY , viewWidth / 3 , viewHeight);
    self.noFollowUpLabel.frame = CGRectMake(viewWidth / 3 * 2, offsetY , viewWidth / 3 - offsetX , viewHeight);
    self.linView.frame = CGRectMake(0, viewHeight - 1, viewWidth - offsetX, 1);
}
@end


