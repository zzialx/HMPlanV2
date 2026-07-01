//
//  WSPlanRouteListTableViewHeaderView.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanRouteListTableViewHeaderView.h"


static CGFloat const kPlanRouteListViewHeaderViewOffset    = 10;

@interface WSPlanRouteListTableViewHeaderView ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSPlanRouteListTableViewHeaderView

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
    
    [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"#efefef"]];
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text =  @"路线名称";
    
    UILabel *planLabel = [[UILabel alloc] init];
    planLabel.font = [UIFont systemFontOfSize:15];
    planLabel.textColor = [UIColor blackColor];
    planLabel.text =  @"执行状态";
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.text =  @"执行日期";
    
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:planLabel];
    [self.contentView addSubview:timeLabel];
    
    
    self.nameLabel = nameLabel;
    self.planLabel = planLabel;
    self.timeLabel = timeLabel;
    
}

- (void)layoutControls {
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat offsetX = kPlanRouteListViewHeaderViewOffset;
    CGFloat offsetY = 0;
    self.nameLabel.frame = CGRectMake(offsetX, offsetY , viewWidth / 3 , viewHeight);
    self.planLabel.frame = CGRectMake(viewWidth / 3 + offsetX, offsetY , viewWidth / 5 , viewHeight);
    self.timeLabel.frame = CGRectMake(viewWidth / 3 + viewWidth / 5 + offsetX, offsetY , viewWidth / 3  , viewHeight);
}
@end
