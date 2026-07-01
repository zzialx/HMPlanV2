//
//  WSAddressCheckPanel.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/18.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSAddressCheckPanel.h"
#import "I_M_View.h"
#import "I_W_BuildInfo.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "WSEnvrionment.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "WSResolveAddressManager.h"
//========================================================================================================================================================================

#pragma mark - 地址检测控件 延展(内部)
@interface WSAddressCheckPanel () <BMKGeoCodeSearchDelegate, AMapSearchDelegate>

@property (nonatomic, strong) UIButton *callButton;         //校验按键
@property (nonatomic, strong) BMKGeoCodeSearch *baiduSearch;//百度搜索
@property (nonatomic, strong) AMapSearchAPI *gaodeSearch;   //高德搜索

@end
//========================================================================================================================================================================

#pragma mark - 地址检测控件
@implementation WSAddressCheckPanel

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        return self;
    }
    return nil;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _baiduSearch.delegate = nil;
    _gaodeSearch.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    CGFloat height = orientition ? self.height : MAIN_CELL_BUTTON_WH;
    self.callButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.callButton.frame = CGRectMake(self.width - MAIN_CELL_BUTTON_WH, (self.frame.size.height - MAIN_CELL_BUTTON_WH) / 2, MAIN_CELL_BUTTON_WH, height);
    [self.callButton setTitle:@"校验" forState:UIControlStateNormal];
    [self.callButton setTitle:@"校验" forState:UIControlStateSelected];
    self.callButton.tintColor = MAIN_TINT_COLOT;
    self.callButton.titleLabel.tintColor = MAIN_TINT_COLOT;
    [self.callButton addTarget:self action:@selector(checkDown) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.callButton];
    
    if (orientition) {
        CGRect newFrame = self.textField.frame;
        newFrame.size.width -= MAIN_CELL_BUTTON_WH;
        self.textField.frame = newFrame;
    }
    
    CGFloat seperatOffsetY = (self.size.height - MAIN_CELL_SEPERATOR_LENGTH) / 2;
    UIView *sperateLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.callButton.frame), seperatOffsetY, 1, MAIN_CELL_SEPERATOR_LENGTH)];
    sperateLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:sperateLineView];
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    if (orientition) {
        CGRect newFrame = self.textField.frame;
        newFrame.size.width -= MAIN_CELL_BUTTON_WH;
        self.textField.frame = newFrame;
    }
}

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 校验按键响应方法
- (void)checkDown {
    
    [self endEditing:YES];
    
    NSString *address = [NSString stringNotNilWithValue:self.textField.text];
    if (address.length == 0) {
        [SVProgressHUD showHudMsg:@"请输入地址"];
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //监听逆地理编码地址通知，二者只会有一个通知被监听到
        [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(geoCodeSearchAddress:) name:@"geoCodeSearchAddress" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(geoPOISearchAddress:) name:kWinPOISearchNotifi object:nil];

        if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
            
            if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                _resultCheck = strongSelf.textField.text;
                [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onCheck(" widget:self];
            }
        }
    });
    
    
}

#pragma mark - 获取baiduSearch方法
- (BMKGeoCodeSearch *)baiduSearch {
    
    if (!_baiduSearch) {
        _baiduSearch = [[BMKGeoCodeSearch alloc] init];
    }
    return _baiduSearch;
}

#pragma mark - 获取gaodeSearch方法
- (AMapSearchAPI *)gaodeSearch {
    
    if (!_gaodeSearch) {
        _gaodeSearch = [[AMapSearchAPI alloc] init];
    }
    return _gaodeSearch;
}

#pragma mark - geoCodeSearchAddress通知回调方法(脚本内执行getGpsReserve方法 会发通知)
- (void)geoCodeSearchAddress:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"geoCodeSearchAddress" object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"please_wait", nil)  tips:nil tapTarget:self action:nil];
    
    NSDictionary *dic = [notification object];
    NSString *searchStr = [dic objectForKey:@"geoCodeSearch"];
    NSString *address = searchStr;
    NSString *city = @"";
    if ([searchStr containsString:@"@#"]) {
        NSArray *array = [searchStr componentsSeparatedByString:@"@#"];
        address = [array firstObject];
        city = [array lastObject];
    }
    
    if ([WSEnvrionment getUseBaiduMap]) {
        
        BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc] init];
        geoCodeSearchOption.address = address;
        geoCodeSearchOption.city = city;
        
        self.baiduSearch.delegate = self;
        [self.baiduSearch geoCode:geoCodeSearchOption];
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        geo.address = address;
        geo.city = city;
        self.gaodeSearch.delegate = self;
        [self.gaodeSearch AMapGeocodeSearch:geo];
    }
}
#pragma mark - geoPOISearchAddress通知回调方法(脚本内执行getGpsReserve方法 会发通知)

- (void)geoPOISearchAddress:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWinPOISearchNotifi object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"please_wait", nil)  tips:nil tapTarget:self action:nil];
    
    NSDictionary *dic = [notification object];
    NSString *searchStr = [dic objectForKey:@"geoCodeSearch"];
    NSString *address = searchStr;
    NSString *city = @"";
    if ([searchStr containsString:@"@#"]) {
        NSArray *array = [searchStr componentsSeparatedByString:@"@#"];
        address = [array firstObject];
        city = [array lastObject];
    }
    
    if ([WSEnvrionment getUseBaiduMap]) {
        
        BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc] init];
        geoCodeSearchOption.address = address;
        geoCodeSearchOption.city = city;
        
        self.baiduSearch.delegate = self;
        [self.baiduSearch geoCode:geoCodeSearchOption];
    }else if ([WSEnvrionment getuseGeoAmap]) {
       
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords = address;
        request.city = city;
        __weak __typeof__(self) weakSelf = self;

        void(^searchResultBlock)(NSArray *array, NSError *error) = ^(NSArray *array, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            if (!array || array.count == 0) {
                LogError(@"POI搜索失败或无结果: %@", error ?: @"未知错误");
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                                     withText:@"地址信息解析失败，请重试或修改填写内容"
                                        tips:nil
                                   tapTarget:strongSelf
                                      action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
            AMapPOI *poi = [array firstObject];
            if (!poi || !poi.location) {
                LogError(@"POI位置信息无效");
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                                     withText:@"地址信息解析失败，请重试或修改填写内容"
                                        tips:nil
                                   tapTarget:strongSelf
                                      action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
            NSString *longitudeLabel = [NSString stringWithFormat:@"%.6f", poi.location.longitude];
            NSString *latitudeLabel = [NSString stringWithFormat:@"%.6f", poi.location.latitude];
            LogInfo(@"POI搜索结果 - 地址: %@, 坐标: %@,%@", poi.address, latitudeLabel, longitudeLabel);
            
            if ([xbuildInfo getLuaScript].length > 0 &&
                [delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                _resultCheck = [NSString stringWithFormat:@"%@@#%@", latitudeLabel, longitudeLabel];
                [delegate executeLuaScript:xbuildInfo
                                    script:[xbuildInfo getLuaScript]
                                 funcName:@"function onResult("
                                   widget:strongSelf];
            }
        };
        
        [[WSResolveAddressManager shareInstance] startAMapPOIKeywordsSearchWith:request withBlock:searchResultBlock];
    }
}
#pragma mark - 实现onGetGeoCodeResult:result:errorCode:协议(返回地址信息搜索结果)
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    self.baiduSearch.delegate = nil;
    
    NSString *longitudeLabel = @"0";
    NSString *latitudeLabel = @"0";
    if (error == BMK_SEARCH_NO_ERROR) {
        longitudeLabel = [NSString stringWithFormat:@"%.6f", result.location.longitude];
        latitudeLabel = [NSString stringWithFormat:@"%.6f", result.location.latitude];
    }
    
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            _resultCheck = [NSString stringWithFormat:@"%@@#%@", latitudeLabel, longitudeLabel];
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onResult(" widget:self];
        }
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    LogError(@"search error");
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow
                         withText:@"地址信息解析失败，请重试或修改填写内容"
                            tips:nil
                       tapTarget:self
                          action:nil type:MBProgressHUDMessageTypeFailed];
    //失败需要清楚之前的成功记录
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            _resultCheck = @"";
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onChange(" widget:self];
        }
    }
}

#pragma mark - 实现onGeocodeSearchDone:response:协议(返回地址信息搜索结果)
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    self.gaodeSearch.delegate = nil;
    
    AMapGeocode *mapGeocode = [response.geocodes firstObject];
    NSString *longitudeLabel = @"0";
    NSString *latitudeLabel = @"0";
    if (mapGeocode) {
        longitudeLabel = [NSString stringWithFormat:@"%.6f", mapGeocode.location.longitude];
        latitudeLabel = [NSString stringWithFormat:@"%.6f", mapGeocode.location.latitude];
    }
    LogInfo(@"onGeocodeSearchDone lat--->%@,lon--->%@",latitudeLabel,longitudeLabel);
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            _resultCheck = [NSString stringWithFormat:@"%@@#%@", latitudeLabel, longitudeLabel];
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onResult(" widget:self];
        }
    }
}

#pragma mark - 实现textField:shouldChangeCharactersInRange:replacementString:协议
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            _resultCheck = @"";
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onChange(" widget:self];
        }
    }
    
    return YES;
}

#pragma mark - 重写runScript方法
- (void)runScript {
    
    if ([xbuildInfo getLuaScript] != nil && [[xbuildInfo getLuaScript] length] > 0) {
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            _resultCheck = @"";
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onChange(" widget:self];
        }
    }
}

- (void)MessageView:(NSObject<I_M_View> *)messageView clickAtButtonIndex:(NSInteger)index {

}

- (void)MessageViewClickAtCancel:(NSObject<I_M_View> *)messageView {
    
}

@end
//========================================================================================================================================================================
