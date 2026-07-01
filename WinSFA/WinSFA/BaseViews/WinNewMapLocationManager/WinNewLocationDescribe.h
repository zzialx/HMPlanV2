//
//  WinNewLocationDescribe.h
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 定位信息
@interface WinNewLocationDescribe : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;//位置坐标
@property (nonatomic, copy) NSString *address;                          //地址
@property (nonatomic, copy) NSString *province;                         //省
@property (nonatomic, copy) NSString *city;                             //市
@property (nonatomic, copy) NSString *district;                         //区
@property (nonatomic, copy) NSString *locality;                         //地点
@property (nonatomic, copy) NSString *poiName;                         //模糊地点

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
