//
//  WSStoreAnnotation.h
//  WinSFA
//
//  Created by heju on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseAnnotation.h"

@interface WSStoreAnnotation : WSBaseAnnotation

@property (nonatomic,copy) NSString *storeName;
@property (nonatomic,copy) NSString *storeId;
@property (nonatomic,strong) WSStoreBean *store;

@property (nonatomic, assign) BOOL isNewSet;            //是否新的设置方法
@property (nonatomic, copy) NSString *annotationImgStr; //注释图片名称
@property (nonatomic, assign) BOOL isShowRowNumber;     //是否展示RowNumber标示

/*gcj的annotaion*/
-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate
           storeId:(NSString *)storeId
         storeName:(NSString *)storeName;

-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate
   annotationStore:(WSStoreBean *)store;

/*wgs84的anotation*/
- (id)initWith:(CLLocationCoordinate2D)coordiante storeId:(NSString *)storeId
     storeName:(NSString *)storeName;

- (id)initWith:(CLLocationCoordinate2D)coordiante annotationStore:(WSStoreBean *)store;

@end
