//
//  WorkFlowViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSWorkFlowViewController.h"
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSEnterStoreViewController.h"
#import "WSLeaveStoreViewController.h"
#import "WSAcvtListViewController.h"
#import "BaseViewController.h"
#import "WSWorkFlowCollectionViewController.h"
#import "WSStoreKPIViewController.h"
#import "WSInoutStoreTable.h"
#import "WSFuncsBean_opt.h"
#import "UIDevice+Addtional.h"
#import "WSPlistHelper.h"
#import "WSNavigationBar.h"
#import "WSLocationManager.h"
#import "WSBaseAcvtDBService.h"
#import "WSStoreInfoViewController.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSVisitedMenuArray.h"
#import "WSEnterStoreAcvtViewController.h"
#import "WSLeaveStoreAcvtViewController.h"
#import "WSNextStepViewController.h"
#import "WSStoreInfoMapViewController.h"
#import "WSEnvrionment.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "PureLayout.h"
#import "VisitDoctorViewController.h"
#import "NSString+ServerUrl.h"
#import "WSImageBrowserView.h"
#import "WSRequestHelper.h"
#import "WSImagePathTable.h"
#import "NSString+Additions.h"
#import "NSString+Valid.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSWorkFlowNoticeView.h"
#import "WSApplicationWindowsRelationManager.h"
#import "UINavigationController+Additions.h"
#import "WSScrollLabelView.h"
#import "WSAcvtScrollView.h"
#import "WSAllStoresMapViewController.h"
#import "WSUpdateStoreIconViewController.h"
#import "WSShowQstViewForStoreListCell.h"
#import "WSStatisticsManager.h"
#import "WSEnvrionment.h"
#import "WSReportFormController.h"
#import "WinJSBridgeViewController.h"
#import "WSTLAlertManager.h"
#import "LEOMemoTouch.h"

#define k_TableViewContentWidth     ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))
#define kMaxCallStoreNumAlertTag    1888
#define kTemplateButtonTag          5888
#define kHeaderImageViewLeftSpace   15
#define kHeaderImageViewCodeSpace   10
#define kHeaderImageViewWH          ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 75 : 88)
#define kHeaderIconPadding          4
#define kHeaderViewMinHeight        (isInThinMode ? (INTERFACE_IS_PHONE ? 90 : 147) : kHeaderImageViewWH + 30)
#define STORE_NAV_BUTTON_WIDHT      70
#define STORE_NAV_BUTTON_MIN_WIDTH  36
#define STORE_NAV_BUTTON_HEGIHT     18
#define NAV_BUTTON_RIGTHT_SPACE     20
#define NAV_BUTTON_TOP_SPACE        22
#define kImageView_And_Detail_Space 4
#define kTopTipKey                  @"TopTip"
#define kDetaiTextFont              FONT_SIZE_PINGFANG_MEDIUM(13)
#define WORKFLOW_HEADERVIEW_COLOR   ([UIColor colorForKey:@"WorkFlowHeaderViewTitle"] ? : [UIColor colorWithRed:33.0f/255 green:33.0f/255 blue:33.0f/255 alpha:1.0f] )
#define WORKFLOW_HEADERVIEW_FONT    [UIFont fontForKey:@"WorkFlowHeaderViewTitle"] ? : FONT_SIZE_PINGFANG_MEDIUM(15)

static NSString * const tskf_storeInfoName = @"门店信息卡";

@interface WSWorkFlowViewController()<UIActionSheetDelegate> {
    
    WSFuncsBean *showTemplateFuncsBean;
    BOOL isInThinMode;
}

@property (nonatomic, strong) NSMutableDictionary *iCheckInfo;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) UIView * headView;
@property (nonatomic, strong) NSMutableArray *linktelArray;
@property (nonatomic, weak) WSWorkFlowCollectionViewController *collectionController;
@property (nonatomic, strong) UIImageView *storeImageView;
@property (nonatomic, strong) UIButton * storeInfoBtn;

@end
//========================================================================================================================================================

@implementation WSWorkFlowViewController {
    
    NSMutableDictionary *requireTable_;
}

-(NSMutableArray *)linktelArray {
    
    if (!_linktelArray) {
        _linktelArray = [[NSMutableArray alloc]init];
    }
    
    return _linktelArray;
}

- (void)initFuncsBeanData {
    
    [super initFuncsBeanData];
    
    NSMutableArray *mutableArray = [self.funcBeanArray mutableCopy];
    for (WSFuncsBean *funcsBean in self.funcBeanArray) {
        
        if ([funcsBean.fv isEqualToString:UNILEVERORDERTEMPLATE_FV]) {
            showTemplateFuncsBean = funcsBean;
            [mutableArray removeObject:funcsBean];
            break;
        }
    }

    self.funcBeanArray = [mutableArray copy];
}

- (id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore {
    
    if (self = [self initWithFuncs:funcs Store:store]) {
        self.acvtNewStore = acvtNewStore;
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore {
    
    return  [self initWithFuncs:funcs Store:store subEmpStore:subEmpStore unredo:funcs.unredo];
}

- (id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore unredo:(NSString *)unredo {
    
    if (self = [self initWithFuncs:funcs Store:store unredo:unredo]) {
        self.subempStore = subEmpStore;
        return self;
    }
    return self;
}


- (id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store {
    
    return [self initWithFuncs:funcs Store:store unredo:funcs.unredo];
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store unredo:(NSString *)unredo {
    
    if (funcs == nil) {
        return nil;
    }
    
    self = [super init];
    if (self != nil) {
        
        self.currentFuncs = funcs;
        self.currentStore = store;

        if (unredo) {
           self.unredo = unredo;
        }
        requireTable_ = [[NSMutableDictionary alloc] init];
        
        return self;
    }
    return nil;
}

- (void)initializationBackItemAction {
    
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:@selector(backAction) target:self withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }
    else {
        [self backItemAction:@selector(backAction) target:self];
    }
}

- (void)setupViews {
    
    UIView *headerView = [self getTableHeaderView];
    [self.view addSubview:headerView];
    
    CGFloat paddingY = CGRectGetMaxY(headerView.frame);
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    if (self.currentFuncs.readonly && self.currentFuncs.iParentFuncsBean.funcsArray.count == 1) {

        WSAcvtBean * acvtBean = [baseAcvtDBService queryAcvtWithAcvtCode:self.currentFuncs.filter];
        WSAcvtViewController *acvtVC = [[WSAcvtViewController alloc] initWithAcvt:acvtBean Funcs:self.currentFuncs Store:self.currentStore];
        [acvtVC.view setFrame:CGRectMake(self.view.origin.x, paddingY, self.view.width, self.view.height - paddingY)];
        acvtVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addChildViewController:acvtVC];
        [self.view addSubview:acvtVC.view];
        return;
    }
    
    WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithStoreId:self.currentStore.Id withAcvtTyp:STORE_KPI_ACVT_CODE];
    
    if (acvtBean) {
        
        WSStoreKPIViewController *kpiController = [[WSStoreKPIViewController alloc] initWithFuncs:self.currentFuncs acvtBean:acvtBean store:self.currentStore];
        [self addChildViewController:kpiController];
        
        CGRect viewRect = kpiController.view.frame;
        [kpiController.view setFrame:CGRectMake(0, paddingY, headerView.width, viewRect.size.height)];
        kpiController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:kpiController.view];
        paddingY += viewRect.size.height;
    }
    
    WSWorkFlowCollectionViewController *collectionController = [[WSWorkFlowCollectionViewController alloc] initWithFuncs:self.currentFuncs Store:self.currentStore subEmpStore:self.subempStore];
    [self addChildViewController:collectionController];
    [collectionController.view setFrame:CGRectMake(0, paddingY, self.view.width, self.view.height - paddingY)];
    collectionController.moduleFC = self.moduleFC;
    collectionController.currentVisitAction = self.currentVisitAction;
    collectionController.input_reflect_code = self.input_reflect_code;
    collectionController.acvtNewStore = self.acvtNewStore;
    collectionController.wsSplitController = self.wsSplitController;
    collectionController.allDataArray = self.funcBeanArray;
    collectionController.title = self.title;
    collectionController.realParentFuncsCode = self.realParentFuncsCode;
    [self.view addSubview:collectionController.view];
    self.collectionController = collectionController;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    [self addNotificationObserver];

    [self initFuncsBeanData];
    
    isInThinMode = NO;
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    if ((INTERFACE_IS_PAD && self.currentFuncs.wfcol > 0 && self.currentFuncs.wfcol < 300) || [isUsePhotos isEqualToString:@"0"]) {
        isInThinMode = YES;
    }
    
    [self initializationBackItemAction];
    [self setupViews];
    [self setupNavScrollTitle];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self getTopTip];
    });
    
    if ([self.currentStore.actionState isEqualToString:ActionWorking]) {
        [self p_addOrangeAndDisReqTips];
    }
}

- (void)storeInfoHasArrived:(id)sender {
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];

    self.navigationController.navigationBar.userInteractionEnabled=YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_STOREINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error) {
        
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else {
        
        NSDictionary *responsedic = [info objectFromJSONString];
        NSString *objIdString = STOREINFO_UPDATE;
        NSArray *sInfo = [responsedic objectForKey:objIdString];
        NSDictionary *dic = [sInfo objectAtIndex:0];
        NSArray * storeInfo = [dic objectForKey:@"storeInfo"];
        
        for (NSDictionary * dict in storeInfo) {
            
            NSString * phoneNumber = [dict objectForKey:@"col2"];
            if ([phoneNumber isPhoneNumber]) {
                
                NSString * nameAndPhoneNumber = [NSString stringWithFormat:@"%@:%@",dict[@"col1"],phoneNumber];
                [self.linktelArray addObject:nameAndPhoneNumber];
            }
        }
    }
}

- (UIView *)getTableHeaderView {
    
    CGFloat autoHeight = 0.0;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderViewMinHeight)];
    UITapGestureRecognizer * showStoreInfoGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showStoreInfoViewController)];
    [headerView addGestureRecognizer:showStoreInfoGesture];
    headerView.backgroundColor = [UIColor colorForKey:@"WorkFlowTitleViewBackgroudColor"];
    
    UIFont *storeNameFont = WORKFLOW_HEADERVIEW_FONT;
    BOOL isCode = [self.currentFuncs.opt.isCode isEqualToString:@"0"];
    BOOL isPhoneMode;
    NSString *menuType = self.currentFuncs.menuType;
    if (menuType && menuType.length > 0) {
        
        isPhoneMode = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeInfoHasArrived:) name:NOTIFY_STOREINFO object:nil];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_prompt", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
        [[WSRequestHelper shareInstance] appGetStoreInfobyStoreId:self.currentStore.Id notifyName:NOTIFY_STOREINFO styp:self.currentStore.styp];
    }
    else {
        isPhoneMode = NO;
    }
    
    UIImageView *storeImageView;
    if (!isPhoneMode) {
        
        if (!isInThinMode) {
            
            storeImageView = [UIImageView newAutoLayoutView];
            self.storeImageView = storeImageView;
            storeImageView.tag = 10002;
            storeImageView.contentMode = UIViewContentModeScaleAspectFill;
            storeImageView.clipsToBounds = YES;
            
            NSString *detectFc = self.moduleFC;
            if (self.input_reflect_code && [self.input_reflect_code length]>0) {
                
                if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                    detectFc = self.input_reflect_code;
                    
                }
            }
            
            NSString *local_image = [[WSInoutStoreTable sharedTable]getStoreLocalImageWithStore:self.currentStore andOtherParam:nil andParamType:EParameterType_NULL];
            if ([self.currentStore.storeImg length] > 0){
                
                if ([self.currentStore.storeImg rangeOfString:@"."].location != NSNotFound) {
                    [[WSRequestHelper shareInstance]  downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.currentStore.storeImg] imageView:storeImageView
                                                          placeholderImage:[UIImage imageNamed:@"shop_default"]];
                }
                else {
                    
                    NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.currentStore.storeImg];
                    if (imagePathArray.count) {
                        
                        WSImagePathObject * object = [imagePathArray lastObject];
                        if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                            
                            NSString * url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                            [[WSRequestHelper shareInstance]  downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:[WSHttpURLHelper getImageCompleteURL:url]] imageView:storeImageView placeholderImage:[UIImage imageNamed:@"shop_default"]];
                        }
                        else {
                            
                            UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
                            if (image) {
                                storeImageView.image = image;
                            }
                            else {
                                storeImageView.image = [UIImage imageNamed:@"shop_default"];
                            }
                        }
                    }
                }
            }
            else if (local_image && local_image.length >0 && ![local_image isEqualToString:@"null"]) {
                
                NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
                if (![isUsePhotos isEqualToString:@"2"]) {
                    UIImage *localImage =[[SDImageCache sharedImageCache]imageFromKey:local_image fromDisk:YES];
                    storeImageView.image = localImage;
                }
                else {
                    storeImageView.image = [UIImage imageNamed:@"shop_default"];
                }
            }
            else {
                storeImageView.image = [UIImage imageNamed:@"shop_default"];
            }
            
            storeImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer * showStoreImageView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showStoreImageView:)];
            [storeImageView addGestureRecognizer:showStoreImageView];
            [headerView addSubview:storeImageView];
            
            [storeImageView autoSetDimension:ALDimensionWidth toSize:kHeaderImageViewWH];
            [storeImageView autoSetDimension:ALDimensionHeight toSize:kHeaderImageViewWH];
            [storeImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHeaderImageViewLeftSpace];
            [storeImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kHeaderImageViewLeftSpace];
        }
    }
    
    UIFont *naviButtonFont = kDetaiTextFont;
    BOOL isShowNaviButton = YES;
    NSString *naviDis = self.currentFuncs.opt.naviDis;
    NSInteger navidisNum = [naviDis integerValue];

    if (naviDis && naviDis.length > 0) {
        
        NSInteger caculateNum = navidisNum >> 1;
        if (navidisNum == 0 || (caculateNum % 2) == 1 ) {
            isShowNaviButton = NO;
        }
        else {
            navidisNum = 1;
        }
    }

    BOOL isHaveNavButtonImage =  YES;
    if (navidisNum << 3 == 1) {
        isHaveNavButtonImage = NO;
    }
    
    CGFloat storeNavWidth;
    if ([self.currentStore.distance length] > 0 && isShowNaviButton) {
        storeNavWidth = [self.currentStore.distance ws_sizeWithFont:naviButtonFont constrainedToWidth:CGFLOAT_MAX].width ;
    }
    else {
        storeNavWidth = 0;
    }
    
    CGFloat nameWidth = 0;
    if (isInThinMode) {
        nameWidth = (CGFloat)self.currentFuncs.wfcol;
    }
    else {
        
        CGFloat totalWidth = self.view.width;
        if (INTERFACE_IS_PAD) {
            totalWidth = SPLITVIEW_LEFT_DEFAULT_WIDTH;
            if (self.currentFuncs.wfcol > 0) {
                totalWidth = (CGFloat)self.currentFuncs.wfcol;
            }
        }
        nameWidth = totalWidth - kHeaderImageViewWH - storeNavWidth - kHeaderImageViewLeftSpace - kHeaderImageViewLeftSpace/2 - kView_Height;
    }

    CGSize size = [self.currentStore.name ws_sizeWithFont:storeNameFont constrainedToWidth:nameWidth lineBreakMode:NSLineBreakByCharWrapping];
    autoHeight += size.height;

    UILabel *storeNameLabel = [UILabel newAutoLayoutView];
    storeNameLabel.text = self.currentStore.name;
    storeNameLabel.numberOfLines = 0;
    storeNameLabel.font = storeNameFont;
    storeNameLabel.backgroundColor = [UIColor clearColor];
    storeNameLabel.textColor = [UIColor blackColor];
    storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [headerView addSubview:storeNameLabel];
    UIColor *titleColor = WORKFLOW_HEADERVIEW_COLOR;
    if (titleColor) {
        storeNameLabel.textColor = titleColor;
    }
    else {
        titleColor = [UIColor colorWithHexString:@"#6b6b6b"];
    }
    
    if (!self.currentStore.distance || [self.currentStore.distance length] == 0) {

        if (isInThinMode) {
            [storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView withOffset:-30];
        }
        else {
            [storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView withOffset:-(kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2 + 5)];
        }
    }
    else {
        [storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView withOffset:-(kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2 + 5)];
    }
    
    if (isInThinMode || isPhoneMode) {
        [storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
    }
    else {
        [storeNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewLeftSpace];
    }
    
    [storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    autoHeight += 20;
   
    UIButton *navButton ;
    if ([self.currentStore.distance length] > 0) {

        navButton = [[UIButton alloc]init];
        navButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

        if (isHaveNavButtonImage) {
            
            navButton.frame = CGRectMake(0, 0, 24, 24);
            [navButton setImage:[UIImage imageNamed:@"detailMapNav"] forState:UIControlStateNormal];
            [navButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [navButton setTitle:self.currentStore.distance forState:UIControlStateNormal];
            navButton.frame = CGRectMake(0, 0, storeNavWidth, STORE_NAV_BUTTON_HEGIHT);
            [navButton setTitleColor:titleColor forState:UIControlStateNormal];
            [navButton.titleLabel setFont:naviButtonFont];
        }

        UIBarButtonItem * navItem = [[UIBarButtonItem alloc]initWithCustomView:navButton];
        self.navigationItem.rightBarButtonItem = navItem;
        if (!isShowNaviButton) {
            navButton.hidden = YES;
        }
    }

    if (INTERFACE_IS_PHONE) {
        
        storeNameLabel.hidden = YES;
    }
    
    UIFont *storeIDFont = kDetaiTextFont;
    CGSize storeIDSize = [self.currentStore.code ws_sizeWithFont:storeIDFont constrainedToWidth:CGFLOAT_MAX];
    if (!isCode) {
        autoHeight += storeIDSize.height;
    }

    UILabel *storeIDLabel = [UILabel newAutoLayoutView];
    storeIDLabel.text = self.currentStore.code;
    storeIDLabel.font = storeIDFont;
    storeIDLabel.backgroundColor = [UIColor clearColor];
    storeIDLabel.textColor = titleColor;
    [headerView addSubview:storeIDLabel];
    if (!INTERFACE_IS_PHONE) {
        [storeIDLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
    }
    
    CGFloat storeIDLabelTopMagin = 0;
    if (isInThinMode || isPhoneMode) {
        
        if (INTERFACE_IS_PHONE) {
            [storeIDLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
            storeIDLabelTopMagin = 10;
        }
        else {
            [storeIDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:18];
            storeIDLabelTopMagin = 18;
        }
    }
    else {
        
        if (INTERFACE_IS_PHONE) {
            [storeIDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeImageView withOffset:10];
                storeIDLabelTopMagin = 10;
        
        }else {
            [storeIDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeNameLabel withOffset:5];
            storeIDLabelTopMagin = 5;
        }
    }
    
    if (!isCode) {
        autoHeight += storeIDLabelTopMagin;
    }
    
    if (INTERFACE_IS_PHONE) {
        
        UIImageView *codeImageView = [UIImageView newAutoLayoutView];
        codeImageView.image = [UIImage imageNamed:@"detailCode"];
        [headerView addSubview:codeImageView];
        
        if (isInThinMode || isPhoneMode) {
            [codeImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
        }
        else {
            [codeImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
        }
        
        [storeIDLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:codeImageView withOffset:kHeaderIconPadding];

        CGFloat codeImageViewWidth = kView_Height - 3;
        [codeImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeIDLabel withOffset:kImageView_And_Detail_Space];
        [codeImageView autoSetDimension:ALDimensionWidth toSize:codeImageViewWidth];
        [codeImageView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];

        UIView *lastView = storeIDLabel;
    
        CGFloat labelPadding = kView_Height/4;
        NSLayoutConstraint * storeAddrLabelTopContraint;
        NSLayoutConstraint * storeAddrImageTopContraint;
        NSLayoutConstraint * isPlanImgViewLeftContraint;
        NSLayoutConstraint * imgScrollViewLeftContraint;
        UILabel *storeAddrLabel ;
        UIImageView * addImageView;
        
        if ([self.currentStore.addr isKindOfClass:[NSString class]]) {
            
            if (self.currentStore.addr.length > 0) {
                
                addImageView = [UIImageView newAutoLayoutView];
                addImageView.image = [UIImage imageNamed:@"detailAddr"];
                storeAddrLabel = [UILabel newAutoLayoutView];
                storeAddrLabel.numberOfLines = 0;
                storeAddrLabel.text = self.currentStore.addr;
                storeAddrLabel.font = storeNameFont;
                storeAddrLabel.backgroundColor = [UIColor clearColor];
                storeAddrLabel.textColor = titleColor;
                [headerView addSubview:addImageView];
                [headerView addSubview:storeAddrLabel];
                storeAddrLabelTopContraint =   [storeAddrLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:labelPadding];
                [storeAddrLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:addImageView withOffset:kHeaderIconPadding];
                
                if (self.currentStore.qrcode.length > 0) {
                    [storeAddrLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:4*NAV_BUTTON_RIGTHT_SPACE];
                }
                else{
                    [storeAddrLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:2*NAV_BUTTON_RIGTHT_SPACE];
                }
                
                CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
                if (storeImageView) {
                    labelWidth -= (kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2);
                }
                
                if (INTERFACE_IS_PHONE) {
                    if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                        labelWidth -= 25;
                    }
                }
                if (![self.currentFuncs.isStoreInfo isEqualToString:@"0"]){
                    labelWidth -= 25.0f;
                }                
                CGSize addrSize = [self.currentStore.addr ws_sizeWithFont:storeNameFont constrainedToWidth:labelWidth];
                autoHeight += labelPadding + addrSize.height;
                
                storeAddrImageTopContraint = [addImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:labelPadding + kImageView_And_Detail_Space];
                
                if (isInThinMode || isPhoneMode) {
                    [addImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }
                else {
                    [addImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
                }
                
                [addImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
                [addImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
                
                lastView = storeAddrLabel;
                
                if (self.currentFuncs.readonly && self.currentFuncs.iParentFuncsBean.funcsArray.count == 1 ) {
                    [self addGestureForAddrLabel:storeAddrLabel];
                }
            }
        }
        
        if ([self.currentStore.last_man isKindOfClass:[NSString class]]) {
            
            if ([self.currentStore.last_man length] > 0) {
                
                UIImageView * lastManImageView = [UIImageView newAutoLayoutView];
                lastManImageView.image = [UIImage imageNamed:@"icon_person_white"];
                UILabel *storeLastManLabel = [UILabel newAutoLayoutView];
                storeLastManLabel.numberOfLines = 0;
                NSString *dateValue = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"last_man",nil),self.currentStore.last_man] ;
                storeLastManLabel.text = dateValue;
                storeLastManLabel.font = storeNameFont;
                storeLastManLabel.backgroundColor = [UIColor clearColor];
                storeLastManLabel.textColor = WORKFLOW_HEADERVIEW_COLOR;
                [headerView addSubview:lastManImageView];
                [headerView addSubview:storeLastManLabel];
                [storeLastManLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
                [storeLastManLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastManImageView withOffset:kHeaderIconPadding];
                CGFloat rightPadding = 2*NAV_BUTTON_RIGTHT_SPACE;

                [storeLastManLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:rightPadding];
                
                CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
                if (storeImageView) {
                    labelWidth -= kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2;
                }
                
                if (INTERFACE_IS_PHONE) {
                    if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                        labelWidth -= 25;
                    }
                }
                
                CGSize dateSize = [dateValue ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
                autoHeight += labelPadding + dateSize.height;
                
                [lastManImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding+ kImageView_And_Detail_Space];
                
                if (isInThinMode || isPhoneMode) {
                    [lastManImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }
                else {
                    [lastManImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
                }
                
                [lastManImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
                [lastManImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
                
                lastView = storeLastManLabel;
            }
        }
        
        if ([self.currentStore.last_date isKindOfClass:[NSString class]]) {
            
            if ([self.currentStore.last_date length] > 0) {
                
                UIImageView * lastDateImageView = [UIImageView newAutoLayoutView];
                lastDateImageView.image = [UIImage imageNamed:@"detailTime"];
                UILabel *storeLastDateLabel = [UILabel newAutoLayoutView];
                storeLastDateLabel.numberOfLines = 0;
                NSString *dateValue = [NSString stringWithFormat:NSLocalizedString(@"last_date", nil),self.currentStore.last_date] ;
                storeLastDateLabel.text = dateValue;
                storeLastDateLabel.font = storeIDFont;
                storeLastDateLabel.backgroundColor = [UIColor clearColor];
                storeLastDateLabel.textColor = titleColor;
                [headerView addSubview:lastDateImageView];
                [headerView addSubview:storeLastDateLabel];
                [storeLastDateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
                [storeLastDateLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastDateImageView withOffset:kHeaderIconPadding];
                CGFloat rightPadding = 2*NAV_BUTTON_RIGTHT_SPACE;

                [storeLastDateLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:rightPadding];
                
                CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
                if (storeImageView) {
                    labelWidth -= kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2;
                }
                
                if (INTERFACE_IS_PHONE) {
                    if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                        labelWidth -= 25;
                    }
                }
                
                CGSize dateSize = [dateValue ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
                autoHeight += labelPadding + dateSize.height;
                
                [lastDateImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding+ kImageView_And_Detail_Space];
                
                if (isInThinMode || isPhoneMode) {
                    [lastDateImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }
                else {
                    [lastDateImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
                }
                
                [lastDateImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
                [lastDateImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
                
                lastView = storeLastDateLabel;
            }
        }

        if ([self.currentStore.last_transaction isKindOfClass:[NSString class]]) {
            
            if ([self.currentStore.last_transaction length] > 0) {
                
                UIImageView * lastTransactionImageView = [UIImageView newAutoLayoutView];
                lastTransactionImageView.image = [UIImage imageNamed:@"detailTime"];
                UILabel *storeLastTransactionLabel = [UILabel newAutoLayoutView];
                storeLastTransactionLabel.numberOfLines = 0;
                NSString *lastTransactionValue = [NSString stringWithFormat:NSLocalizedString(@"最近交易:%@", nil),self.currentStore.last_transaction] ;
                storeLastTransactionLabel.text = lastTransactionValue;
                storeLastTransactionLabel.font = storeIDFont;
                storeLastTransactionLabel.backgroundColor = [UIColor clearColor];
                storeLastTransactionLabel.textColor = titleColor;
                [headerView addSubview:lastTransactionImageView];
                [headerView addSubview:storeLastTransactionLabel];
                [storeLastTransactionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
                [storeLastTransactionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastTransactionImageView withOffset:kHeaderIconPadding];
                CGFloat rightPadding = 2*NAV_BUTTON_RIGTHT_SPACE;

                [storeLastTransactionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:rightPadding];
                
                CGFloat labelWidth = self.view.width - codeImageViewWidth - labelPadding;
                if (storeImageView) {
                    labelWidth -= kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2;
                }
                
                if (INTERFACE_IS_PHONE) {
                    if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                        labelWidth -= 25;
                    }
                }
                CGSize dateSize = [lastTransactionValue ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
                autoHeight += labelPadding + dateSize.height;
                
                [lastTransactionImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding  +kImageView_And_Detail_Space];
                
                if (isInThinMode || isPhoneMode) {
                    [lastTransactionImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
                }
                else {
                    [lastTransactionImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
                }
                
                [lastTransactionImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:codeImageView];
                [lastTransactionImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:codeImageView];
                
                lastView = storeLastTransactionLabel;
            }
        }

        UIButton *infoButton = [UIButton newAutoLayoutView];
        if (INTERFACE_IS_PHONE) {
            
            if (isPhoneMode) {
                
                [infoButton setBackgroundImage:[UIImage imageNamed:@"detailPhone"] forState:UIControlStateNormal];
                [headerView addSubview:infoButton];
                [infoButton autoSetDimension:ALDimensionWidth toSize:20];
                [infoButton autoSetDimension:ALDimensionHeight toSize:20];
                [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeIDLabel withOffset:5];
                [infoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:headerView withOffset:-kView_Height];
                [infoButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
                
                [infoButton setBackgroundImage:[UIImage scaledImageForName:@"detailArrowRight" ofType:@"png"] forState:UIControlStateNormal];
                [headerView addSubview:infoButton];
                [infoButton autoSetDimension:ALDimensionWidth toSize:20];
                [infoButton autoSetDimension:ALDimensionHeight toSize:20];

                if (isInThinMode || isPhoneMode) {
                    [infoButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
                }
                else {
                    [infoButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeImageView];
                }
                
                [infoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:headerView withOffset:-kView_Height];
                [infoButton addTarget:self action:@selector(showStoreInfoViewController) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else {
            
            [infoButton setImage:[UIImage imageNamed:@"map_button"] forState:UIControlStateNormal];
            infoButton.backgroundColor = [UIColor clearColor];
            [headerView addSubview:infoButton];
            [infoButton addTarget:self action:@selector(showStoreMapViewController) forControlEvents:UIControlEventTouchUpInside];
            
            CGFloat imageWH;
            [infoButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:storeNameLabel];
            if (isInThinMode) {
                [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:17];
                imageWH = 35;
            }
            else {
                [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeIDLabel withOffset:5];
                autoHeight +=10;
                imageWH = 24;
            }
            
            [infoButton autoSetDimension:ALDimensionWidth toSize:imageWH];
            [infoButton autoSetDimension:ALDimensionHeight toSize:imageWH];
            autoHeight += imageWH;
        }
        
        if (self.currentStore.qrcode.length > 0) {
            
            UIImageView *qrCodeimageView = [[UIImageView alloc] init];
            qrCodeimageView.image = [UIImage imageNamed:@"qrcode.png"];
            [headerView addSubview:qrCodeimageView];
            
            [qrCodeimageView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.right.mas_equalTo(infoButton.mas_left).offset(-5);
                make.top.mas_equalTo(infoButton);
                make.height.mas_equalTo(NAV_BUTTON_RIGTHT_SPACE);
                make.width.mas_equalTo(NAV_BUTTON_RIGTHT_SPACE);
            }];
        }
        
        if (showTemplateFuncsBean) {
            
            UIButton *lastbutton;
            UIView *leftPinEdgeView;
            if ([infoButton superview]) {
                leftPinEdgeView = infoButton;
            }
            else if ([storeImageView superview]) {
                leftPinEdgeView = storeImageView;
            }
            else {
                leftPinEdgeView = headerView;
            }
            
            for (WSFuncsBean *funcsBean in showTemplateFuncsBean.funcsArray) {
                
                UIButton *button = [UIButton newAutoLayoutView];
                [button setImage:[UIImage imageNamed:funcsBean.fv] forState:UIControlStateNormal];
                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [button autoSetDimension:ALDimensionWidth toSize:35];
                [button autoSetDimension:ALDimensionHeight toSize:35];
                button.tag = kTemplateButtonTag + [showTemplateFuncsBean.funcsArray indexOfObject:funcsBean];
                [headerView addSubview:button];
                [button addTarget:self action:@selector(showTemplateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if (isInThinMode) {
                    
                    [button autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:infoButton];
                    if (lastbutton) {
                        [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lastbutton withOffset:30];
                    }
                    else {
                        [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:leftPinEdgeView withOffset:30];
                    }
                }
                else {
                    
                    [button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
                    if (lastbutton) {
                        [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lastbutton withOffset:20];
                    }
                    else {
                        [button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:leftPinEdgeView withOffset:25];
                    }
                }
                
                lastbutton = button;
            }
        }
        
        autoHeight += 30;
        
        if (self.currentStore.auxiliaryInfoArray.count > 0) {
            
            NSArray *dataArray = self.currentStore.auxiliaryInfoArray;
            BOOL isAddAuxiliaryInfo = NO;
            BOOL dataItemsIsShowQstModel = NO;
            for (id model in dataArray) {
                
                if ([model isKindOfClass:[WSShowQstViewSingleLineModel class]]) {
                    dataItemsIsShowQstModel = YES;
                    break;
                }
            }
            
            CGFloat viewWidth = self.view.width - codeImageViewWidth - labelPadding;
            if (storeImageView) {
                viewWidth -= (kHeaderImageViewWH + kHeaderImageViewLeftSpace * 2);
                
            }
            
            if (INTERFACE_IS_PHONE) {
                if (!isPhoneMode && ![self.currentFuncs.isStoreInfo isEqualToString:@"0"] && autoHeight < CGRectGetMaxY(infoButton.frame)) {
                    viewWidth -= 25;
                }
            }
            
            if (dataItemsIsShowQstModel) {
                
                WSShowQstViewForStoreListCellModel * viewModel = [[WSShowQstViewForStoreListCellModel alloc]init];
                viewModel.titleFont = kDetaiTextFont;
                viewModel.defaultColor = titleColor;
                viewModel.displayArray = dataArray;
                
                BOOL isHorizontal = NO;
                CGFloat viewHeight = 0;
                if (dataArray.count > 0) {
                    
                    NSMutableArray *horizontalDisplayArray = [NSMutableArray arrayWithCapacity:10];
                    NSMutableArray *verticalDisplayArray = [NSMutableArray arrayWithCapacity:10];
                    for (WSShowQstViewSingleLineModel * tempModel in dataArray) {
                        
                        if ([tempModel.groupName hasPrefix:@"horizontal"]) {
                            
                            if (!isHorizontal) {
                                isHorizontal = YES;
                                viewHeight += kView_Height;
                            }
                            [horizontalDisplayArray addObject:tempModel];
                        }
                        else {
                            
                            NSString *titileString = [WSShowQstViewForStoreListCell getTitleString:tempModel];
                            CGFloat titleHeight= [titileString ws_sizeWithFont:kDetaiTextFont constrainedToWidth:viewWidth].height;
                            viewHeight += ((titleHeight + 7) > (kView_Height + 7) ? titleHeight + 7 : kView_Height + 7);
                            [verticalDisplayArray addObject:tempModel];
                        }
                    }
                    
                    viewModel.horizontalDisplayArray = horizontalDisplayArray;
                    viewModel.verticalDisplayArray = verticalDisplayArray;
                }
                
                WSShowQstViewForStoreListCell * view = [WSShowQstViewForStoreListCell newAutoLayoutView];
                [headerView addSubview:view];
                [self setConstraintsWithView:view lastView:lastView storeImageView:storeImageView labelPadding:labelPadding];
                lastView = view;
                [view autoSetDimension:ALDimensionHeight toSize:viewHeight];
                
                view.maxWidth = viewWidth;
                view.isHasQstHorizontal = isHorizontal;
                view.currentModel = viewModel;
                autoHeight +=viewHeight +labelPadding;
            }
            else {
                
                for (int i = 0; i < dataArray.count; ++i) {
                    
                    id model = [dataArray objectAtIndex:i];
                    NSString *title = [self auxiliaryInfoFromModel:model];
                    
                    if(title.length <= 0) {
                        continue;
                    }
                
                    isAddAuxiliaryInfo = YES;
                
                    UILabel *titleLabel = [UILabel newAutoLayoutView];
                    titleLabel.numberOfLines = 0;
                    titleLabel.text = title;
                    titleLabel.font = storeIDFont;
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.textColor = titleColor;
                    [headerView addSubview:titleLabel];
                
                    [self setConstraintsWithView:titleLabel lastView:lastView storeImageView:storeImageView labelPadding:labelPadding];
               
                    lastView = titleLabel;
                    CGFloat labelWidth = viewWidth;
                    CGSize addrSize = [title ws_sizeWithFont:storeIDFont constrainedToWidth:labelWidth];
                    autoHeight += labelPadding + addrSize.height;
                }
            
                if (isAddAuxiliaryInfo) {
                    autoHeight += labelPadding;
                }
            }
        }

        UIImageView * isPlanImgView = [UIImageView newAutoLayoutView];
        isPlanImgView.contentMode = UIViewContentModeScaleAspectFit;

        if (self.currentStore.plan) {
            
            isPlanImgView.image = [UIImage imageNamed:@"point_plan_icon"];
            [headerView addSubview:isPlanImgView];
            isPlanImgViewLeftContraint = [isPlanImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeIDLabel withOffset:kHeaderImageViewLeftSpace];
            [isPlanImgView autoSetDimension:ALDimensionHeight toSize:kView_Height];
            [isPlanImgView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeIDLabel];
            [isPlanImgView autoSetDimension:ALDimensionWidth toSize:(kView_Height + 5)];
        }
        
        UIScrollView * imgScrollView = [UIScrollView newAutoLayoutView];
        [headerView addSubview:imgScrollView];
        
        if (self.currentStore.plan) {
            [imgScrollView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:isPlanImgView];
        }
        else{
           imgScrollViewLeftContraint = [imgScrollView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeIDLabel];
        }
        
        [imgScrollView autoSetDimension:ALDimensionHeight toSize:kView_Height];
        [imgScrollView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeIDLabel];
        [imgScrollView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:headerView withOffset: - kHeaderImageViewLeftSpace];
       
        if (self.currentStore.attri!=nil&&[self.currentStore.attri isKindOfClass:[NSString class]]) {
            
            if (self.currentStore.attri && self.currentStore.attri.length > 0) {
                
                NSArray * storeImgs = [self.currentStore.attri componentsSeparatedByString:@","];
                CGFloat imgX = 0;
                for (int i = 0; i < storeImgs.count; i++) {
                    
                    imgX = i * (kView_Height + 5) + (i + 1) *kHeaderIconPadding;
                    UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX  , 0, kView_Height + 5, kView_Height)];
                    imgView.contentMode = UIViewContentModeScaleAspectFit;
                    
                    NSString *imgURLStr = [WSHttpURLHelper getImageCompleteURL:storeImgs[i]];
                    if ([imgURLStr hasSuffix:@"png"] || [imgURLStr hasSuffix:@"jpg"]) {
                        [[WSRequestHelper shareInstance]  downloadImageWithUrl:imgURLStr imageView:imgView];
                    }
                    else {
                        if([storeImgs[i] containsString:@"icon"]) {
                            imgView.image = [UIImage imageNamed: storeImgs[i]];
                        }
                        else {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", storeImgs[i]]];
                        }
                    }
                    
                    [imgScrollView addSubview:imgView];
                    imgScrollView.contentSize = CGSizeMake(imgX, 0);
                }
            }
        }
   
        if (isCode) {
            
            codeImageView.hidden = YES;
            storeIDLabel.hidden = YES;
            if ((self.currentStore.attri && self.currentStore.attri.length > 0) || self.currentStore.plan) {
                
                if (self.currentStore.plan) {
                    
                    [isPlanImgViewLeftContraint autoRemove];
                    if (isInThinMode || isPhoneMode) {
                        isPlanImgViewLeftContraint = [isPlanImgView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHeaderImageViewLeftSpace];
                    }
                    else {
                        isPlanImgViewLeftContraint = [isPlanImgView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderIconPadding];
                    }
                }
                else {
                    
                    [imgScrollViewLeftContraint autoRemove];
                    if (isInThinMode || isPhoneMode) {
                        imgScrollViewLeftContraint = [imgScrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHeaderImageViewLeftSpace];
                    }
                    else {
                        imgScrollViewLeftContraint = [imgScrollView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderIconPadding];
                    }
                }
            }
            else {
                
                [storeAddrImageTopContraint autoRemove];
                [storeAddrLabelTopContraint autoRemove];
                if (isInThinMode || isPhoneMode) {
                    storeAddrLabelTopContraint = [storeAddrLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kHeaderImageViewLeftSpace];
                    storeAddrImageTopContraint = [addImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kHeaderImageViewLeftSpace];
                }
                else {
                    storeAddrLabelTopContraint = [storeAddrLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeImageView withOffset:10];
                    storeAddrImageTopContraint = [addImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeImageView withOffset:10];
                }
            }
        }

        [headerView addSubview:self.storeInfoBtn];
        [self.storeInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(codeImageView.mas_left).offset(0);
            make.top.mas_equalTo(lastView.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(90);
        }];
    }
    
    UIColor *bottomLineColor = [UIColor colorForKey:@"WorkFlowTitleViewBottomLineColor"];
    if (bottomLineColor) {
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor redColor];
        [headerView addSubview:line];
        [line autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:headerView];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    }
    
    [headerView setFrame:CGRectMake(0, 0, self.view.width, MAX(kHeaderViewMinHeight, autoHeight))];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headView = headerView;
    return headerView;
}

- (void)setConstraintsWithView:(UIView *)view  lastView:(UIView *)lastView storeImageView:(UIImageView *)storeImageView labelPadding:(CGFloat)labelPadding {
    
    [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:labelPadding];
    if (storeImageView) {
        [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:storeImageView withOffset:kHeaderImageViewCodeSpace];
    }
    else {
        [view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHeaderImageViewLeftSpace];
    }
    
    [view autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:2 * NAV_BUTTON_RIGTHT_SPACE];
}


- (void)addGestureForAddrLabel:(UILabel *)label {
    
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToStoreMap)];
    [label addGestureRecognizer:gesture];
}

- (void)jumpToStoreMap {
    
    WSAllStoresMapViewController * storeMap = [[WSAllStoresMapViewController alloc]initWithFuncs:self.currentFuncs];
    storeMap.storeMap = self.currentStore;
    [self.navigationController pushViewController:storeMap animated:YES];
}

- (void)showTemplateButtonAction:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *button = (UIButton *)sender;
        NSInteger index = button.tag - kTemplateButtonTag;
        WSFuncsBean *fb = [showTemplateFuncsBean.funcsArray objectAtIndex:index];
        
        NSString *detectFc = self.moduleFC;
        if (self.input_reflect_code && [self.input_reflect_code length] > 0) {
            if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                detectFc = self.input_reflect_code;
            }
        }
        
        NSString *enterTime = [[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC];
        NSString *leaveTime = [[WSInoutStoreTable sharedTable] getLeaveStoreTime:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC];
        
        if((![[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC]
           && (![fb.fv isEqualToString:ENTERSTORE_FV])
           && ![fb.required isEqualToString:@"E"])
           || ([enterTime compare:leaveTime] == NSOrderedSame)) {
            
            NSString *EnterStoreString = NSLocalizedString(@"not_enter_store",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:EnterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
        if (vc) {
            
            WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:vc];
            [vc leftItemImage:@"icon_back" target:vc action:@selector(backAction)];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (void)showStoreMapViewController {
    
    WSStoreInfoMapViewController *mapCon = [[WSStoreInfoMapViewController alloc] init];
    if (self.wsSplitController) {
        
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:mapCon];
        [self.wsSplitController showRightController:nav];
    }
    else {
        
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:mapCon animated:YES];
        }
        else {
            [self.navigationController pushViewController:mapCon animated:YES];
        }
    }
}

- (void)showStoreInfoViewController {
    
    UIViewController *storeInfo = nil;

    if ([self.unredo isEqualToString:@"0"]) {
        [self startGetStoreInfoBySotre:self.currentStore];
    }
    else {
        
        if (!self.currentFuncs.isStoreInfo || [self.currentFuncs.isStoreInfo length] == 0 || [self.currentFuncs.isStoreInfo isEqualToString:@"1"]) {
            
            storeInfo = [[WSStoreInfoViewController alloc] initWithStoreInfo:self.currentStore withSubempStore:self.subempStore];
            [[WSStatisticsManager sharedInstance] insertStoreInfoSenceEventWithID:EVENT_STORE_INFO parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs
                                                                            store:self.currentStore
                                                                          senceId:SCENE_VISIT_STORE eventValue:EVENT_STORE_INFO startTime:[WSCurrentTime getTimeMillisStringForDevice]
                                                                          endTime:nil genId:[WSStatisticsManager getGenId]];
        }
        else if ([self.currentFuncs.isStoreInfo isEqualToString:@"3"]) {
            
            storeInfo = [[WSPfizerEtripModifyStoreInfoViewController alloc] initWithFuncs:self.currentFuncs store:self.currentStore storeInfoDic:nil];
        }
        else if ([self.currentFuncs.isStoreInfo length] > 0) {

            WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
            WSFuncsBean *storeInfoFB = [fba getFuncsBeanFromAllFucsWithFC:self.currentFuncs.isStoreInfo];
            storeInfo = [self checkNextPageWithFuncsBean:storeInfoFB withShowToast:NO isInStore:NO];
        }
        
        NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
        if (self.currentStore == nil) {
            StoreInforString = @"客户信息";
        }
        storeInfo.title = StoreInforString;

        [self pushViewController:storeInfo isAutoJump:NO];
    }
}

-(void)showStoreImageView:(UITapGestureRecognizer *)gesture {
    
    if ([self.currentFuncs.opt.isUpdateStoreIcon isEqualToString:@"1"]) {
        
        WSUpdateStoreIconViewController * updateStoreIcon = [[WSUpdateStoreIconViewController alloc]initWithFuncs:self.currentFuncs];
        updateStoreIcon.store = self.currentStore;
        __weak typeof(self)weakSelf  = self;
        updateStoreIcon.reloadStoreImage = ^(NSString *imageIndex) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.currentStore.storeImg = imageIndex;
                [weakSelf reloadHeaderView];
            });
        };
        
        [self.navigationController pushViewController:updateStoreIcon animated:YES];
        return;
    }
    
    self.headView.userInteractionEnabled = NO;
    UIImageView * imageView = (UIImageView *)(gesture.view);
    if (imageView) {
        [self scaleImageWithImageArray:@[imageView.image] index:0];
    }
}

- (void)scaleImageWithImageArray:(NSArray *)array index:(NSInteger)index {
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    if(INTERFACE_IS_PAD){
        
        UIViewController *topVC = kApplicationWinddow.rootViewController;
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            topVC = ((UINavigationController *)topVC).visibleViewController;
        }
        else if (topVC.presentedViewController) {
            while (topVC.presentedViewController) {
                topVC = topVC.presentedViewController;
            }
        }

        rootView = topVC.view;
    }
    
    WSImageBrowserView *view = [[WSImageBrowserView alloc]initWithFrame:INTERFACE_IS_PAD ? CGRectMake(0, 0, BROWSERVC_WIDTH, BROWSERVC_HEIGNT) : kApplicationWinddow.bounds andImage:array andImageIndex:index];
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchShowImageViewEnd:)];
    [view addGestureRecognizer:gesture];
    if (INTERFACE_IS_PAD) {
        view.frame = CGRectMake((BROWSERVC_WIDTH - view.width)/2,view.size.height, view.size.width, view.size.height);
    }
    else {
        view.frame = CGRectMake(view.origin.x,rootView.size.height, view.size.width, rootView.size.height);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        view.top = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
                     completion:^(BOOL finished) {
    }];
    [rootView addSubview:view];
}

- (void)touchShowImageViewEnd:(UITapGestureRecognizer *)gesture {
    
    self.headView.userInteractionEnabled = YES;

    [UIView animateWithDuration:0.25 animations:^{
        
        gesture.view.top = gesture.view.height;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } completion:^(BOOL finished) {
        [gesture.view removeFromSuperview];
    }];
}

- (BOOL)shouldPauseBackAction {
    
    if (self.currentStore) {
        
        BOOL isEnterStore = [[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
        if (isEnterStore) {
            BOOL isLeaveStore = [[WSInoutStoreTable sharedTable] isLeaveStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
            if (!isLeaveStore) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)backAction {
    
    BOOL isEnterStore = NO;
    if (self.currentStore) {
        isEnterStore = [[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
    }
    
    if (isEnterStore) {
        
        BOOL isLeaveStore = [[WSInoutStoreTable sharedTable] isLeaveStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
        if (isLeaveStore||[self.currentFuncs.opt.leaveStoreTip isEqualToString:@"0"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
            [self backToParent];
        }
        else {

            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"post_quit_message", nil)];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label",nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
                [self backToParent];
            }];
            [alert show];
        }
    }
    else {
        [self backToParent];
    }
}

- (BOOL)backToParent{
    
    NSString *isShipKey = [NSString stringWithFormat:@"isShiped%@",self.currentStore.Id];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:isShipKey];
    
    if (self.backVC) {
        [self.navigationController popToViewController:self.backVC animated:YES];
        return YES;
    }
    else {
        return [super backToParent];
    }
}

- (void)transferfunction:(WSFuncsBean*)aFunction withDictionary:(NSMutableDictionary *)aDic withName:(NSString*)aName {
    
    if (aFunction != nil) {
        
        NSMutableString *string = [[NSMutableString alloc] initWithCapacity:10];
        if (aName != nil) {
            
            if (aName.length > 0) {
                [string appendString:aName];
                [string appendString:@"-"];
            }
            [string appendString:aFunction.name];
        }

        if (aFunction.funcsArray == nil) {
            
            WSFuncsBean_opt* fb_opt = aFunction.opt;
            if (fb_opt && fb_opt.isCode) {
                
                NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:8];
                if (string) {
                    [temp setObject:string forKey:@"fname"];
                }
                
                if (aFunction.fc) {
                    [temp setObject:aFunction.fc forKey:@"fcode"];
                }
                
                if ([WSAppData getObjectbyKey:APPDATA_EMPID]) {
                    [temp setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"fempid"];
                }
                
                [temp setObject:@"0" forKey:@"fischecked"];
                if (self.currentStore.Id) {
                    [temp setObject:self.currentStore.Id forKey:@"fstoreid"];
                }
                
                [temp setObject:@"" forKey:@"fitem"];
                
                if (temp) {
                    [aDic setObject:temp forKey:[NSString stringWithFormat:@"%@||%@||%@", [WSAppData getObjectbyKey:APPDATA_EMPID],self.currentStore.Id,aFunction.fc]];
                }
                temp = nil;
            }
        }
        
        for (WSFuncsBean *bean in aFunction.funcsArray) {
            [self transferfunction:bean withDictionary:aDic withName:string];
        }
    }
}

- (void)reloadView {
    
    [self refreshCollectionView];
}

- (void)removeSelection {
    
    [self.collectionController removeSelection];
}

- (void)refreshCollectionView {
    
    [self.collectionController reloadData];
}

- (void)reloadHeaderView {
    
    for (UIView *subView in self.headView.subviews) {
        
        if (subView.tag == 10002) {
            
            UIImageView *storeImageView = (UIImageView *)subView;
            NSString *detectFc = self.moduleFC;
            if (self.input_reflect_code && [self.input_reflect_code length]>0) {
                
                if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                    detectFc = self.input_reflect_code;
                }
            }
            
            NSString *local_image = [[WSInoutStoreTable sharedTable]getStoreLocalImageWithStore:self.currentStore andOtherParam:nil andParamType:EParameterType_NULL];
            if ([self.currentStore.storeImg length] > 0){
                
                if ([self.currentStore.storeImg rangeOfString:@"."].location != NSNotFound) {
                    [[WSRequestHelper shareInstance]  downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.currentStore.storeImg]
                                                                 imageView:storeImageView placeholderImage:[UIImage imageNamed:@"shop_default"]];
                }
                else {
                    
                    NSArray *imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.currentStore.storeImg];
                    if (imagePathArray.count) {
                        
                        WSImagePathObject *object = [imagePathArray lastObject];
                        if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                            NSString * url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:url] imageView:storeImageView placeholderImage:[UIImage imageNamed:@"shop_default"]];
                        }
                        else {
                            UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
                            if (image) {
                                storeImageView.image = image;
                            }
                            else {
                                storeImageView.image = [UIImage imageNamed:@"shop_default"];
                            }
                        }
                    }
                }
            }
            else if (local_image && local_image.length >0 && ![local_image isEqualToString:@"null"]) {
                
                NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
                if (![isUsePhotos isEqualToString:@"2"]) {
                    UIImage *localImage =[[SDImageCache sharedImageCache]imageFromKey:local_image fromDisk:YES];
                    storeImageView.image = localImage;
                }
                else {
                    storeImageView.image = [UIImage imageNamed:@"shop_default"];
                }
            }
            else {
                storeImageView.image = [UIImage imageNamed:@"shop_default"];
            }
        }
    }
}

- (WCBaseViewController *)getDefaultShowController {
    
    [self initFuncsBeanData];
    
    if (self.funcBeanArray && [self.funcBeanArray count] == 1) {
        
        WSFuncsBean* fb = [self.funcBeanArray objectAtIndex:0];
        WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
        [self getVisitActionStatusWithFuncsBean:fb action:action];
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        WCBaseViewController *vc = (WCBaseViewController *)[self checkNextPageWithFuncsBean:fb withShowToast:NO];
        vc.currentVisitAction = action;
        return vc;
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if ([self.currentFuncs.opt.sendRequest isEqualToString:@"1"]) {
        [self startUpdateStoreWithFb:self.currentFuncs];
    }
    
    for (WSFuncsBean *fb in self.funcBeanArray) {
        WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
        [self getVisitActionStatusWithFuncsBean:fb action:action];
    }

    [self refreshCollectionView];
    [self reloadHeaderView];
    [self showMemoTouch];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!self.isLoaded) {
        
        self.isLoaded = YES;
        
        if ((INTERFACE_IS_PHONE || (INTERFACE_IS_PAD && !self.wsSplitController)) && self.funcBeanArray && [self.funcBeanArray count] == 1) { //iPad上已经在splitController里显示
            WSFuncsBean* fb = [self.funcBeanArray objectAtIndex:0];
            UIViewController *vc = [self checkNextPageWithFuncsBean:fb withShowToast:NO];
            [self gotoNextPageWithViewController:vc withFuncsBean:fb withAutoJump:YES];
        }
        
        if (self.funcBeanArray.count > 1 && [self.currentStore.actionState isEqualToString:ActionNotStart]) {
            
            NSArray *requridArray = @[kRequrid_Directaccess];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"self.required in %@",requridArray];
            NSArray *funcArray = [self.funcBeanArray filteredArrayUsingPredicate:thePredicate];

            if (funcArray.count > 0) {
                
                WSFuncsBean *fb = [funcArray firstObject];
                UIViewController *vc = [self checkNextPageWithFuncsBean:fb withShowToast:NO isInStore:NO];
                [self gotoNextPageWithViewController:vc withFuncsBean:fb withAutoJump:YES];
                if ([vc isKindOfClass:[WSReportFormController class]]) {
                    
                    WSReportFormController * reportVC =  (WSReportFormController*)vc;
                    __weak typeof (self) weakSelf = self;
                    [reportVC setShowTips:^{
                        [weakSelf p_addOrangeAndDisReqTips];
                    }];
                }
            }
        }
    }
    else {

        if ((INTERFACE_IS_PHONE || (INTERFACE_IS_PAD && !self.wsSplitController)) && self.funcBeanArray && [self.funcBeanArray count] == 1) {
            
            WSFuncsBean* fb = [self.funcBeanArray objectAtIndex:0];
            WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
            VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action intOutFlag:self.input_reflect_code];
            if ([status isEqualToString:ActionDone]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self hideMemoTouch];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)navButtonClick:(UIButton *)button {
    
    if (self.currentStore.latitude && self.currentStore.longitude) {
        [WSTLAlertManager addMapNavigationCustomAlertViewWithStorebean:self.currentStore];
    }
    else {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"无门店经纬度!", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
    }
}

- (void)callAction:(id)sender {

    if (self.linktelArray.count > 0) {
        
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_label",nil) destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        for (NSString * title in self.linktelArray) {
            [actionSheet addButtonWithTitle:title];
        }
        [actionSheet showInView:self.view];
    }
}

- (void)getTopTip {
    
    NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"topTip != %@", [NSNull null]];
    NSArray *topTipArray = [self.funcBeanArray filteredArrayUsingPredicate:predicateNotNull];
    if (!topTipArray || [topTipArray count] == 0) {
        
        for (WSFuncsBean *funcBean in self.funcBeanArray) {
            
            NSArray *subFuncBeanArray = funcBean.funcsArray;
            if ([subFuncBeanArray count] > 0) {
                topTipArray = [subFuncBeanArray filteredArrayUsingPredicate:predicateNotNull];
                if ([topTipArray count] > 0) {
                    break;
                }
            }
        }
        
        if (!topTipArray || [topTipArray count] == 0) {
            return;
        }
    }
    
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    WSBaseAcvtdisDBService *acvtDisService = [[WSBaseAcvtdisDBService alloc] init];
    NSInteger topTipCount = 0;
    for (WSFuncsBean *fb in topTipArray) {
        
        WSAcvtBean_qst *acvtQst = [acvtService queryQstWithAcvtQstCode:fb.topTip];
        WSBaseStoreAcvtDisObject *object = [[acvtDisService queryStoreAcvtDisBeanArrayWithStoreID:self.currentStore.Id acvtQstID:acvtQst.acvtQstId noteName:nil] firstObject];

        NSString *topTipKey = [self getTopTipKeyByAcvtQstId:acvtQst.acvtQstId storeId:self.currentStore.Id];
        BOOL isHidden = [self getTopTipHiddenByKey:topTipKey];
        if (isHidden) {
            continue;
        }
        
        if (object.acvt_qst_answer.length > 0) {
            
            WSWorkFlowNoticeView *noticeView = [[WSWorkFlowNoticeView alloc] initWithFrame:CGRectMake(0, -MAIN_NOTICE_HEIGHT, self.view.width, MAIN_NOTICE_HEIGHT)];
            [self.view addSubview:noticeView];
            [noticeView setNoticeText:[NSString stringWithFormat:@"%@ : %@", acvtQst.qstName, object.acvt_qst_answer]];
            [noticeView setHidden:NO];
            [noticeView setIsShowCloseButton:YES];
            [noticeView setFb:fb];
            
            [UIView animateWithDuration:0.3 animations:^{
                noticeView.frame = CGRectMake(0, topTipCount * MAIN_NOTICE_HEIGHT, self.view.width, MAIN_NOTICE_HEIGHT);
            }];
            
            topTipCount++;
            
            __weak typeof (self) weakSelf = self;
            noticeView.noticeBlock = ^(WSFuncsBean *fb) {
                UIViewController *vc = [weakSelf checkNextPageWithFuncsBean:fb withShowToast:YES];
                [weakSelf gotoNextPageWithViewController:vc withFuncsBean:fb withAutoJump:NO];
                [weakSelf setTopTipHiddenByKey:topTipKey];
            };
            
            noticeView.closeBlock = ^() {
                [weakSelf setTopTipHiddenByKey:topTipKey];
            };
        }
    }
}

- (NSString *)getTopTipKeyByAcvtQstId:(NSString *)acvtQstId storeId:(NSString *)storeId {
    
    NSString *topTipKey = [NSString stringWithFormat:@"%@-%@-%@-%@", kTopTipKey, acvtQstId, storeId, [WSAppData getObjectbyKey:APPDATA_EMPID]];
    return topTipKey;
}

- (void)setTopTipHiddenByKey:(NSString *)topTipKey {
    
    NSString *dateString = [WSCurrentTime getDateString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dateString forKey:topTipKey];
}

- (BOOL)getTopTipHiddenByKey:(NSString *)topTipKey {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dateString = [userDefaults objectForKey:topTipKey];
    if (!dateString || ![dateString isKindOfClass:[NSString class]]) {
        return NO;
    }
    else {
        NSString *currentDateString = [WSCurrentTime getDateString];
        if ([dateString isEqualToString:currentDateString]) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)setupNavScrollTitle {
    
    CGFloat margin = [self.navigationController getNavTitleMargin];
    WSScrollLabelView *scrollLabelView = [[WSScrollLabelView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - margin, 44)];
    scrollLabelView.text = self.navigationItem.title;
    UIColor *navBarTitleColor = [UIColor colorForKey:@"NavigationBarTitleColor"]; //获取导航的颜色
    UIFont *navBarTitleFont = [UIFont fontForKey:@"NavigationBarTitleFont"]; //获取导航的字体
    scrollLabelView.textColor = navBarTitleColor;
    scrollLabelView.font = navBarTitleFont;
    

    self.navigationItem.titleView = scrollLabelView;
}

- (UIButton*)storeInfoBtn {
    
    if (!_storeInfoBtn) {
        
        _storeInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_storeInfoBtn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        _storeInfoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 0);
        [_storeInfoBtn setBackgroundColor:RGBCOLOR(239, 254, 229)];
        [_storeInfoBtn setImage:[UIImage imageNamed:@"icon_right"] forState:UIControlStateNormal];
        [_storeInfoBtn setTitle:tskf_storeInfoName forState:UIControlStateNormal];
        [_storeInfoBtn setTitleColor:RGBCOLOR(123, 177, 99) forState:UIControlStateNormal];
        _storeInfoBtn.titleLabel.font = FONT(13.0);
        [_storeInfoBtn addTarget:self action:@selector(clickStoreInfoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _storeInfoBtn;
}

- (void)clickStoreInfoAction {
    
    if (self.currentFuncs.opt.jumpStoreInfoUrl.length == 0) {
        return;
    }
    
    WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
    vc.currentStore = self.currentStore;
    vc.externalOpenUrl = self.currentFuncs.opt.jumpStoreInfoUrl;
    [self gotToController:vc];
}

- (void)gotToController:(WCBaseViewController *)wfvc {

    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    else {
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex != 0) {
        
        NSString * phone = [[self.linktelArray[buttonIndex -1] componentsSeparatedByString:@":"]lastObject];
        phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
        if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
            [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([actionSheet respondsToSelector:selector]) {
        
        UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]]) {
            
            for (UIAlertAction  *action in alertController.actions) {
                if ([action.title isEqualToString:NSLocalizedString(@"cancel_label",nil)]) {
                    [action setValue:[UIColor redColor] forKey:@"_titleTextColor"];
                }
                else{
                    [action setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                }
            }
        }
    }
    else {
        for (UIView * subView in actionSheet.subviews) {
            
            if ([subView isKindOfClass:[UIButton class]] ) {
                
                UIButton * btn = (UIButton*)subView;
                if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"cancel_label",nil)] ) {
                    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                else{
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        }
    }
}
- (void)addNotificationObserver{
    
    if ([self.currentVisitAction.fromModuleName isEqualToString:kHelpSales_Name]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCnyAction) name:CNY_ACTIVITY_NOT object:nil];
    
}

- (void)activityCnyAction {
    [self p_addCNYActivityTips];
}

- (void)p_addCNYActivityTips{
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSString * server_orange_answer = [service queryCNYActivityAndMainDisplayNumberStoreId:self.currentStore.Id andQstCode:@"fffclMsg"];
    if (server_orange_answer.length>0){
        [self addChencShowAlertTipsWithMsg:server_orange_answer];
    }
}

#pragma mark - 通过模型获取辅助信息方法
- (NSString *)auxiliaryInfoFromModel:(id)model {
    
    if ([model isKindOfClass:[WSShowQstViewSingleLineModel class]]) {
        
        WSShowQstViewSingleLineModel *showQstViewSingleLineModel = (WSShowQstViewSingleLineModel *)model;
        NSArray *qstanwserArray = [showQstViewSingleLineModel.qstanwser componentsSeparatedByString:@"@"];
        NSString *qstAnwser = [qstanwserArray firstObject];
        NSString *qstName = showQstViewSingleLineModel.qstname;
        
        if ([showQstViewSingleLineModel.hideQstName isEqualToString:@"1"]) {
            return ((qstAnwser.length > 0) ? qstAnwser : nil);
        }

        NSString *auxiliaryInfo = [NSString stringWithFormat:@"%@%@", ((qstName.length > 0) ? qstName : @""), ((qstAnwser.length > 0) ? qstAnwser : @"")];
        return ((auxiliaryInfo.length > 0) ? auxiliaryInfo : nil);
    }
    
    return nil;
}

#pragma mark - 橙色采集、主货架必填添加弹框校验
- (void)p_addOrangeAndDisReqTips {
    
    if ([self.currentFuncs.opt.showReqTips isEqualToString:@"0"]) {
        return;
    }
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSInteger server_orange_answer = [service queryOrangeCollectAndMainDisplayNumberStoreId:self.currentStore.Id andQstCode:@"isupload_FAC_864"];
    LogInfo(@"WSWorkFlowViewController p_addOrangeAndDisReqTips server_orange_answer 服务器下发橙色采集上传状态：%ld", server_orange_answer);
    NSInteger server_display_answer = [service queryOrangeCollectAndMainDisplayNumberStoreId:self.currentStore.Id andQstCode:@"isupload_FAC_865"];
    LogInfo(@"WSWorkFlowViewController p_addOrangeAndDisReqTips server_display_answer 服务器下发主货架/二次陈列上传状态：%ld", server_display_answer);
    
    NSString * msg = @"";
    if (server_orange_answer == 1 && server_display_answer == 1) {
        msg = @"该门店当前有完美门店活动及主货架/二次陈列活动需要拍摄，请执行!";
    }
    else if (server_orange_answer == 1) {
         msg = @"该门店当前有完美门店活动需要拍摄，请执行!";
    }
    else if (server_display_answer == 1) {
        msg = @"该门店当前有主货架/二次陈列活动需要拍摄，请执行!";
    }

    [self addChencShowAlertTipsWithMsg:msg];
}

#pragma mark - 显示备忘录按键方法
- (void)showMemoTouch {
    
    NSString *memoURL = [LEOMemoTouch isShowMemoURL];
    if (memoURL && memoURL.length > 0) {

        __weak __typeof__(self) weakSelf = self;
        [[LEOMemoTouch subSharedInstance] setMainBtnClickedCallbackBlock:^{
        
            __strong typeof(weakSelf) strongSelf = weakSelf;
            WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
            vc.externalOpenUrl = memoURL;
            vc.hidesBottomBarWhenPushed = YES;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }];
        
        [[LEOMemoTouch subSharedInstance] show];
    }
}

#pragma mark - 隐藏备忘录按键方法
- (void)hideMemoTouch {
    
    [[LEOMemoTouch subSharedInstance] setMainBtnClickedCallbackBlock:^{}];
    [[LEOMemoTouch subSharedInstance] hide];
}

@end
//========================================================================================================================================================
