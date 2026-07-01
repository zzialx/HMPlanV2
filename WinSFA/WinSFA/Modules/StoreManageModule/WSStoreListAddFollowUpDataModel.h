//
//  WSStoreListAddFollowUpDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/5/12.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WSStoreListAddFollowUpDataInfoModel;

@interface WSStoreListAddFollowUpDataModel : NSObject

@property (nonatomic, copy)    NSArray <WSStoreListAddFollowUpDataInfoModel *>*addFollowUpStoreSearchList;

@property (nonatomic, copy)    NSArray <WSStoreListAddFollowUpDataInfoModel *>*addTskfFollowUpStoreSearchList;

@end

@interface WSStoreListAddFollowUpDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *empName;//下属人员
@property (nonatomic, copy)  NSString *empId;//下属人员id
@property (nonatomic, copy)  NSString *storeName;//门店名称
@property (nonatomic, copy)  NSString *storeId;//门店ID
@property (nonatomic, copy)  NSString *leaderId;//主管id
@property (nonatomic, copy)  NSString *leaderName;//主管id
@end
NS_ASSUME_NONNULL_END
