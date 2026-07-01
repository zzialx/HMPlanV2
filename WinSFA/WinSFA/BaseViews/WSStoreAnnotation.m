//
//  WSStoreAnnotation.m
//  WinSFA
//
//  Created by heju on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSStoreAnnotation.h"

@implementation WSStoreAnnotation

-(NSString *)title{
    return [NSString stringWithFormat:@"%@",self.storeName];
}
-(NSString *)subtitle{
    
    if (self.store.isShowMapCallout) {
        return self.store.code;
    }
    
    if ([self.store.addr length] > 0) {
        return self.store.addr;
    }else {
        return [super subtitle];
    }
}
 
- (id)initWith:(CLLocationCoordinate2D)coordiante annotationStore:(WSStoreBean *)store{
    
    _store = store;
    return [self initWith:coordiante storeId:store.Id storeName:store.name];
}

- (id)initWith:(CLLocationCoordinate2D)coordiante storeId:(NSString *)storeId
     storeName:(NSString *)storeName {
    if (self = [super init]) {
         self.coordinate = coordiante;
        self.wgs84Coordinate = coordiante;
        _storeId = storeId;
        _storeName = storeName;
    }
    return self;
    
}


-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate storeId:(NSString *)storeId
         storeName:(NSString *)storeName
{
    self = [super initWithWgs84:wgs84Coordinate title:storeName];
    if(self != nil)
    {
        _storeId = storeId;
        _storeName = storeName;
        
    }
    return self;
}

-(id)initWithWgs84:(CLLocationCoordinate2D)wgs84Coordinate annotationStore:(WSStoreBean *)store {
    self = [super initWithWgs84:wgs84Coordinate title:store.name];
    if(self != nil)
    {
        _storeId = store.Id;
        _storeName = store.name;
        _store = store;
        
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@-->{coordinate:{latitude=%12f,longitude=%12f},title:%@,subtitle:%@,storeName:%@,storeId:%@}",
            [self className],
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.title,
            self.subtitle,
            self.storeName,
            self.storeId];
}

@end
