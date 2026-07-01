//
//  WSCalendarFollowUpDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/5/7.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSCalendarFollowUpDataInfoModel;
@class WSCalendarFollowUpStoreDataInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface WSCalendarFollowUpDataModel : NSObject
@property (nonatomic, copy)    NSArray <WSCalendarFollowUpDataInfoModel * >*getLeaderList;//下层人员
@property (nonatomic, copy)    NSArray <WSCalendarFollowUpDataInfoModel * >*getSrList;//下层人员
@property (nonatomic, copy)    NSArray <WSCalendarFollowUpDataInfoModel * >*getSrStoreList;//下层人员

@end

@interface WSCalendarFollowUpDataInfoModel : NSObject
@property (nonatomic, copy)    NSString *Id;
@property (nonatomic, copy)    NSString *name;
@property (nonatomic, assign)  NSInteger number;

@end

NS_ASSUME_NONNULL_END
