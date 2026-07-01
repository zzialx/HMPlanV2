//
//  WSPerson4Store.h
//  WinSFA
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WSPerson4Store : NSObject

/**
 *  门店信息
 */
@property(nonatomic,copy) NSString * storeName;

/**
 *  门店位置
 */
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
/**
 *  门店icon
 */

@property(nonatomic,copy)NSString * icon;
@end
