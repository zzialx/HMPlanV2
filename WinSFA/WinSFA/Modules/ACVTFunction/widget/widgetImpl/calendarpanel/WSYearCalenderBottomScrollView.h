//
//  WSYearCalenderBottomScrollView.h
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSMonthBottomView.h"



@protocol WSYearCalenderBottomScrollViewDelegate;

@interface WSYearCalenderBottomScrollView : UIView <WSMonthBottomDelegate>

@property (nonatomic,weak)id<WSYearCalenderBottomScrollViewDelegate>delegate;

@end

@protocol WSYearCalenderBottomScrollViewDelegate <NSObject>

- (void)yearCalenderBottomScrollView:(WSYearCalenderBottomScrollView *)yearCalender selectedYear:(NSString *)year month:(NSString *)month;

@end