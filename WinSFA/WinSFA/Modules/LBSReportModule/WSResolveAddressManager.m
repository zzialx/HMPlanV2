//
//  WSResolveAddressManager.m
//  WinSFA
//
//  Created by mac on 17/3/20.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSResolveAddressManager.h"

static WSResolveAddressManager *resolveAddressManager = nil;


@interface WSResolveAddressManager ()<AMapSearchDelegate>
@property (nonatomic , strong)  AMapReGeocodeSearchRequest *regeo;
@property (nonatomic , strong) AMapSearchAPI * search;
@end


@implementation WSResolveAddressManager

+(instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resolveAddressManager = [[WSResolveAddressManager alloc]init];
    });
    
    return resolveAddressManager;
}

-(instancetype)init{
    if (self == [super init]) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return self;
}
-(void)startGetFormattedAddressWith:(CLLocationCoordinate2D)coordinate2D withBlock:(getFormattedAddress)getAddressBlock{
    
    if (getAddressBlock) {
        self.getAddressBlock = getAddressBlock;
    }

    _regeo = [[AMapReGeocodeSearchRequest alloc] init];
    _regeo.requireExtension = YES;
    
    _regeo.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    [self.search AMapReGoecodeSearch:_regeo];
    
}

-(void)startGetReGeocodeSearchWith:(NSString *)address withBlock:(getGeocodes)getGeocodesBlock{
    if (getGeocodesBlock) {
        self.getGeocodesBlock = getGeocodesBlock;
    }
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = address ;
    [self.search AMapGeocodeSearch:geo];

}

-(void)startGetAroundSearchWith:(AMapPOIAroundSearchRequest *)request withBlock:(getPois)getPoisBlock
{
    if (getPoisBlock) {
        
        self.getPoisBlock = getPoisBlock;
    }
    
    [self.search AMapPOIAroundSearch:request];
}


-(void)startAMapPOIKeywordsSearchWith:(AMapPOIKeywordsSearchRequest *)request withBlock:(getPois)getPoisBlock
{
    if (getPoisBlock) {
        
        self.getPoisBlock = getPoisBlock;
    }
    
    [self.search AMapPOIKeywordsSearch:request];
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if (self.getAddressBlock) {
        
        self.getAddressBlock(response.regeocode,nil);
        self.getAddressBlock = nil;
    }
}


/* 地理编码回调. */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (self.getGeocodesBlock) {
        self.getGeocodesBlock(response.geocodes ,nil);
        self.getGeocodesBlock = nil;
    }

}

/* POI查询回调函数 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    if (self.getPoisBlock) {
        self.getPoisBlock(response.pois ,nil);
        self.getPoisBlock = nil;
    }
}
/*当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。*/
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
//    NSString * errorMsg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
//    NSString * errorMsg = @"";
    // 添加一个默认提示
    LogError(@"Error: %@", error);
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        // YIHAIKERRY-2758 //MN-4460    关闭网络新增门店卡死
        if (self.getAddressBlock) {
            self.getAddressBlock(nil,error);
            self.getAddressBlock = nil;
        }
//          if (errorMsg.length == 0 ) {
//              errorMsg = NSLocalizedString(@"解析位置失败", nil);
//          }
    }else if ([request isKindOfClass:[AMapGeocodeSearchRequest class]]){

        if (self.getGeocodesBlock) {
            self.getGeocodesBlock(nil,error);
            self.getGeocodesBlock = nil;
        }

//        if (errorMsg.length == 0 ) {
//            errorMsg = NSLocalizedString(@"获取地理信息失败", nil);
//        }
    }else if ([request isKindOfClass:[AMapPOISearchBaseRequest class]]){

        if (self.getPoisBlock) {
            self.getPoisBlock(nil,error);
            self.getPoisBlock = nil;
        }

//        if (errorMsg.length == 0 ) {
//            errorMsg = NSLocalizedString(@"查询周边数据失败", nil);
//        }
    }
    
//    if (errorMsg.length > 0) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:errorMsg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }

}
@end
