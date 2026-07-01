//
//  DateView.h
//  ZYCalendar
//
//  Created by winchannel on 16/10/29.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define RESTIMAGEWIDTH (INTERFACE_IS_PHONE ? 14 : 14)

typedef enum {
    DateButtonStateNormal,
    DateButtonStateSelected,
    DateButtonStateToday
} DateButtonState;

@interface DateView : UIView
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *eventCountLabel;
@property (nonatomic, assign) DateButtonState state;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL isExchangeMap;

@property (nonatomic, strong) UILabel *labNumber;

-(void)removeEventArray:(NSArray *)eventArray;
   
- (void)setEventArray:(NSArray *)eventArray;

- (void)reloadDateViewWithArray:(NSArray *)array;

@end
