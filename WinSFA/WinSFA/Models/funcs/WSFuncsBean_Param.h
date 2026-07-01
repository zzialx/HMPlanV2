//
//  FuncsBean_Param.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSAcvtBean_qst;

@interface WSFuncsBean_Param : NSObject <NSCopying>

@property (nonatomic, strong /*, readonly*/) NSString    *charNum;
@property (nonatomic, strong /*, readonly*/) NSString    *col;
@property (nonatomic, strong /*, readonly*/) NSString    *name;
@property (nonatomic, strong /*, readonly*/) NSString    *tpy;
@property (nonatomic, assign /*, readonly*/) NSInteger   wcol;
@property (nonatomic, strong /*, readonly*/) NSString    *max;
@property (nonatomic, strong /*, readonly*/) NSString    *min;
@property (nonatomic, strong /*, readonly*/) NSString    *pcs;
@property (nonatomic, assign/*, readonly*/) NSInteger   readonly;
@property (nonatomic, strong /*, readonly*/) NSString    *redis;
@property (nonatomic, strong /*, readonly*/) NSString    *value;
@property (nonatomic, strong /*, readonly*/) NSString    *listener;
@property (nonatomic, strong /*, readonly*/) NSString    *filter;
@property (nonatomic, assign /*, readonly*/) NSInteger isMutex;
@property (nonatomic, strong /*, readonly*/) NSString *buttonname;
@property (nonatomic, strong /*, readonly*/) NSString *isReq;
@property (nonatomic, strong /*, readonly*/) NSString *answerColor;
@property (nonatomic, strong /*, readonly*/) NSString *valueSize;

// For single selection list
@property (nonatomic, strong /*, readonly*/) NSArray *iSelectionItems;
@property (nonatomic, assign /*, readonly*/) NSInteger iDefaultItemIndex;

@property (nonatomic, strong /*, readonly*/) NSString *isfilled;
@property (nonatomic, strong /*, readonly*/) NSString *idefault; //default value
@property (nonatomic, assign /*, readonly*/) BOOL isSupperLocalPhoto;
// 用作QS类型控件判断是否支持手动编辑多个序列号
@property (nonatomic, assign /*, readonly*/) BOOL isSupportEdit;
@property (nonatomic, strong /*, readonly*/) NSString *hints;
@property (nonatomic, assign /*, readonly*/) NSInteger sort;
@property (nonatomic, assign /*, readonly*/) BOOL isRealtime; // 是否需要实时请求数据

@property (nonatomic, copy) NSString *ids; //中粮稽核使用 数据源
@property (nonatomic, copy) NSString *iDependon;
@property (nonatomic, copy) NSString *mappingAcvtQstDs;

//辉瑞etrip增加，用于FPT中某一列的校验。如果该字段不为空，给定产品价格为p,则当输入价格高于 (1 + alert) * p 和小于 (1 - alert) * p 时，输入内容标红
@property (nonatomic, copy) NSString *alert;
// 正则表达式 MSTD-925
@property (nonatomic, copy) NSString *reg;

/*列是否隐藏*/
//配置为1.隐藏不回显到首页 2。隐藏回显到首页
@property (nonatomic, strong) NSString *gone;

@property (nonatomic, strong) NSString *tip;

@property (nonatomic, strong /*, readonly*/) NSString *mappingAcvtQstId;
// 问题是否隐藏
@property (nonatomic,copy) NSString *isHidden;

// 参数为align-对齐方式，参数中的数值分三种：L为左对齐，C为居中，R为右对齐
@property (nonatomic,copy) NSString *align;

@property (nonatomic, copy) NSString *paramDescript; //参数描述

//蒙牛新增
//采集项转问题
@property (nonatomic, copy)NSString *groupName;

@property (nonatomic, copy)NSString *widthPercent;

@property (nonatomic, copy)NSString *hideQstName;

// SFA-13283 立白新增，需要在添加产品页直接填写的列，此参数为1
@property (nonatomic, copy)NSString *AddEdit;

// SFA-15823 泸州老窖新增，验证回显更多某列不能为空，不为空时才回显到表格
@property (nonatomic, copy) NSString *needValidateMoreProdRedisValue;

// SFA-22265 东莞鸿兴新增，解决 checkbox 点击过但是没有值，值使用空而非0
@property (nonatomic, assign) BOOL isNotUploadEmpty;

// SFA-17367 新增父级列，下拉选择框支持级联选择
@property (nonatomic, copy) NSString *parent;

// SFA-20682 opt中isRedisMoreHome配置了为1，该列即使有回显数据产品也不显示 . 操作逻辑等同与LNR，但是上传
@property (nonatomic, strong, /*readonly*/) NSString    *isRedisNoMoreHome;

//蒙牛新增 MN-3576 参数为1，编辑wshtextfeild时，弹窗编辑框
@property (nonatomic, copy) NSString *coljumpinput;

@property (nonatomic, copy) NSString *ispopup;// "ispopup":"N" 如果配了这个，就不弹详情了

- (id)initFuncs_ParamWithObject:(id)object;
- (NSInteger)specIndex;

/**
 * 用于以表格形式展示acvt列表（箭牌增加）
 **/
- (id)initFuncsParamWithAcvtQstBean:(WSAcvtBean_qst *)acvtQstBean;

@end
