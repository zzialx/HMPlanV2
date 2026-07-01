//
//  WSPickerView.h
//  WinSFA
//
//  Created by Alicia on 16/11/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSDatePickerLabel.h"

typedef enum WSPickerViewType : NSUInteger {
    WSPickerViewTypeTime,
    WSPickerViewTypeDate,
    WSPickerViewTypeDateAndTime,
    WSPickerViewTypeDateYear,
    WSPickerViewTypeDateYearMonth,
    WSPickerViewTypeCountDownTimer,
    WSPickerViewTypeDatas
} WSPickerViewType;


typedef void(^didSelectPickerDataBlock)(NSObject * data,BOOL isOK); // 是否通过点击确定按钮选择

@interface WSPickerView : UIView

@property(nonatomic, strong) NSArray * dataSources;

@property(nonatomic, copy) didSelectPickerDataBlock didSelectBlock;

@property(nonatomic, assign) WSPickerViewType pickerType;

@property(nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic) NSTimeInterval countDownDuration;

@property (nonatomic) NSInteger minuteInterval;
@property (nonatomic , assign) BOOL isAddDeleteButton;

@property (nonatomic, strong) UIPickerView *pickerView;

- (void)setDateStr:(NSString *)dateStr;
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

+ (WSPickerViewType)convertToPickerViewTypeFromDatePickerMode:(UIDatePickerMode)mode;
+ (WSPickerViewType)convertToPickerViewTypeFromDatePickerLabelMode:(WSDatePickerLabelMode)mode;

+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type;
+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray;
+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray isAddDeleteButton:(BOOL)isAddDeleteButton;
+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type isAddDeleteButton:(BOOL)isAddDeleteButton;

+ (WSPickerView *)showPickerViewInVCTop:(UIViewController *)VC withType:(WSPickerViewType)type;
+ (WSPickerView *)showPickerViewInView:(UIView *)view withType:(WSPickerViewType)type;


- (void)setDefaultSelectedData:(NSArray *)selectedDataArray;

@end
