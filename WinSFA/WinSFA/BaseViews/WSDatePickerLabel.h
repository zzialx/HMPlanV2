//
//  WSDatePickerLabel.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-27.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSYMPickView.h"

typedef enum {
    WSDatePickerLabelModeDate,
    WSDatePickerLabelModeYM,/*只显示年月*/
    WSDatePickerLabelModeTime
}WSDatePickerLabelMode;

@class WSDatePickerLabel;

@protocol WSDatePickerLabelDelegate <NSObject>

- (void)datePickerLabel:(WSDatePickerLabel *)datePickerLabel valueChanged:(NSString *)value;

- (void)didSelectedDatePickerLabel:(WSDatePickerLabel *)datePickerLabel;

@end

@interface WSDatePickerLabel : UILabel <WSValidateData, WSGettingValues,WSYMPickerViewDelegate>

@property (nonatomic, assign) BOOL isValueChange;

@property (nonatomic, weak) id<WSDatePickerLabelDelegate> delegate;

@property (nonatomic, assign) WSDatePickerLabelMode datePickerLaberMode;

- (id)initWithFrame:(CGRect)frame param:(WSFuncsBean_Param *)aParam;

#pragma mark - 依赖关系
//row and column
@property (nonatomic, assign) unsigned int m_nRow;
@property (nonatomic, assign) unsigned int m_nColumn;

// 控件的表格属性
@property (nonatomic, copy) NSString  *m_col;
//是否被依赖
@property (nonatomic, assign) BOOL m_isDepended;

//前缀
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//依赖类型
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, strong) NSString *minValue;
@property (nonatomic, strong) NSString *maxValue;

/**
 创建日历icon
 */
- (void)createDatePickerIconWith:(WSDatePickerLabelMode)datePickerLabelMode;

/**
 添加border
 */
- (void)changeStyle;

- (void)addTimeImageToView;

//WSValidateData function
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;

- (BOOL)entityIsEnable;

//Getting value
- (NSString *)getTextValue;

- (BOOL)isValueLegal;


- (void) setTimeText:(NSString *)timeText;

@end
