//
//  WSCheckBox.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-9-17.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCheckBox : UIButton <WSValidateData, WSGettingValues>

/**
 发送消息前缀 一般为 fc_col 或者 mc_col
 **/
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//是否是被依赖体
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, assign) BOOL isValueChange;
// 新增记录checkbox是否被点击
@property (nonatomic, assign) BOOL isClicked;
// SFA-22277
@property (nonatomic, assign) BOOL isNotUploadEmpty;
//add by xiajunling 2014-07-01 for checkbox所属类型 COL_TYPCHECKBOX 或 COL_TYPCHECKBOXALL 
@property (nonatomic, copy)NSString *tpy;

@property (nonatomic, copy)NSString *m_col;


- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;


- (BOOL)entityIsEnable;

//WSGettingValues
//- (BOOL)isValueLegal;

@end
