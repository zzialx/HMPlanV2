//
//  WCStartEndDateView.h
//  StartEndDate
//
//  Created by ZhengJiepeng on 13-4-1.
//  Copyright (c) 2013年 ZhengJiepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCStartEndDateView;

@protocol WCStartEndDateViewDelegate <NSObject>

@optional


- (void)WCStartEndDateViewValueChanged:(WCStartEndDateView *)aWCStartEndDateView;

- (void)showDatePickerView:(WCStartEndDateView *)aWCStartEndDateView andSelectedBtn:(UIButton *)selectedbtn;


@end


@interface WCStartEndDateView : UIView <UIActionSheetDelegate>

@property (nonatomic, assign) BOOL readRonly;

@property (nonatomic, copy) NSString *startTitle;
@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, copy) NSString *endTitle;
@property (nonatomic, strong) NSDate *endDate;

//控件日期区间 区间起始时间
@property (nonatomic, strong) NSDate *sectionStartDate;
//控件日期区间 区间结束时间
@property (nonatomic, strong) NSDate *sectionEndDate;

@property (nonatomic, weak) id<WCStartEndDateViewDelegate> delegate;

@property (nonatomic, assign)UIDatePickerMode pickerMode;

@property (nonatomic, assign)BOOL isSinglePicker;

@property (nonatomic, strong) NSString *lastStartDateString; //单个日期模式，记录上次时间

- (instancetype)initWithFrame:(CGRect)frame
       withDateMode:(UIDatePickerMode)pickerMode
 withIsSinglePicker:(BOOL)isSinglePicker
         dateString:(NSString *)dateString
   dateFormatString:(NSString *)dateFormatString;

- (void)setStartEndTitleByString:(NSString *)aString;
- (void)setStartDateWithString:(NSString *)startDateString;
- (void)setEndDateWithString:(NSString *)endDateString;
- (NSString *)getValueByString;


-(void)setSelectedDate:(NSDate *)date forBtn:(UIButton *)button;

@end
