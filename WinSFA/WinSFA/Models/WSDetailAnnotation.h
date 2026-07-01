//
//  WSDetailAnnotation.h
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class WSSalePersonModel;
@class WSPerson4Store;
@interface WSDetailAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

//数据模型
@property (nonatomic, strong) WSSalePersonModel *saleModle;

@property (nonatomic,strong) WSPerson4Store * personModel;
@end
