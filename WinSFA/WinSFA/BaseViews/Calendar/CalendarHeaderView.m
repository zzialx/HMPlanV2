//
//  CalendarHeaderView.m
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import "CalendarHeaderView.h"
#import "WSDimensMacros.h"
#import "UIColor+Additions.h"


@implementation CalendarHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor=[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1];
        
        UIView * top_lineLayer=[[UIView alloc]init];
        top_lineLayer.backgroundColor=[UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1];
        top_lineLayer.frame=CGRectMake(0, 0, frame.size.width, 1);
        [self addSubview:top_lineLayer];
        
        UIView * bototm_lineLayer=[[UIView alloc]init];
        bototm_lineLayer.backgroundColor=[UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1];
        bototm_lineLayer.frame=CGRectMake(0, frame.size.height-1, frame.size.width, 1);
        [self addSubview:bototm_lineLayer];
        
        
        NSArray *weekArray = [self getDaysOfTheWeek];
        
        for (int i=0; i<weekArray.count; i++) {
            UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*self.bounds.size.width/7.f, 0, self.bounds.size.width/7.f, HeaderViewHeight)];
            weekLabel.textAlignment = NSTextAlignmentCenter;
            weekLabel.textColor = [UIColor colorWithHexString:@"#7b7b7b"];
            weekLabel.font = [UIFont systemFontOfSize:UI_Font_Cell];
            weekLabel.text = weekArray[i];
            [self addSubview:weekLabel];
        }
        
    }
    return self;
}

- (NSArray *)getDaysOfTheWeek {
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    
    // adjust array depending on which weekday should be first
    NSArray *weekdays = [dateFormatter shortWeekdaySymbols];
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSUInteger firstWeekdayIndex = [calendar firstWeekday] -1;
    if (firstWeekdayIndex > 0)
    {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7-firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0,firstWeekdayIndex)]];
    }
    return weekdays;
}
@end
