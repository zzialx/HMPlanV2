//
//  WSAnnotation.h
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class WSSalePersonModel;
@class WSPerson4Store;
@interface WSAnnotation : NSObject<MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) WSSalePersonModel *saleModel;
@property (nonatomic,strong) WSPerson4Store * personModel;
//是否显示描述视图
@property (nonatomic, assign) BOOL isShowDesc;
@end
