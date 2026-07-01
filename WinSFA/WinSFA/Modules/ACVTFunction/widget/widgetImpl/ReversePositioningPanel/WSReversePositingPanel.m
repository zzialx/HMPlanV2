//
//  WSReversePositingPanel.m
//  WinSFA
//
//  Created by mac on 17/4/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSReversePositingPanel.h"
#import "WSRPMapViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "NSString+Additions.h"
#import "I_W_DisplayValue.h"
#import "WSInterAction.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "NSString+WSJSON.h"
#import "WinRPMapViewController.h"
#import "WinRPMapPOI.h"
#import "WSEnvrionment.h"

#define kMaxmnum      2000000

@interface WSReversePositingPanel () <AMapSearchDelegate>
@property(nonatomic,strong) UILabel * addressLabel;
@property(nonatomic,assign) CGFloat selfHeight;
@property (nonatomic , assign) CLLocationCoordinate2D wgs84Coordinate;
@property(nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic , strong) NSDictionary* areaCode;

@end

@implementation WSReversePositingPanel

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}

-(void)buildDisplayContent{
    // mlen 显示的条数 ， mnum最大范围
    [super buildDisplayContent];
    
    self.height = self.frame.size.height;
    
    UILabel * startInputPosition = [[UILabel alloc]init];
    startInputPosition.text = NSLocalizedString(@"please_select_address", nil);
    startInputPosition.textColor = MAIN_TINT_COLOR;
    startInputPosition.textAlignment = NSTextAlignmentRight;
    startInputPosition.userInteractionEnabled = YES;
    startInputPosition.frame = CGRectMake(self.titleLabel.right, self.titleLabel.top, self.width - self.titleLabel.right - MAIN_CELL_PADDING, self.titleLabel.height);
    UITapGestureRecognizer * getsture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpMapViewControlller)];
    [startInputPosition addGestureRecognizer:getsture];
    [self addSubview:startInputPosition];
    
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.left, self.titleLabel.bottom,self.width - 2 * MAIN_CELL_PADDING, 30)];
    _addressLabel.font = [UIFont systemFontOfSize:UI_Font];
    _addressLabel.numberOfLines = 0;
    _addressLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_addressLabel];
    
    _selfHeight = self.height;
    NSString *address;
    float lat = 0;
    float lon = 0;
    NSString* l_dis = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    _originalValue = l_dis;
    //SFA-25675  donghong //SFA-25732。兼容 字典形式和逗号分隔
    if(l_dis != nil && [l_dis length] > 0)
    {
        NSString *str = (NSString *)l_dis;
        if ([l_dis containsString:GPS_LAT] && [l_dis containsString:GPS_LON]) {
            NSDictionary *dic =[NSString parseJSONStringToNSDictionary:str];
            if(dic)
            {
                address = [dic objectForKey:GPS_LOC_ADDR];
                lat = [[dic objectForKey:GPS_LAT] floatValue];
                lon = [[dic objectForKey:GPS_LON] floatValue];
            }
        } else if ([l_dis containsString:@","]){
            NSArray *geoArray = [l_dis componentsSeparatedByString:@","];
            lat = [geoArray[0] floatValue];
            lon = [geoArray[1] floatValue];
            if (geoArray.count > 2) {
                address = geoArray[2];
            }
        }
    }
    
    CGSize size = [address ws_sizeWithFont:[UIFont systemFontOfSize:15] constrainedToWidth:self.width - 2 * MAIN_CELL_PADDING];
    self.addressLabel.height = size.height;
    self.addressLabel.text = address;
    self.height = self.height + size.height + MAIN_PADDING;
    self.wgs84Coordinate = CLLocationCoordinate2DMake(lat, lon);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.height);
}

-(void)jumpMapViewControlller{
    /**
    WSRPMapViewController * rpMapviewCtrl = [[WSRPMapViewController alloc]init];
    NSString * range = [xbuildInfo getMumx];
    if (!range || range.length == 0) {
        range = @"3000";
    }
    NSString * maxItem = [xbuildInfo getMumx];
    if (!maxItem || maxItem.length == 0 || [maxItem integerValue ] > 50) {
        maxItem = @"20";
    }
    rpMapviewCtrl.title = [xbuildInfo getQuestName];
    rpMapviewCtrl.range = range;
    
    rpMapviewCtrl.maxItem = maxItem;

    rpMapviewCtrl.condition = [xbuildInfo getAcvtMemo];
    
    rpMapviewCtrl.searchPlaceholder = [xbuildInfo getDefaultValue];
    
    __weak typeof(self)weakSelf = self;
    
    // 对回调的值 进行处理
    rpMapviewCtrl.confirmButtomClick = ^(AMapPOI * poi,NSString * provinceCityDistricy){
        
        CGSize size = [poi.address ws_sizeWithFont:[UIFont systemFontOfSize:15] constrainedToWidth:weakSelf.width - 2 * MAIN_CELL_PADDING];
        weakSelf.addressLabel.height = size.height;
        weakSelf.addressLabel.text = poi.address;
        weakSelf.height = weakSelf.selfHeight + size.height + MAIN_PADDING;
        CLLocationCoordinate2D gcj02Coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        // 转成标准信息上传
        weakSelf.wgs84Coordinate = [CoordinateTransform transCoordinate:gcj02Coordinate from:@"gcj02" to:@"wgs84"];
        weakSelf.resultCheck =  provinceCityDistricy;
        if ([weakSelf.delegate respondsToSelector:@selector(executeLuaScript:widget:)] ) {
            [weakSelf.delegate executeLuaScript:weakSelf.xbuildInfo widget:weakSelf];
        }
    };

    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    [interaction setExecute_controller:rpMapviewCtrl];

    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {

        [delegate executeInterAction:interaction];

    }
     
 */
    
    //用新的 *******************************
    NSString *range = [xbuildInfo getMumx];
    if (!range || range.length == 0) {
        range = @"3000";
    } else if ([range integerValue] >= kMaxmnum) {
        range = @"";
    }
    
    NSString *maxItem = [xbuildInfo getMumx];
    if (!maxItem || maxItem.length == 0 || [maxItem integerValue] > 50) {
        maxItem = @"20";
    }
    
    WinRPMapViewController *vc = [[WinRPMapViewController alloc] init];
    vc.title = [xbuildInfo getQuestName];
    vc.searchPlaceholder = [xbuildInfo getDefaultValue];
    vc.searchRange = range;
    vc.searchCount = maxItem;
    vc.searchPOI = [xbuildInfo getAcvtMemo];
    
    __weak typeof(self)weakSelf = self;
    vc.confirmBlock = ^(WinRPMapPOI *uploadData){
        CGSize size = [uploadData.address ws_sizeWithFont:[UIFont systemFontOfSize:15] constrainedToWidth:weakSelf.width - 2 * MAIN_CELL_PADDING];
        weakSelf.addressLabel.height = size.height;
        weakSelf.addressLabel.text = uploadData.address;
        weakSelf.height = weakSelf.selfHeight + size.height + MAIN_PADDING;
        
        weakSelf.wgs84Coordinate = uploadData.wgs84Location.coordinate;
        weakSelf.resultCheck = uploadData.provinceCityDistricy;
        weakSelf.areaCode = uploadData.areaCodeDic;
        
        if ([weakSelf.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [weakSelf.delegate executeLuaScript:weakSelf.xbuildInfo widget:weakSelf];
        }
    };
    
    WSInterAction *interaction =[[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    [interaction setExecute_controller:vc];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

- (NSObject *)getResultPresentation {
    /*Jira - MENGNIU-1248 create by sunhongfu 2017-11-10  要地址文字 不是坐标*/
    return [NSString stringWithFormat:@"%@",self.addressLabel.text];
    //    if (self.wgs84Coordinate.latitude > 0 && self.wgs84Coordinate.longitude > 0) {
    //
    //        return [NSString stringWithFormat:@"%f,%f", self.wgs84Coordinate.latitude, self.wgs84Coordinate.longitude];
    //
    //    }
    //
    //    return nil;
}

- (NSObject *)getCurrentValue{
    
    if (self.wgs84Coordinate.latitude > 0 && self.wgs84Coordinate.longitude > 0)
    {
        CLLocation * location = [[CLLocation alloc]initWithLatitude:self.wgs84Coordinate.latitude longitude:self.wgs84Coordinate.longitude];
        return [[WSLocationManager getLocationUploadDataWithLocation:location andAddress:self.addressLabel.text] JSONString];
    }
    else
    {
        return @"";
    }
}

// 问题需要上传的数据
-(NSObject *)getResultDirectly{
    //MMSH-3052 IOS-SFA 玛氏中国MWC--uat环境--门店管理--新增批发渠道，填写其他必填项，不填写国家行政和门店地址时，不校验必填，新增成功
    if (self.wgs84Coordinate.latitude > 0 && self.wgs84Coordinate.longitude > 0)
    {
        CLLocation * location = [[CLLocation alloc]initWithLatitude:self.wgs84Coordinate.latitude longitude:self.wgs84Coordinate.longitude];
         return [[WSLocationManager getLocationUploadDataWithLocation:location andAddress:self.addressLabel.text] JSONString];
    }
    else
    {
        return nil;
    }
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.userInteractionEnabled = NO;
    }
    
}


@end
