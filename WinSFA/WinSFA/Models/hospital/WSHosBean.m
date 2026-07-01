//
//  HosBean.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-15.
//
//

#import "WSHosBean.h"

@implementation WSHosBean

@synthesize sid = _sid;
@synthesize Id = _Id;
@synthesize name = _name;
@synthesize cod = _cod;
@synthesize isPlan = _isPlan;

@synthesize hosBeanArray = _hosBeanArray;

- (id)initHosWithObject:(id)object isPlan:(BOOL)isPlan {
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _isPlan = isPlan;
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *storeDectionary = (NSDictionary *)object;
            _sid = [[self getStringValueFromDic:storeDectionary withKeyName:@"sid"] copy];
            _Id = [[self getStringValueFromDic:storeDectionary withKeyName:@"id"] copy];
            _name = [[self getStringValueFromDic:storeDectionary withKeyName:@"name"] copy];
            _cod = [[self getStringValueFromDic:storeDectionary withKeyName:@"cod"] copy];
            
            NSArray *hosArray = [storeDectionary objectForKey:@"hos"];
            if ([hosArray count]) {
                _hosBeanArray = [[NSMutableArray alloc] initWithCapacity:[hosArray count]];
            }
            for (NSDictionary *dic in hosArray) {
                WSHosBean *hosBean = [[WSHosBean alloc] initHosWithObject:dic isPlan:isPlan];
                [_hosBeanArray addObject:hosBean];
            }
            
            _state = [[self getStringValueFromDic:storeDectionary withKeyName:@"state"] copy];

//            self.cellid = [NSString stringWithValue:[storeDectionary objectForKey:Store_cellid]];
//            self.code = [NSString stringWithValue:[storeDectionary objectForKey:Store_cod]];
//            self.Id = [NSString stringWithValue:[storeDectionary objectForKey:Store_id]];
//            self.pid = [NSString stringWithValue:[storeDectionary objectForKey:Store_pid]];
//            self.name = [storeDectionary objectForKey:Store_name];
//            self.styp = [storeDectionary objectForKey:Store_styp];
//            self.addr = [storeDectionary objectForKey:Store_addr];
//            
//            //add by wangdongyan 03-08
//            self.sv = [NSString stringWithValue:[storeDectionary objectForKey:Store_sv]];
//            
//            // parse GPS info
//            id t = [object objectForKey:Store_GEO];
//            t = [t objectAtIndex:0];
//            t = [t objectForKey:@"lon"];
//            if ([t isKindOfClass:[NSNull class]]) {
//                self.longitude = 0;
//            } else {
//                self.longitude = [t doubleValue];
//            }
//            
//            t = [object objectForKey:Store_GEO];
//            t = [t objectAtIndex:0];
//            t = [t objectForKey:@"lat"];
//            if ([t isKindOfClass:[NSNull class]]) {
//                self.latitude = 0;
//            } else {
//                self.latitude = [t doubleValue];
//            }
        }
        
//        [self initStoreWithObject:object];
    }
    
    return self;
}

//- (id)initHosWihDict:(WSDictBean *)dict storeId:(NSString *)storeId  isPlan:(BOOL)isPlan {
//    if (dict == nil) {
//        return nil;
//    }
//    self = [super init];
//    if (self) {
//        _isPlan = isPlan;
//        _sid = storeId;
//        _Id = dict.Id;
//        _name = dict.name;
//        _cod = dict.cod;
//        _hosBeanArray = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

- (id)initHosWihDepartmentId:(NSString *)departmentId departmentName:(NSString *)departmentName storeId:(NSString *)storeId  isPlan:(BOOL)isPlan iconUrl:(NSString *)iconUrl{

    self = [super init];
    if (self) {
        _isPlan = isPlan;
        _sid = storeId;
        _Id = departmentId;
        _name = departmentName;
        _iconUrl = iconUrl;
        _hosBeanArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)initHosWihStore:(WSStoreBean *)doctStore storeId:(NSString *)hosStoreId isPlan:(BOOL)isPlan {
    if (doctStore == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        _isPlan = isPlan;
        _sid = hosStoreId;
        _Id = doctStore.Id;
        _name = doctStore.name;
        _cod = doctStore.name;
        _hosBeanArray = [[NSMutableArray alloc] init];
        _state = doctStore.state;
    }
    return self;
}


- (NSString *)getStringValueFromDic:(NSDictionary *)aDic withKeyName:(NSString *)aKey {
    if (aDic == nil || aKey == nil) {
        return nil;
    }
    id value = [aDic objectForKey:aKey];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithValue: value];
    }
    
    return nil;
}


@end
