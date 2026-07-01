//
//  WSSalePersonModel.h
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface WSSalePersonModel : NSObject
/**
 *  销售人员姓名
 */
@property(nonatomic,copy) NSString * name;

/**
 *  图标
 */
@property(nonatomic,copy) NSString * icon;

/**
 *  人员位置
 */
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;

/**
 *  店名
 */
@property(nonatomic,copy) NSString * storeName;

/**
 *  人员需要拜访的门店信息
 */
@property(nonatomic,strong) NSArray * person4store;

@end
