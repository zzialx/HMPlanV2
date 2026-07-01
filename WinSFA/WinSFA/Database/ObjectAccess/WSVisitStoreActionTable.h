//
//  WSVisitStoreActionTable.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-20.
//
//

#import <Foundation/Foundation.h>


@interface WSVisitStoreActionTable : WSSqliteUtil

+ (WSVisitStoreActionTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//查询拜访状态
- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction;

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction intOutFlag:(NSString *)flag;

// 是否将 title 作为查询条件 MSTD-4877 为解决中英文切换
- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction isQueryTitle:(BOOL)isQueryTitle;

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction intOutFlag:(NSString *)flag isQueryTitle:(BOOL)isQueryTitle;

//查询前一项拜访状态
//- (VisitActionStatus)queryPreActionStatus:(WSVisitStoreActionObject *)aAction;
// 查询必填且没有完成拜访的拜访状态
- (NSArray *)getPreRequiredUndoneAction:(WSVisitStoreActionObject *)aAction;

//查询_id
- (int)queryActionId:(WSVisitStoreActionObject *)aAction;

//查询必须拜访但没拜访项
- (NSArray *)queryNotCompleteButRequiredAction:(WSVisitStoreActionObject *)aAction;

//更新状态
- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus;

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus inOutFlag:(NSString *)flag;

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus inOutFlag:(NSString *)flag parentForceToDone:(BOOL)parentForceToDone;

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction
            toStatus:(NSString *)aStatus
           inOutFlag:(NSString *)flag
   parentForceToDone:(BOOL)parentForceToDone
  updateParentStatus:(BOOL)updateParentStatus;

- (NSArray *)queryActionsWithObject:(WSVisitStoreActionObject *)aObject;

- (NSArray *)queryActionsWithObjectExceptParentId:(WSVisitStoreActionObject *)aObject;

- (void)insertCurrentAction:(WSVisitStoreActionObject *)aAction;

- (NSString *)queryNotCompleteBrotherFuncsFromMustFillFuncsWithCurrentFc:(NSString *)currentFc withStype:(NSString *)styp withStoreId:(NSString *)storeId;
//自动离店的更改状态
- (void)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status;

@end
