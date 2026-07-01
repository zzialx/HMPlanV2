//
//  CalendarModel.h
//  日历
//
//  Created by zhiqing on 16/7/22.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCalendarModel : NSObject
@property(nonatomic,copy) NSString *week;
@property(nonatomic,copy) NSDate *day;
@property(nonatomic,copy) NSString *state;
@property(nonatomic,assign) BOOL isSelected;
@end
