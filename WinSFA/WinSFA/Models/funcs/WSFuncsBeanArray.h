//
//  FuncsBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define FUNCS @ "funcs"
#define IS_SHOW @ "isShow"
#define SHOW_FUNCS_BEAN @ "showFuncsBean"
#define FROM_FUNCS_BEAN @ "fromfuncsBean"
#define MOBILE_HOME_PAGE_READING_TIME    @"readingTime"

#import <Foundation/Foundation.h>

@class WSFuncsBean;

@interface WSFuncsBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *funcsArray;
@property (nonatomic, strong) NSMutableArray *hidefuncsArray;

- (id)initWithObject:(id)object;
- (WSFuncsBean *)getFuncsBeanFromSubFC:(NSString *)subMenu;
- (WSFuncsBean *)getParentFuncsBeanWithFk:(NSString *)fk;
- (WSFuncsBean *)getAllFuncsBeanWithFC:(NSString *)fc;
- (WSFuncsBean *)getFuncsBeanWithFC:(NSString *)fc;
- (WSFuncsBean *)getFuncsBeanWithFV:(NSString *)fv;
- (WSFuncsBean *)getFuncsBeanWithFilter:(NSString *)filter;

/**
 先从funcsArray中查询，查不到再从hidefuncsArray（隐藏菜单中查）

 @param FC 菜单编码
 @return 菜单
 */
- (WSFuncsBean *)getFuncsBeanFromAllFucsWithFC:(NSString *)FC;

/**
 * 从隐藏的funcsArray中根据fc查找funcs。
 * 隐藏的funcsArray为：除去应用显示的整个funcs树，剩下的funcs。这些funcs不在程序中显示，但会用于为其他模块提供数据，例如调查问卷中的表格。
 *（箭牌首发，根据Android的逻辑，原来调查问卷从tb节点获取表格数据，现在tb节点已废弃，改为配置一个不显示的funcs为调查问卷的表格提供数据）
 **/
- (WSFuncsBean *)getHideFuncsBeanWithFC:(NSString *)fc;

- (WSFuncsBean *)getHideFuncsBeanWithFV:(NSString *)FV;

- (NSArray *)getHideSubFuncBeanArrayWithPK:(NSString *)pk;
-(NSDictionary *)getShowFuncsBean;
@end
