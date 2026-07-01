//
//  WSStoreDataService.h
//  WinSFA
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^updateFinish)(WSLocationDescribe * locationDescribe,BOOL isNeedRefresh);

@interface WSStoreDataService : NSObject

@property (nonatomic , copy) updateFinish updateFinishBlock;  // 回调地址信息

+(instancetype)shareInstance;

/**
 更新门店表中的距离

 @param storeArray 门店表的数组
 @param locationDescribe 当前定位的信息
 @return 是否更新成功
 */
-(BOOL)updateStoreTableWithStoreArray:(NSArray *)storeArray locationDescribe:(WSLocationDescribe *)locationDescribe;

// 根据上一次的定位信息，对比是否需要去更新门店距离
-(BOOL)isNeedUpdateStoreDistanceWith:(WSLocationDescribe *)locationDescribe;

//MN-4713 IOS 门店列表显示的定位不准 (添加objID)
-(void)checkAndUpdateStoreDistanceWithCurrentFuncs:(WSFuncsBean *)currentFuncs andSubEmpId:(NSString *)subEmpId andObjectId:(NSString *)objID withBlock:(updateFinish)updateFinishBlock;

@end
