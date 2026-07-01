//
//  ZYCalendarDayCell.m
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import "ZYCalendarDayCell.h"
#import "DateUtil.h"

const NSString *ZYCalendarDayCellIdentifier = @"ZYCalendarDayCellIdentifier";

@implementation ZYCalendarDayCell

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self SetInitValue];
    }
    return self;
}

- (void)SetInitValue{
    
    self.dateView = [[DateView alloc]initWithFrame:self.bounds];
    [self.contentView addSubview:self.dateView];

}

- (void)setP_date:(NSDate *)p_date{
    
    _p_date = p_date;
    self.dateView.date = p_date;
     self.dateView.isExchangeMap = self.isExChangeMap;
    if ([DateUtil checkSameDayWithDay1:p_date withDay2:[NSDate date]]) {
        [self.dateView setState:DateButtonStateToday];
    }else{
        
        [self.dateView setState:DateButtonStateNormal];
        
    }

}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if ([DateUtil checkSameDayWithDay1:self.p_date withDay2:[NSDate date]]) {
        [self.dateView setState:DateButtonStateToday];
    }else{
        
        if (selected) {
            [self.dateView removeEventArray:nil];
            [self.dateView setState:DateButtonStateSelected];
           
        }else{
            [self SetEventArray:_eventArray];
             [self.dateView setState:DateButtonStateNormal];
        }
    }
    
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    if(number > 0)
    {
        self.dateView.labNumber.text = [NSString stringWithFormat:@"%ld",number];
    }
    else
    {
        self.dateView.labNumber.text = @"";
    }
}
- (void)SetEventArray:(NSArray *)eventArray{
    
    _eventArray = [NSArray arrayWithArray:eventArray];
    
    [self.dateView setEventArray:eventArray];
}

- (void)removeEventArray:(NSArray *)eventArray{
    
    [self.dateView removeEventArray:eventArray];
}


@end
