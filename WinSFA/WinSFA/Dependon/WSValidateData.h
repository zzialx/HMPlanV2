//
//  WSValidateData.h
//  KVODemo
//
//  Created by 王晓堂 on 13-8-31.
//  Copyright (c) 2013年 wxt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSValidateDataDependType)
{
    WSValidateDataDependNone,      //无依赖
    WSValidateDataDependOtherData, //依赖其它数据
    WSValidateDataIsDepended,      //被依赖数据
    WSValidateDataDependOtherDataAndIsDepended       //依赖与被依赖同时存在
};

typedef NS_ENUM(NSInteger, WSValidateDataLogicType)
{
    WSValidateDataLogicNone,       //无
    WSValidateDataLogicAND,      //与
    WSValidateDataLogicOR        //或
};

typedef NS_ENUM(NSInteger, WSValidateDataValue)
{
    WSValidateDataValueDisenable = 0,    //enable = no
    WSValidateDataValueEnable = 1,       //enable = yes
    WSValidateDataValueInitialize = 2    //初始化
};

@protocol WSValidateData <NSObject>

@optional

/**
 发送消息前缀 一般为 fc_col 或者 mc_col
 **/
@property (nonatomic, copy)NSString *iNotificationPrefix;
@property (nonatomic, assign) unsigned int m_nRow;  // 依赖的行号
@property (nonatomic, assign) unsigned int m_nColumn; // 依赖的列号

@property (nonatomic, copy) NSString *dNotificationPrefix;
@property (nonatomic, assign) unsigned int m_dRow;  // 被依赖的行号
@property (nonatomic, assign) unsigned int m_dColumn; // 被依赖的列号

// 是否是依赖体
@property (nonatomic, assign)WSValidateDataDependType dDataType;

//自己的行号
@property (nonatomic, assign)unsigned int iRow;

//自己的行号
@property (nonatomic, assign)unsigned int iColumn;

//是否是被依赖体
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

// 数据是否修改过
@property (nonatomic, assign) BOOL isValueChange;


- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;


- (BOOL)entityIsEnable;

- (BOOL)textCheck;


@end
