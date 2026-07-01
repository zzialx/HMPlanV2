//
//  ZYCalendarDayCell.h
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateView.h"

@interface ZYCalendarDayCell : UICollectionViewCell{

    NSArray *_eventArray;
}

@property (nonatomic, strong) NSDate* p_date;

@property (nonatomic, strong)  DateView *dateView;
@property (nonatomic, assign) BOOL isExChangeMap;

@property (nonatomic, assign) NSInteger number;


- (void)SetEventArray:(NSArray *)eventArray;

- (void)removeEventArray:(NSArray *)eventArray;

@end
