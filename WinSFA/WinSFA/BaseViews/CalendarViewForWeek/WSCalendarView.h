//
//  CalendarView.h
//  日历
//
//  Created by zhiqing on 16/7/21.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSCalendarViewDelegate <NSObject>

-(void)queryDataFromDBByDate:(NSDate *)date;

@end

@interface WSCalendarView : UIView
@property(nonatomic,weak) id <WSCalendarViewDelegate>delegate;
@end
