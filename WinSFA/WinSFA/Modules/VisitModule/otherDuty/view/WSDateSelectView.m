//
//  WSDateSelectView.m
//  WinSFA
//
//  Created by yang on 16/11/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDateSelectView.h"
#import "PureLayout.h"

#define kTitleLeftPadding 10
#define kTitleTopPadding 15
#define kLableGap 5

@interface WSDateSelectView ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *weekFormatter;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *weekLabel;

@end

@implementation WSDateSelectView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title date:(NSDate *)date
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [UILabel newAutoLayoutView];
        titleLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kTitleLeftPadding];
        [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTitleTopPadding];
        [titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.3 relation:NSLayoutRelationLessThanOrEqual];
        
        
        UILabel *dateLabel = [UILabel newAutoLayoutView];
        dateLabel.textColor = MAIN_TINT_COLOT;
        dateLabel.font = [UIFont systemFontOfSize:UI_Font];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        [dateLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:titleLabel];
        [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kTitleLeftPadding];
        [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTitleTopPadding];
        
        UILabel *weekLabel = [UILabel newAutoLayoutView];
        weekLabel.textColor = [UIColor grayColor];
        weekLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:weekLabel];
        self.weekLabel = weekLabel;
        
        [weekLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:dateLabel];
        [weekLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:dateLabel withOffset:kLableGap];
        [weekLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:dateLabel];
        
        
        self.date = date;
        
    }
    
    return self;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter standardDateFormatter];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)weekFormatter
{
    if (!_weekFormatter) {
        _weekFormatter = [NSDateFormatter currentLocaleDateFormatter];
        [_weekFormatter setDateFormat:@"EEE"];
    }
    
    return _weekFormatter;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    if (date) {
        [self.dateLabel setText:[self.dateFormatter stringFromDate:date]];
        [self.weekLabel setText:[self.weekFormatter stringFromDate:date]];
    }else {
        self.dateLabel.text = nil;
        self.weekLabel.text = nil;
    }

}

- (NSString *)getDateString
{
    return self.dateLabel.text;
}

@end
