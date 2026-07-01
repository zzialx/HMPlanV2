//
//  WSYMPickView.h
//  WinSFA
//
//  Created by heju on 16/2/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSYMPickerViewDelegate;

typedef enum {
    WSDatePickerSheetModeDate,
    WSDatePickerSheetModeY,
    WSDatePickerSheetModeYM,
    WSDatePickerSheetModeTime
}WSDatePickerSheetMode;

@interface WSYMPickView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>


@property (nonatomic,strong)NSMutableArray *years;
@property (nonatomic,strong)NSArray *months;
@property (nonatomic,strong)NSString *currentYear;
@property (nonatomic,strong)NSString *currentMonth;
@property (nonatomic,strong)NSString *selecteDate;

@property (nonatomic, strong) NSString *nowDateStr;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDate *minDate;

@property (nonatomic ,assign) WSDatePickerSheetMode pickeMode;

@property (nonatomic, weak) id <WSYMPickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withNowDateStr:(NSString *)nowDateStr maxDate:(NSDate *)maxDateStr minDate:(NSDate *)minDateStr withPickerMode:(WSDatePickerSheetMode)PickerSheetMode;

@end


@protocol WSYMPickerViewDelegate <NSObject>

- (void)pickView:(WSYMPickView *)pickView selectedDate:(NSString *)date;

@end
