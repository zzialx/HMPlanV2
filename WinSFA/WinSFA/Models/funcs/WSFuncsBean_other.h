//
//  FuncsBean_other.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-5-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSFuncsBean_other : NSObject


//{
//    NSString* col;
//	NSString* name;
//	NSString* tpy;
//	int wcol;
//	NSString* max;
//	NSString* min;
//	NSString* pcs;
//	int readonly; 
//	NSString* redis;
//    
//    NSString *ds;
//    NSString *filter;
//}

@property(nonatomic,strong,readonly)NSString* col;
@property(nonatomic,strong,readonly)NSString* name;
@property(nonatomic,strong,readonly)NSString* tpy;
@property(nonatomic,assign,readonly)int wcol;
@property(nonatomic,strong,readonly)NSString* max;
@property(nonatomic,strong,readonly)NSString* min;
@property(nonatomic,strong,readonly)NSString* pcs;
@property(nonatomic,assign,readonly)int readonly;
@property(nonatomic,strong,readonly)NSString* redis;
@property(nonatomic,strong,readonly)NSString* ds;
@property(nonatomic,strong,readonly)NSString* filter;
// add by xiajunling 2014-07-14 for 新增计算公式字段  MSTD-944
@property (nonatomic, copy, readonly) NSString *value;
@property (nonatomic, copy, readonly) NSString *reg;
@property (nonatomic, copy, readonly) NSString *regname;

@property (nonatomic, readonly, assign)   NSInteger   isSupperLocalPhoto;       //是否支持从本地选择照片(1标示支持从本地读取照片，0标示不支持，默认为0)
@property (nonatomic, readonly, assign)   NSInteger   maxPhoto;                 //可提交的照片最大数量(未指定为0，标示没有限制)

@property (nonatomic, readonly, strong) NSString*   mdefault;       //默认显示数据

- (id)initFuncsOtherBeanObject:(id)object;

@end
