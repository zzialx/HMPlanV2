//
//  WSMonthCollectionHeadView.m
//  WinSFA
//
//  Created by heju on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMonthCollectionHeadView.h"

#define MONTH_HEAD_COLOR_THEME1 ([UIColor redColor])//大红色
#define MONTH_HEAD_COLOR_THEME ([UIColor colorWithRed:26/256.0  green:168/256.0 blue:186/256.0 alpha:1])
#define MONTH_HEAD_BG_COLOR  ([UIColor whiteColor]) //([UIColor colorWithRed:17.0/255 green:127.0f/255 blue:196.0f/255 alpha:1.0f])
#define MONTH_HEAD_COLOR_THEME3 ([UIColor blackColor])

@interface WSMonthCollectionHeadView () {
    
}

@property (nonatomic ,assign) CGSize headSize;
@property (weak, nonatomic) UILabel *day1OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day2OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day3OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day4OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day5OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day6OfTheWeekLabel;
@property (weak, nonatomic) UILabel *day7OfTheWeekLabel;


@end

@implementation WSMonthCollectionHeadView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = MONTH_HEAD_BG_COLOR;
        _headSize = frame.size;
        [self createHeadLabel];
    }
    return self;
}

- (void)createHeadLabel {
    //一，二，三，四，五，六，日
    
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 0.0f;
    
    CGFloat dayLabelWidth = _headSize.width/7;
    CGFloat dayLabelHeight = 43.0f;
    
    UIFont *font = [UIFont boldSystemFontOfSize:14]; //[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]
    
    UILabel *dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day1OfTheWeekLabel = dayOfTheWeekLabel;
    self.day1OfTheWeekLabel.textAlignment = NSTextAlignmentCenter;
    self.day1OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day1OfTheWeekLabel];
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day2OfTheWeekLabel = dayOfTheWeekLabel;
    self.day2OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day2OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day2OfTheWeekLabel];
    
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day3OfTheWeekLabel = dayOfTheWeekLabel;
    self.day3OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day3OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day3OfTheWeekLabel];
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day4OfTheWeekLabel = dayOfTheWeekLabel;
    self.day4OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day4OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day4OfTheWeekLabel];
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day5OfTheWeekLabel = dayOfTheWeekLabel;
    self.day5OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day5OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day5OfTheWeekLabel];
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day6OfTheWeekLabel = dayOfTheWeekLabel;
    self.day6OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day6OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day6OfTheWeekLabel];
    
    xOffset += dayLabelWidth;
    dayOfTheWeekLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset,yOffset, dayLabelWidth, dayLabelHeight)];
    [dayOfTheWeekLabel setBackgroundColor:[UIColor clearColor]];
    [dayOfTheWeekLabel setFont:font];
    self.day7OfTheWeekLabel = dayOfTheWeekLabel;
    self.day7OfTheWeekLabel.textAlignment=NSTextAlignmentCenter;
    self.day7OfTheWeekLabel.textColor = MONTH_HEAD_COLOR_THEME3;
    [self addSubview:self.day7OfTheWeekLabel];
    
    [self updateWithDayNames:@[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"]];
}

//设置 @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"
- (void)updateWithDayNames:(NSArray *)dayNames
{
    for (int i = 0 ; i < dayNames.count; i++) {
        switch (i) {
            case 0:
                self.day1OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 1:
                self.day2OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 2:
                self.day3OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 3:
                self.day4OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 4:
                self.day5OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 5:
                self.day6OfTheWeekLabel.text = dayNames[i];
                break;
                
            case 6:
                self.day7OfTheWeekLabel.text = dayNames[i];
                break;
                
            default:
                break;
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
