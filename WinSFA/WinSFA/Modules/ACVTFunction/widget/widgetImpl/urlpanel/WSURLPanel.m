//
//  WSURLPanel.m
//  WinSFA
//
//  Created by yang on 15/11/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSURLPanel.h"
#import "WSReportFormController.h"
#import "WSServerIPController.h"
#import "WSServerIPList.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "I_W_DisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSLuaExecutorManager.h"
#import "WSAcvtViewController.h"

#define EXCUSE_RETURN_VALUE_LUA_FUNTION     @"function excuseReturnValue("

#define DefaultHeight 50

@interface WSURLPanel () <WSReportFormControllerDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UILabel *infoLabel;


@property (nonatomic, strong) WSReportFormController *webViewController;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, copy) NSString *selectedIdStr;

/// 箭头图标
@property (nonatomic, strong)UIImageView * arrowIcon;

@end

@implementation WSURLPanel

- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    self.selectedIdStr = [[NSString alloc] init];
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.left, (self.height - self.titleLabel.height)/2, self.titleLabel.width, self.titleLabel.height);
    
    [self addArrowIconImage];
    
    [self addUrlInfoLab];
    
    _originalValue = [xdisplayValue getDisplayValueFor:xbuildInfo];
    
    [self showOriginalValueStringData:(NSString *)_originalValue];

    [self addTapGestureRecognizer];
}

- (void)widgetDidLoadFinish{
    
    BOOL isJump = NO;
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (model.currentFuncs && [model.currentFuncs.opt.isSingleQstToAutoJump isEqualToString:@"1"]) {
        isJump = YES;
    }
    
    if (self.fixedHeight && isJump) { //问题加载完成，问卷只有一个问题时，自动跳转这个功能，默认不开启。增加一个opt参数来判断  SFA-31659
        
        [self removeAllSubviews];
        
        [self addWebViewController];
        
        return;
    }
    
    /* YIHAIKERRY-3084 问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0 && [[xbuildInfo getLuaScript] rangeOfString:@"setValue"].location != NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
     */
}


- (void)widgetWillAppear
{
    [self.webViewController beginAppearanceTransition:YES animated:NO];
    [self.webViewController endAppearanceTransition];
}

- (void)addWebViewController
{
    NSURL *tempUrl = [self getURLByLuaScriptWithURL];
    if (!tempUrl) {
        return;
    }
    
    WSReportFormController *con = [[WSReportFormController alloc] initWithURL:tempUrl];
    self.webViewController = con;
    con.title = [xbuildInfo getQuestName];
    con.delegate = self;
    con.view.frame = self.bounds;
    con.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    con.shouldReloadWhenAppear = NO;
    
    [self addSubview:con.view];
}

- (NSURL *)getUrl
{
    NSString *urlString = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    // SFA-19818 同步安卓逻辑，此问题查出回显值若不是url的形式则继续使用其配置的default值
    if (!urlString || [urlString length] == 0 || ![urlString hasPrefix:@"https://"] || ![urlString hasPrefix:@"http://"]) {
        urlString = [xbuildInfo getDefaultValue];
    }
    NSURL *url;
    if (urlString) {
        urlString = [self processUrl:urlString];
        // SFA-24367 SFA葵花发起PK界面功能——选择人员后再次进入显示之前勾选人员
        if (self.selectedIdStr.length > 0) {
            urlString = [urlString stringByAppendingString:self.selectedIdStr];
        }
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [[NSURL alloc] initWithString:urlString];
    }
    
    return url;
}

- (NSURL *) getURLByLuaScriptWithURL{
    
    //如果通过脚本设置了 URL 则使用脚本设置后的 URL
    return  self.url?self.url:[self getUrl];
    
}

- (void)performClickButton:(id)sender {
    
    [self tapped];
}

- (void)tapped {
    if ([[xbuildInfo getDefaultValue] rangeOfString:@"clickRequire=1"].location != NSNotFound) {
        self.urlNeedValidate = YES;
    }
    NSURL *url = [self getURLByLuaScriptWithURL];
    if (!url) {
        return;
    }
    NSString *readOnly = [xbuildInfo getReadOnly];
    if (readOnly && [readOnly isEqualToString:@"1"]) {
        return;
    }
    
    if ([[xbuildInfo getLuaScript] length] > 0) {
        
        self.url = nil;
        self.resultCheck = [self getDisplayValuePresentation];
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
        // 如果通过脚本设置了 URL 则使用脚本设置后的 URL
        if (self.url) {
            url = self.url;
        }
    }
   
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:url forKey:@"url"];
    if ([xbuildInfo getQuestName]) {
        [dic setObject:[xbuildInfo getQuestName] forKey:@"title"];
    }
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    WSReportFormController *con = [[WSReportFormController alloc] initWithURL:url];
    con.title = [xbuildInfo getQuestName];
    con.delegate = self;
    [interaction setExecute_class_param:dic];
    [interaction setExecute_controller:con];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
    
}

- (NSObject *)getResultDirectly
{
    return [self.dataArray componentsJoinedByString:@","];
}

- (NSObject *)getCurrentValuePresentation{
    
    return [self getResultDirectly];
}

- (NSString *)processUrl:(NSString *)originUrlString
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *url = [originUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([url rangeOfString:StoreIDFormat].location != NSNotFound) {
        if (model.currentStore.Id && ![model.currentStore.Id isEqualToString:@"-1"]) {
            url = [url stringByReplacingOccurrencesOfString:StoreIDFormat withString:model.currentStore.Id];
        }else {
            url = [url stringByReplacingOccurrencesOfString:StoreIDFormat withString:@"-1"];
        }
    }else{
        if (model.currentStore.Id && ![model.currentStore.Id isEqualToString:@"-1"]) {
          if(![url containsString:@"?"])
          {
            if ([url hasSuffix:@"?"]) {
                url = [NSString stringWithFormat:@"%@%@", url, model.currentStore.Id];

            } else {
                url = [NSString stringWithFormat:@"%@?",url];
                url = [NSString stringWithFormat:@"%@%@", url, model.currentStore.Id];

            }
          }
            else
            {
                url = [NSString stringWithFormat:@"%@%@", url, model.currentStore.Id];
            }
        }
    }
    
    if ([url rangeOfString:EmpIDFormat].location != NSNotFound) {
        if ([WSAppData getObjectbyKey:APPDATA_EMPID]) {
            url = [url stringByReplacingOccurrencesOfString:EmpIDFormat withString:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        }
    }
    
    if ([url rangeOfString:SrIDFormat].location != NSNotFound) {
        if (model.currentStore.srid) {
            url = [url stringByReplacingOccurrencesOfString:SrIDFormat withString:model.currentStore.srid];
        } else if (model.currentSubEmpStore.Id) {
            url = [url stringByReplacingOccurrencesOfString:SrIDFormat withString:model.currentSubEmpStore.Id];
        }
    }
    
    if ([url rangeOfString:AcvtIDFormat].location != NSNotFound) {
        if (model.currentAcvtBean.acvtId) {
            url = [url stringByReplacingOccurrencesOfString:AcvtIDFormat withString:model.currentAcvtBean.acvtId];
        }
    }
    
    return url;
    
}

- (NSObject *)getDisplayValuePresentation
{
    return self.infoLabel.text;
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    if (!valuePresentation || [valuePresentation length] == 0) {
        self.dataArray = nil;
        self.infoLabel.text = nil;
        self.selectedIdStr = @"";
    }
     if ([valuePresentation rangeOfString:@"http"].location != NSNotFound)
     {
         NSString *tempUrl = [self processUrl:valuePresentation];
//         tempUrl = [tempUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         
//         [tempUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
         
         
         tempUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)tempUrl,NULL,NULL,kCFStringEncodingUTF8));
         self.url = [NSURL URLWithString:tempUrl];
         if (self.fixedHeight) {
             [self widgetDidLoadFinish];
         }
     }
     else if(valuePresentation && [valuePresentation length] > 0)
    {
        [self loadStringData:valuePresentation];

    }
   
}
- (void)reloadCurrentWidgetWithValue:(NSObject *)value{
    
    [self setCurrentValueWithPresentation:(NSString *)value];

}

- (void)setValueForCurrentObject:(NSObject *)objvalue {
    self.url = [NSURL URLWithString:(NSString *)objvalue];
}

- (void)loadStringData:(NSString *)data {
    NSArray *dataArray = nil;
    
    
    NSArray *selectedIdArray =  [data componentsSeparatedByString:@"@"];
    if (selectedIdArray.count > 1) {
        self.selectedIdStr = [selectedIdArray firstObject];
    }
    
    if ([data length] > 0) {
        dataArray = [data componentsSeparatedByString:@","];
    }
    
    NSMutableString *str = [NSMutableString string];
    
    for (NSString *dataStr in dataArray) {
        NSArray *nameArray = [dataStr componentsSeparatedByString:@"@"];
        if ([nameArray count] > 1) {
            [str appendString:[nameArray objectAtIndex:1]];
            if ([dataArray indexOfObject:dataStr] < [dataArray count] - 1) {
                [str appendString:@","];
            }
        }
        if([nameArray count] ==1){
            [str appendString:[nameArray objectAtIndex:0]];
            if ([dataArray indexOfObject:dataStr] < [dataArray count] - 1) {
                [str appendString:@","];
            }
        }
    }
    
    if ([str length] > 0) {
        self.dataArray = dataArray;
    } else {
        self.dataArray = nil;
    }
    
    self.infoLabel.text = str;
}

- (NSString *)getReturnValueLuaScrip:(NSString *)luaScript
{
    return [WSLuaExecutorManager getSubLuaScriptWith:luaScript ByFuntionName:EXCUSE_RETURN_VALUE_LUA_FUNTION];
}

#pragma mark - WSReportFormControllerDelegate

- (void)didGetDataFromReportForm:(NSString *)data
{
    [self refreshDisplayDataAndRunLuaScriptWithData:data];
}

- (void)realTimeRefreshAcvtDatasWithGetDataFromReportForm:(NSString *)data
{
    id dic = [data mutableObjectFromJSONString];
    
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *objIdStr = [dic objectForKey:@"objId"];
        NSString *paramStr = [dic objectForKey:@"param"];
        NSString *redisValueStr = [dic objectForKey:@"redisValue"];
        NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:objIdStr, @"objId", paramStr, @"extras", nil];
        
        if ([self.viewController isKindOfClass:[WSAcvtViewController class]])
        {
            if ([self.viewController respondsToSelector:@selector(doRealtimeRefreshAcvtDatasWithParamDic:)])
            {
                [(WSAcvtViewController *)self.viewController doRealtimeRefreshAcvtDatasWithParamDic:paramDic];
            }
        }
        
        [self refreshDisplayDataAndRunLuaScriptWithData:[NSString stringWithFormat:@"@%@", redisValueStr]];

    }

}

- (void)refreshDisplayDataAndRunLuaScriptWithData:(NSString *)data{
    
    [self loadStringData:data];
    
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        
        NSString *returnValueScript = [self getReturnValueLuaScrip:[xbuildInfo getLuaScript]];
        self.resultCheck = [self getDisplayValuePresentation];
        
        if (returnValueScript) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:returnValueScript widget:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo widget:self];
            }
        }
    }
}
#pragma mark - # 显示回显逻辑，区分点击选中回显，如果不区分会显示网址
- (void)showOriginalValueStringData:(NSString *)data {
    
    NSArray *dataArray = nil;
    NSArray *selectedIdArray =  [data componentsSeparatedByString:@"@"];
    if (selectedIdArray.count > 1) {
        self.selectedIdStr = [selectedIdArray firstObject];
    }
    if ([data length] > 0) {
        dataArray = [data componentsSeparatedByString:@","];
    }
    
    NSMutableString *str = [NSMutableString string];
    for (NSString *dataStr in dataArray) {
        NSArray *nameArray = [dataStr componentsSeparatedByString:@"@"];
        if ([nameArray count] > 1) {
            [str appendString:[nameArray objectAtIndex:1]];
            if ([dataArray indexOfObject:dataStr] < [dataArray count] - 1) {
                [str appendString:@","];
            }
        }if([nameArray count] == 1){
            NSString * value = nameArray.firstObject;
            if(![value containsString:@"http"]){
                [str appendString:value];
            }
        }
    }
    if ([str length] > 0) {
        self.dataArray = dataArray;
    } else {
        self.dataArray = nil;
    }
    self.infoLabel.text = str;
}
#pragma mark - # 添加单机手势
- (void)addTapGestureRecognizer{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:tap];
}
#pragma mark - # *****************UI*************************
#pragma mark - # 添加 info label
- (void)addUrlInfoLab{
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.right + 10, self.titleLabel.top, self.arrowIcon.left - (self.titleLabel.right + 20), self.titleLabel.height)];
    infoLabel.textColor = PanelTextFieldColorReadonly;
    infoLabel.font = PanelTextFieldFont;
    infoLabel.textAlignment = NSTextAlignmentRight;
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    self.infoLabel = infoLabel;
    [self addSubview:infoLabel];
}
#pragma mark - # 添加箭头
- (void)addArrowIconImage{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    
    imageView.frame = CGRectMake(self.width - imageView.size.width - MAIN_CELL_PADDING, (self.height - imageView.size.height)/2, imageView.size.width, imageView.size.height);
   
    if ([[self getReadonly] boolValue]) {
        imageView.hidden = YES;
    } else {
        imageView.hidden = NO;
    }
    [self addSubview:imageView];
    
    self.arrowIcon = imageView;
}


@end
