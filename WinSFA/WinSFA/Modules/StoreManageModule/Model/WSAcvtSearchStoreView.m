//
//  WSAcvtSearchStoreView.m
//  WinSFA
//
//  Created by heju on 2016/12/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtSearchStoreView.h"

#import "WSAcvtScrollView.h"

#import "WSAcvtView.h"

#import "WSWidget.h"

#import "I_W_BuildInfo.h"

#import "WSRequestHelper.h"

#import "WSBaseAcvtdisDBService.h"

#import "WSDataSourceManager.h"

#import "WSAcvtModel.h"

#import "WSDVDropListPanel.h"

#import "WSBaseStoreDBService.h"

#import "WSStoreDataService.h"

#import "LEOAssistiveTouch.h"

#import "TZImagePickerController.h"

#import "WSSellFloatWindowManager.h"

#define K_LEFT_MARGIN 60

#define K_BOTTOM_HEGINT 46

#define K_BUTTON_HEIGHT 32

#define K_BUTTON_WIDTH 90

#define K_TOP_VIEW_HEIGHT 64

#define K_BUTTON_SPACE 30

#define WSASSV_BASE_TAG 1024

#define WSASSV_AnimationDuration 0.3f

#define WSASSV_REQUST_STORE_ACVT_DIS_NOTIFY @"wsassv_request_store_acvt_dis_notify"


@interface WSAcvtSearchStoreView ()

@property (nonatomic,strong)WSFuncsBean *currentFuncs;


@property (nonatomic,strong)WSAcvtView *acvtview;

@property (nonatomic,strong)WSAcvtScrollView *acvtScrollView;

@property (nonatomic,strong)NSString *filterCondition;

@end

@implementation WSAcvtSearchStoreView



- (id)initWithFrame:(CGRect)frame current:(WSFuncsBean *)currentFuncs acvtBean:(WSAcvtBean *)acvtBean {
    
    self = [super initWithFrame:frame];
    if (self) {
        _currentFuncs = currentFuncs;
        _acvtBean = acvtBean;
        
        WSAcvtModel *model = [[WSAcvtModel alloc] init];
        model.currentFuncs = currentFuncs;
        model.currentAcvtBean = acvtBean;
        [WSDataSourceManager sharedInstance].currentActiveModel = model;
        model.luaExecuteParams = @"false"; //YIHAIKERRY-4017  设置脚本的setvalue的参数 ,false走脚本，true不走脚本

        
        [self buildDisplayContent];
    }
    return self;
}

- (void)buildDisplayContent {
   
    self.blockView = [[UIView alloc] initWithFrame:self.bounds];
    self.blockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.blockView.alpha = 0.01;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockViewTapped:)];
    [self.blockView addGestureRecognizer:tap];
    [self addSubview:self.blockView];
    
    UIView *rightBgView = [[UIView alloc] initWithFrame:CGRectMake(self.width, 0, self.width - K_LEFT_MARGIN, self.height)];
    rightBgView.backgroundColor = [UIColor blackColor];
    [self addSubview:rightBgView];
    self.rightView = rightBgView;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rightBgView.frame), NavigationBarHeight)];
    topView.backgroundColor = MAIN_TINT_COLOR;
    [self.rightView addSubview:topView];
    
    
    CGFloat topPadding = StatusBarHeight;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topPadding, topView.width, topView.height - topPadding)];
    titleLabel.text = self.acvtBean.acvtName;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    /*
     返回按钮
     */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, StatusBarHeight+10, 24, 24);
    backButton.tag = WSASSV_BASE_TAG + 0;
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    if (![self.currentFuncs.opt.isRefresh isEqualToString:@"0"]) {
        // 刷新按钮
        UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshButton.frame = CGRectMake(rightBgView.width - 30 - 10, backButton.frame.origin.y, 24, 24);
        refreshButton.tag = WSASSV_BASE_TAG + 3;
        [refreshButton setImage:[UIImage imageNamed:@"refurbish_icon"] forState:UIControlStateNormal];
        [refreshButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:refreshButton];
    }
    
    CGFloat bottom_height = [TZCommonTools tz_isIPhoneX]?([self getBottmHeight]+K_BOTTOM_HEGINT):K_BOTTOM_HEGINT;

    _acvtScrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, CGRectGetWidth(rightBgView.frame), self.height - K_TOP_VIEW_HEIGHT - K_BOTTOM_HEGINT) andAcvtBean:self.acvtBean];
    _acvtScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _acvtScrollView.backgroundColor = [UIColor whiteColor];
    self.acvtview = _acvtScrollView.acvtView;
    [self.acvtview buildDisplayContent];
    [self.rightView addSubview:self.acvtScrollView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height- bottom_height, CGRectGetWidth(rightBgView.frame), K_BOTTOM_HEGINT)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottomView.backgroundColor = RGBCOLOR(241, 241, 241);
    [self.rightView addSubview:bottomView];
    
//    MSTD-6697 xuhan 2017 1031
    float gapWidth = 15.0f;
    CGFloat button_w = (self.width - gapWidth*3 - K_LEFT_MARGIN)/2;
    CGFloat button_y = 7.0f;
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(gapWidth, button_y, button_w, K_BUTTON_HEIGHT);
    resetButton.tag = WSASSV_BASE_TAG + 1;
    [resetButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [resetButton setTitle:NSLocalizedString(@"w_reset", nil) forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [resetButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    resetButton.backgroundColor = RGBCOLOR(248, 248, 248);
    resetButton.layer.borderWidth = 1.0;
    resetButton.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    resetButton.layer.cornerRadius = 5.0;
    [bottomView addSubview:resetButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(gapWidth*2 + button_w, button_y, button_w, K_BUTTON_HEIGHT);
    confirmButton.tag = WSASSV_BASE_TAG + 2;
    [confirmButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setTitle:NSLocalizedString(@"confirm_label", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:MAIN_TINT_COLOR];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    confirmButton.layer.cornerRadius = 5.0;
    [bottomView addSubview:confirmButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(K_LEFT_MARGIN, self.height - bottom_height - 1, self.width, 1)];
    line.backgroundColor = RGBCOLOR(232, 232, 232);
    [self addSubview:line];
}

- (void)showOnView:(UIView *)superView
{
   
    
    CGRect endFrame = self.rightView.frame;
    self.rightView.frame = CGRectMake(endFrame.origin.x + self.width, endFrame.origin.y, self.width, self.height);
    
    [superView addSubview:self];
    
    [UIView animateWithDuration:WSASSV_AnimationDuration animations:^{
        self.rightView.frame = endFrame;
        self.blockView.alpha = 1.0;
    }];
}

- (void)blockViewTapped:(id) sender
{
    if ([_delegate respondsToSelector:@selector(acvtSearchStoreView:isShow:)]) {
        [_delegate acvtSearchStoreView:self isShow:NO];
    }
}


- (void)buttonClick:(UIButton *)button {
    NSInteger btnTag= button.tag;
    switch (btnTag - WSASSV_BASE_TAG) {
        case 0:
        {
            self.blockView.alpha = 0.01;
            self.blockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            if ([_delegate respondsToSelector:@selector(acvtSearchStoreView:isShow:)]) {
                [_delegate acvtSearchStoreView:self isShow:NO];
            }
        }
            break;
        case 1:
        {
            [self celearData];
        }
            break;
        case 2:
        {
            [self startLocation];
            
        }
            break;

        case 3:
        {
            [self reFreshData];

        }
            break;

        default:
            break;
    }
}

-(void)celearData{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    model.luaExecuteParams = @"true"; //YIHAIKERRY-4017  设置脚本的setvalue的参数 ,false走脚本，true不走脚本
    [self.acvtview celearAcvtData];

}

-(void)startLocation{

    // 是否包含距离问题 如果没有距离问题，则不需要定位和重新更新门店表中的距离
    BOOL isNeedUpdata = NO;
    for (WSWidget *widget in self.acvtview.widgetArray) {
       
        if ([[widget.xbuildInfo getISRequire] isEqualToString:@"1"] && ![widget getResultDirectly]) {
            NSString *tip = NSLocalizedString(@"not_filled", nil);
            NSString *toastStr = [NSString stringWithFormat:tip, [widget.xbuildInfo getQuestName]];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:toastStr tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_SB]) {
            NSString *result = (NSString *)[widget getResultDirectly];
            if ([result floatValue] > 0) {
                isNeedUpdata = YES;
            };
            break;
        }
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"查询中" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];

    // 实时定位  默认为开启GPS，如果配置为Y开启
    if ((!self.currentFuncs.opt.isGps || [self.currentFuncs.opt.isGps isEqualToString:@"Y"]) && isNeedUpdata) {
        __weak typeof(self)weakSelf  = self;
        LogInfo(@"问卷搜索门店开始定位");
        [[WSStoreDataService shareInstance] checkAndUpdateStoreDistanceWithCurrentFuncs:self.currentFuncs andSubEmpId:nil andObjectId:nil withBlock:^(WSLocationDescribe * locationDescribe,BOOL isNeedRefresh) {
            [weakSelf excluteQuery];
        }];
        
    }else{
        
        [self excluteQuery];

    }

}

-(void)excluteQuery{
    LogInfo(@"执行问卷搜索门店");
    NSMutableDictionary *qstValuesDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *rangeValuesDic = [NSMutableDictionary dictionary];
    CGFloat distance = 0;
    NSMutableString *searchStoreType = nil;
    for (WSWidget *widget in self.acvtview.widgetArray) {
        NSString *result = (NSString *)[widget getSearchCondition];
        NSString *acvtQstId = [widget.xbuildInfo getAcvtQstId];
        if ([result length] > 0 && ![[widget.xbuildInfo getIsHidden] isEqualToString:@"1"]) {
            NSRange range = [result rangeOfString:QST_SEARCH_DISTANCE];
            if (range.location == NSNotFound) {
                if ([result rangeOfString:QST_SEARCH_RANGE_SEPARATOR].location == NSNotFound) {
                    qstValuesDic[acvtQstId] = result;
                } else {
                    rangeValuesDic[acvtQstId] = result;
                }
            } else {
                NSString *distanceStr = [result substringFromIndex:range.length];
                distance = [distanceStr floatValue];
            }
        }
        //        MN-3104
        //        【后台】城市经理手机端四级拜访筛选条件和搜索门店问题，见描述。
        NSString *storeType = (NSString *)[widget getSearchStoreTypeWithCondition:result];
        if (storeType.length > 0 && searchStoreType.length > 0) {
            [searchStoreType stringByAppendingFormat:@",%@",storeType];
        } else {
            searchStoreType = [NSMutableString stringWithString:storeType];
        }

    }
    
    self.blockView.alpha = 0.01;
    self.blockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    if ([_delegate respondsToSelector:@selector(acvtSearchStoreView:isShow:)]) {
        [_delegate acvtSearchStoreView:self isShow:NO];
    }
    if ([_delegate respondsToSelector:@selector(acvtSearchStoreView:searchStoreWithCondition:rangeConditions:distance: searchStoreType:)]) {
        [_delegate acvtSearchStoreView:self searchStoreWithCondition:qstValuesDic  rangeConditions:[rangeValuesDic copy] distance:distance searchStoreType:searchStoreType];
    }

}
- (void)requestStoreAcvtdisData {
    
    /*如果能查到此调查问卷相关的回显值 则不进行实时请求*/
    WSBaseAcvtdisDBService *baseAcvtdisDBService = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *storeAcvtdiss = [baseAcvtdisDBService queryAcvtQstDatasByAcvtId:self.acvtBean.acvtId];
    if ([storeAcvtdiss count] > 0) {
        return;
    }
    
    if ([self.currentFuncs.opt.acvtSearch length] == 0) {
        LogInfo(@"self.currentFuncs.opt.acvtSearch is nil");
        return;
    }
    
    [self reFreshData];
}

-(void)reFreshData{
    NSString *AccessInfortmpString = NSLocalizedString(@"refresh_prompt",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInfortmpString  tips:nil tapTarget:self action:nil];
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] ;
    NSString *compress = @"1";
    
    NSString *objId = self.currentFuncs.opt.acvtSearch;
    NSMutableDictionary *searchDic = [NSMutableDictionary dictionary];
    [searchDic setObject:empId forKey:APPDATA_EMPIDBIGI];
    [searchDic setObject:compress forKey:@"compress"];
    [searchDic setObject:objId forKey:@"objId"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestStoreAcvtdisFinish:) name:WSASSV_REQUST_STORE_ACVT_DIS_NOTIFY object:nil];
    [[WSRequestHelper shareInstance] postRequestData:searchDic notifyName:WSASSV_REQUST_STORE_ACVT_DIS_NOTIFY];
}

// 服务器搜索返回数据
- (void)requestStoreAcvtdisFinish:(id)sender {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WSASSV_REQUST_STORE_ACVT_DIS_NOTIFY object:nil];
    // 解析数据
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    NSString *objId = self.currentFuncs.opt.acvtSearch;
    NSArray *storeAcvtdiss = [dic objectForKey:objId];
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    
    if ([flag isEqualToString:@"0"]) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        return;
    }
    
    NSString *alterString = nil;
    if (storeAcvtdiss && [storeAcvtdiss count] > 0) {
    
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        [service replaceToTableWithDicts:storeAcvtdiss FromNode:objId hasNewData:YES storeID:nil isRemoteSearch:NO];
        
        //将回显acvt_qst_answer 转为opt_value 的方法 processServerAcvtDisValue 统一处理
//        WSBaseAcvtdisDBService *processServer = [[WSBaseAcvtdisDBService alloc] init];
//        if (![processServer processServerAcvtDisValue]) {
//            LogError(@"processServerAcvtDisValue 失败");
//        }
        alterString = NSLocalizedString(@"refresh_success",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        WSAcvtModel *model = [[WSAcvtModel alloc] init];
        model.currentFuncs = _currentFuncs;
        model.currentAcvtBean = _acvtBean;
        [WSDataSourceManager sharedInstance].currentActiveModel = model;
        
        [self refreshStoreAcvtDataSource];
        
    } else {
        // 提示没有搜出来结果
        //        没有结果的话不需要提示  有结果就是有回显。没结果就是没有不需要提示 董宏 YIHAIKERRY-2339
//        alterString = NSLocalizedString(@"no_result", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
// MSTD-7748 董宏
- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        if ([_delegate isKindOfClass:[WCBaseViewController class]] )
        {
            WCBaseViewController *base = (WCBaseViewController*)_delegate;
            [base showOnlineConsultationBtn];
        }
    }
    else
    {
        [LEOAssistiveTouch hide];
        [WSSellFloatWindowManager hideSellFloatWindow];

    }
}
#pragma mark -刷新问卷的数据源
- (void)refreshStoreAcvtDataSource
{
    // YIHAIKERRY-3889  currentActiveModel在其他页面可能会用到，然后设为nil，所以在此处需要重新赋值
    // SFA 益海嘉里-传统渠道【IOS】门店列表高级搜索查询后，返回门店列表，进入门店查看促销活动，返回门店列表进入高级筛选，筛选显示的门店个数被清空
    WSAcvtModel *model = [[WSAcvtModel alloc] init];
    model.currentFuncs = self.currentFuncs;
    model.currentAcvtBean = self.acvtBean;
    [WSDataSourceManager sharedInstance].currentActiveModel = model;
    
    for (WSWidget *widget in self.acvtview.widgetArray) {
        if ([widget isKindOfClass:[WSDVDropListPanel class]]) {
            [(WSDVDropListPanel *)widget refreshDataSource];
        }
    }
}

- (CGFloat)getBottmHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        return mainWindow.safeAreaInsets.bottom;
    }
    return 0;
}

@end
