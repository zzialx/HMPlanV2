//
//  WSNewTodayVisitAndAllStoreCell.m
//  WinSFA
//
//  Created by sunhongfu on 2017/12/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSNewStoreListTool.h"
#import "GlobalUtil.h"
#import "WSRequestHelper.h"
#import "WSImagePathTable.h"
#import "WSInoutStoreTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSEnvrionment.h"
#import "WSTLAlertManager.h"

static CGFloat storeIconWidth;

#define KLittleGap              8
#define ALL_STORE_CELL_FONT     [UIFont fontForKey:@"WSAllStoreCell"] ? : [UIFont systemFontOfSize:INTERFACE_IS_PAD ? (UI_SubViewForStoreList_Font13or15 + 3):18]
#define kALLSTORECellTitleColor ([UIColor colorForKey:@"WSAllStoreCell"] ? [UIColor colorForKey:@"WSAllStoreCell"] : [UIColor colorWithHexString:@"333333"])

@interface WSNewTodayVisitAndAllStoreCell () {
    
    BOOL userStoreIcon;
    BOOL userStoreSelect;
    NSInteger NaviDisNum;
    CGFloat _cellWidth;
    BOOL isHideCode;
    NSMutableArray *acvtdisServiceArray;
}

@property (nonatomic, strong) UIView *lastBottomView;
@property (nonatomic, strong) WSBaseAcvtDBService *acvtService;
@property (nonatomic, strong) WSBaseAcvtdisDBService *acvtdisService;
@property (nonatomic, strong) UIView *storeListAcvtCodeView;
@property (nonatomic, copy) NSString *acvtCode;

@end

@implementation WSNewTodayVisitAndAllStoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        storeIconWidth = 52;
        storeIconTopSpace = 22;
        storeIconleftSpace = 25;
        firstLabelTopSpace = 18;
        firstForSecondLabelSpace = 12;
        labelSpace = 10;
        nameLabelForStoreAsattriViewSpace = 24;
        codePadding = 7;
        self.isChatVisible = NO;
        _cellWidth = cellWidth;
        acvtdisServiceArray = [NSMutableArray array];

        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    if ([isUsePhotos isEqualToString:@"0"]) {
        userStoreIcon = NO;
    }
    else {
        userStoreIcon = YES;
        [self.storeIcon addSubview:self.chatImage];
    }
    
    [self.contentView addSubview:self.storeSelect];
    [self.contentView addSubview:self.storeIcon];
    [self.contentView addSubview:self.storeNavButton];
    [self.contentView addSubview:self.storeNameLabel];
    [self.contentView addSubview:self.storeCodeImg];
    [self.contentView addSubview:self.storeCodeLabel];
    [self.contentView addSubview:self.storeAsattriView];
    [self.contentView addSubview:self.addressImg];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.storeLastmanView];
    [self.contentView addSubview:self.storeLastmanLabel];
    [self.contentView addSubview:self.lastDateImgView];
    [self.contentView addSubview:self.storeLastDateLabel];
    [self.contentView addSubview:self.storeLastTransactionImgView];
    [self.contentView addSubview:self.storeLastTransactionLabe];
    [self.contentView addSubview:self.storeMonthVisitTimeImgView];
    [self.contentView addSubview:self.storeMonthVisitTimeLable];
    [self.contentView addSubview:self.prepareAndVisitStateBtn];
    [self.contentView addSubview:self.storeListAcvtCodeView];
    [self.contentView addSubview:self.loadTag];
}

- (void)makeSubViewsConstraints {
    
    storeIconWidth = 52;
    storeIconTopSpace = 22-2;
    storeIconleftSpace = 25;
    firstLabelTopSpace = 18;
    firstForSecondLabelSpace = 12;
    labelSpace = 10;
    nameLabelForStoreAsattriViewSpace = 24;
    
    if (userStoreSelect) {
        
        storeIconleftSpace += 20;
        [self.storeSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset((storeIconleftSpace-17)/2);
            make.top.equalTo(self).offset((storeIconTopSpace+storeIconWidth/2-8));
            make.size.equalTo(CGSizeMake(17, 17));
        }];
    }

    [self.storeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(storeIconleftSpace);
        make.top.equalTo(self).offset(storeIconTopSpace);
        make.size.equalTo(CGSizeMake((userStoreIcon ? storeIconWidth : 0), (userStoreIcon ? storeIconWidth : 0)));
    }];
    
    if (userStoreIcon) {
        
        [self.chatImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.storeIcon);
            make.bottom.equalTo(self.storeIcon.mas_bottom);
            make.size.equalTo(CGSizeMake((userStoreIcon ? self.chatImage.image.size.width : 0), (userStoreIcon ? self.chatImage.image.size.height : 0)));
        }];
    }
    
    [self.storeNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo((userStoreIcon ? self.storeIcon.mas_right : self)).offset(kView_Space_Left);
        make.top.equalTo(self).offset(kViewForStoreList_Space_Top);
        make.right.equalTo(isHideCode ? (self.storeAsattriView.mas_left) : self).offset(-kView_Space_Left);
    }];
    self.lastBottomView = self.storeNameLabel;
    
    CGFloat prepareStateBtnWidth = [GlobalUtil getTextWidth:self.prepareAndVisitStateBtn.titleLabel.font string:prepareAndVisitStateBtnText] + 5;
    [self.prepareAndVisitStateBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.mas_bottom).offset(-labelSpace);
        make.right.equalTo(self).offset(-K_VISIT_STATUS_LEFT_SPACE);
        CGSize btnSize = (CGSizeMake(prepareStateBtnWidth > 5 ? (K_NAV_BUTTON_STOREList_WIDHT > prepareStateBtnWidth ? K_NAV_BUTTON_STOREList_WIDHT : prepareStateBtnWidth):0, kView_Height));
        make.size.equalTo(btnSize);
    }];
    
    [self.storeCodeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.storeCodeLabel.text.length>0? kView_Height - 3 : 0,self.storeCodeLabel.text.length>0 ? kView_Height - 3 : 0));
    }];

    CGFloat storeCodeLabelWidth = [GlobalUtil getTextWidth:self.storeCodeLabel.font string:self.storeCodeLabel.text]+1;
    [self.storeCodeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.storeCodeImg.mas_right).offset(codePadding);
        make.top.equalTo(self.storeCodeImg.mas_top).offset(-2);
        make.width.equalTo(storeCodeLabelWidth);
    }];

    if (self.storeCodeLabel.text.length) {
        self.lastBottomView = self.storeCodeLabel;
    }
    
    [self.storeAsattriView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-K_VISIT_STATUS_LEFT_SPACE);
        make.size.equalTo(CGSizeMake(storeAsattriViewWidth, kView_Height));
        make.centerY.equalTo((isHideCode ? self.storeNameLabel : self.storeCodeLabel));
    }];

    [self.addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.addressLabel.text.length>0? kView_Height - 3 : 0,self.addressLabel.text.length>0? kView_Height - 3 : 0));
    }];

    CGSize storeNavBtnSize = [GlobalUtil sizeOfContent:_store.distance labelFont:self.storeNavButton.titleLabel.font isFixWidth:NO fixValue:1000];
    storeNavBtnSize.width = storeNavBtnSize.width+5;
    CGFloat storeNavButtonWidth = storeNavBtnSize.width + self.storeNavButton.imageView.image.size.width;
    [self.addressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.addressImg.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-(storeNavBtnSize.width > 5 ? (storeNavButtonWidth+labelSpace*2) : labelSpace));
        make.top.equalTo(self.addressImg.mas_top).offset(-2);
    }];
    
    if (self.addressLabel.text.length) {
        self.lastBottomView = self.addressLabel;
    }
    
    if ((self.lastBottomView = self.addressLabel)) {
       
        [self.storeNavButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-labelSpace);
            make.top.equalTo(self.storeNameLabel.mas_bottom).offset(codePadding);
            make.size.equalTo(CGSizeMake(storeNavBtnSize.width > 5 ? (storeNavBtnSize.width + self.storeNavButton.imageView.image.size.width) : 0, self.storeNavButton.imageView.image.size.height?self.storeNavButton.imageView.image.size.height:storeNavBtnSize.height));
        }];
    }
    
    [self.storeLastmanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.storeLastmanLabel.text.length>0? kView_Height - 3 : 0,self.storeLastmanLabel.text.length>0? kView_Height - 3 : 0));
    }];
    
    [self.storeLastmanLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeLastmanView.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.top.equalTo(self.storeLastmanView.mas_top).offset(-2);
    }];
    
    if (self.storeLastmanLabel.text.length) {
        self.lastBottomView = self.storeLastmanLabel;
    }
    
    [self.lastDateImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(_storeLastDateLabel.text.length > 0? kView_Height - 3 : 0,_storeLastDateLabel.text.length > 0? kView_Height - 3 : 0));
    }];

    [self.storeLastDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lastDateImgView.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.top.equalTo(self.lastDateImgView.mas_top).offset(-2);
        make.height.equalTo(self.storeLastDateLabel.text.length > 0 ? 15 : 0);
    }];
    
    if (_store.last_date.length) {
        self.lastBottomView = self.storeLastDateLabel;
    }
    
    [self.storeLastTransactionImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.storeLastTransactionLabe.text.length>0? kView_Height - 3 : 0,self.storeLastTransactionLabe.text.length>0? kView_Height - 3 : 0));
    }];
    
    [self.storeLastTransactionLabe mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeLastTransactionImgView.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.top.equalTo(self.storeLastTransactionImgView.mas_top).offset(-2);
    }];
    
    if (self.storeLastTransactionLabe.text.length) {
        self.lastBottomView = self.storeLastTransactionLabe;
    }
    
    [self.storeMonthVisitTimeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.storeMonthVisitTimeLable.text.length>0? kView_Height - 3 : 0,self.storeMonthVisitTimeLable.text.length>0? kView_Height - 3 : 0));
    }];
    
    [self.storeMonthVisitTimeLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeMonthVisitTimeImgView.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.top.equalTo(self.storeMonthVisitTimeImgView.mas_top).offset(-2);
    }];
    
    if (self.storeMonthVisitTimeLable.text.length) {
        self.lastBottomView = self.storeMonthVisitTimeLable;
    }
    
    [self.storeListAcvtCodeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom);
        make.height.equalTo((kView_Height + 7) * acvtdisServiceArray.count);
    }];
    
    if (acvtdisServiceArray.count) {
        self.lastBottomView = self.storeMonthVisitTimeLable;
    }
    
    if (self.lastBottomView != self.addressLabel) {
        
        [self.lastBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(prepareStateBtnWidth > 5 ? self.prepareAndVisitStateBtn.mas_left : self.mas_right).offset(-labelSpace);
        }];
    }
    
    [self.loadTag mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
}

- (void)setIsChatVisible:(BOOL)isChatVisible {
    
    _isChatVisible = isChatVisible;
    self.chatImage.hidden = !isChatVisible;
}

- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt prepareFuncsBean:(WSFuncsBean *)funcBean prepareAcvtBean:(WSAcvtBean *)acvtBean {
    
    [self.contentView removeAllSubviews];
    
    if (opt.isChat && [opt.isChat isEqualToString:@"Y"]) {
        self.isChatVisible = YES;
    }
    else {
        self.isChatVisible = NO;
    }
    
    if ([opt.isGps isEqualToString:@"N"]) {
        self.isDistance = NO;
    }
    else {
        self.isDistance = YES;
    }
    self.isDistance = NO;
    
    if (opt.naviDis && opt.naviDis.length > 0) {
        NaviDisNum = [opt.naviDis integerValue];
    }
    else {
        NaviDisNum = 2;
    }
    if ([opt.isCode isEqualToString:@"0"]) {
        isHideCode = YES;
    }
    
    if (opt.storeListAcvtCode.length > 0) {
        _acvtCode = opt.storeListAcvtCode;
    }
    
    self.store = store;
    if (funcBean) {
        [self setPrepareStateWithPrepareFuncsBean:funcBean prepareAcvtBean:acvtBean];//设置准备状态
    }
    [self createSubviews];
    [self makeSubViewsConstraints];
}

- (void)setStore:(WSStoreBean *)store {
    
    if (_store != store) {
        _store = store;
    }
    
    if(store.isSelect) {
        userStoreSelect = YES;
    }

    self.lastBottomView = nil;

    if ((_store.distance.length> 0)&& !([_store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit", nil)].location != NSNotFound ||
                                        [_store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit_km", nil)].location != NSNotFound) ) {
        _store.distance = [WSLocationManager convertDistance:[_store.distance doubleValue]];
    }

    [self setStoreIcon];
    [self addChatImageAction];
    
    NSString *storeName = [WSNewTodayVisitAndAllStoreCell getStoreNameByStoreBean:_store];
    _storeNameLabel.text = storeName;

    if (!isHideCode) {
        _storeCodeLabel.text = _store.code;
    }
    
    [self setStoreAsattriView];
    
    _addressLabel.text = _store.addr;

    NSString *SRString = NSLocalizedString(@"last_man",nil);
    if (_store.last_man.length > 0) {
        self.storeLastmanLabel.text = [NSString stringWithFormat:@"%@:%@",SRString,_store.last_man];
    }

    if (_store.last_date.length > 0) {
        self.storeLastDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"last_date", nil),_store.last_date];
    }
    else {
        self.storeLastDateLabel.text = @"";
    }
    
    if (_store.last_transaction.length > 0) {
        self.storeLastTransactionLabe.text = [NSString stringWithFormat:NSLocalizedString(@"最近交易:%@", nil),_store.last_transaction];
    }

    NSString * qstName = [self.acvtService queryQstWithAcvtQstCode:@"last_num"].qstName;
    if (_store.store_month_visit_time.length > 0) {
        self.storeMonthVisitTimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%@:%@", nil),qstName,_store.store_month_visit_time];
    }

    if (_acvtCode) {
        [self addStoreListAcvtCodeView];
    }

    [self setVisitStatus];
    
    if (!userStoreSelect) {
        [self setStoreNavButton];
    }
}

+ (NSString *)getStoreNameByStoreBean:(WSStoreBean *)storeBean {
    
    NSString *storeName = storeBean.name;
    if ([storeBean.row_number length] > 0) {
        storeName = [NSString stringWithFormat:@"%@.%@",storeBean.row_number,storeBean.name];
    }
    return storeName;
}

- (void)setStoreIcon {
    
    if ([self.store.storeImg length] > 0) {
        
        if ([self.store.storeImg rangeOfString:@"."].location != NSNotFound) {
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.store.storeImg] imageView:_storeIcon placeholderImage:[UIImage imageNamed:@"shop_default@2x"]];
        }
        else {

            NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.store.storeImg];
            if (imagePathArray.count) {
                
                WSImagePathObject * object = [imagePathArray lastObject];
                if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                    NSString * url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:url] imageView:_storeIcon placeholderImage:[UIImage imageNamed:@"shop_default"]];
                }
                else {
                    
                    UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
                    if (image) {
                        _storeIcon.image = image;
                    }
                    else {
                        _storeIcon.image = [UIImage imageNamed:@"shop_default@2x"];
                    }
                }
            }
        }
    }
    else {
        
        NSString *local_image = [[WSInoutStoreTable sharedTable]getStoreLocalImageWithStore:self.store andOtherParam:nil andParamType:EParameterType_NULL];
        if (local_image && local_image.length >0 && ![local_image isEqualToString:@"null"]) {
            
            NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
            if (![isUsePhotos isEqualToString:@"2"]){
                UIImage *localImage =[[SDImageCache sharedImageCache]imageFromKey:local_image fromDisk:YES];
                _storeIcon.image = localImage;
            }
            else{
                _storeIcon.image = [UIImage imageNamed:@"shop_default@2x"];
            }
        }
        else {
            _storeIcon.image = [UIImage imageNamed:@"shop_default@2x"];
        }
    }
}

-(void)setStoreNavButton {
    
    if ([_store.distance length] > 0) {
        
        if (NaviDisNum % 2 == 0 &&  NaviDisNum != 0) {
            
            _store.distance = [self strChange:self.store.distance];
            [self.storeNavButton setTitle:self.store.distance forState:UIControlStateNormal];

            if ((NaviDisNum >> 2) % 2 == 1){
                
            }
            else {
                
                [self.storeNavButton setImage:[UIImage imageNamed:@"icon_distance"] forState:UIControlStateNormal];
                [self.storeNavButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (NSString *)strChange:(NSString *)str {
    
    NSRange range = [str rangeOfString:@"."];
    if (range.location != NSNotFound) {
        
        if (range.location == 1) {
            return str;
        }
        else {
            
            NSInteger num;
            NSString *unit;
            if (str.length>range.location+2)
            {
                num = [[str substringWithRange:NSMakeRange(0,range.location+2)] integerValue];
                unit = [str substringWithRange:NSMakeRange(range.location+2,str.length-range.location-2)];
                return [NSString stringWithFormat:@"%ld%@",num,unit];
            }
            return str;
        }
    }
    else {
        return str;
    }
}

-(void)setStoreAsattriView {
    
    [self.storeAsattriView removeAllSubviews];
    
    if ((self.store.attri && self.store.attri.length > 0) || (_store.plan || (_store.isRouteStore && ![_store.isRouteStore isEqualToString:@"0"]))) {
        
        if (_store.plan || (_store.isRouteStore && ![_store.isRouteStore isEqualToString:@"0"])) {
            
            self.visitPlanImgView.frame = CGRectMake(0, 0, kView_Height +5, kView_Height);
            [self.storeAsattriView addSubview:self.visitPlanImgView];
        }
        
        NSArray * storeImgs = [self.store.attri componentsSeparatedByString:@","];
        CGFloat imgX = 0;
        CGFloat scrollViewWidth = self.visitPlanImgView.frame.size.width;
        CGFloat space = 2.0f;
        
        for (int i = 0; i < storeImgs.count; i++) {
            
            imgX = (self.visitPlanImgView.frame.size.width ? (self.visitPlanImgView.frame.size.width+2):0) + i * (kView_Height +5) + (i) * space/*(kView_Space_Left - 2.5)*/;
            UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX  , 0, kView_Height + 5, kView_Height)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            NSString *imgURLStr = [WSHttpURLHelper getImageCompleteURL:storeImgs[i]];
            
            if ([imgURLStr hasSuffix:@"png"] || [imgURLStr hasSuffix:@"jpg"]) {
                [[WSRequestHelper shareInstance] downloadImageWithUrl:imgURLStr imageView:imgView];
            }
            else {
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", storeImgs[i]]];
            }
            scrollViewWidth = imgView.right;
            [self.storeAsattriView addSubview:imgView];
        }
        
        self.storeAsattriView.contentSize = CGSizeMake(scrollViewWidth, 0);
        storeAsattriViewWidth = scrollViewWidth;
    }
}

- (void)setVisitStatus {
    
    if (self.store.actionState.length) {
        
        UIColor *stateColor;
        UIImage * bgVisitStatusImg = [UIImage imageNamed:@""];
        NSString * visitStateTitle = @"";
        self.prepareAndVisitStateBtn.userInteractionEnabled = NO;
        
        if ([self.store.actionState isEqualToString:ActionDone]) {

            [self.prepareAndVisitStateBtn setTitle:@"" forState:UIControlStateNormal];
            prepareAndVisitStateBtnText = @"";
            stateColor  = K_STATUS_GRAY_COLOR;
            visitStateTitle = NSLocalizedString(@"planned_state", nil);
            bgVisitStatusImg =[UIImage imageNamed:@"bg_status_gray"];
        }
        else if ([self.store.actionState isEqualToString:ActionWorking]) {
            
                stateColor  = K_STATUS_YELLOW_COLOR;
                visitStateTitle = NSLocalizedString(@"planning_state", nil);
                bgVisitStatusImg =[UIImage imageNamed:@"bg_status_yellow"];
        }
        else if ([self.store.actionState isEqualToString:ActionNotStart] || self.store.actionState.length == 0) {
            
            stateColor  = [UIColor clearColor];
            visitStateTitle = @"";
            bgVisitStatusImg =[UIImage imageNamed:@""];
            _prepareAndVisitStateBtn.userInteractionEnabled = YES;
        }
        
        [self.prepareAndVisitStateBtn setTitleColor:stateColor forState:UIControlStateNormal];
        [self.prepareAndVisitStateBtn setBackgroundImage:bgVisitStatusImg forState:UIControlStateNormal];
        [self.prepareAndVisitStateBtn setTitle:visitStateTitle forState:UIControlStateNormal];
        prepareAndVisitStateBtnText = visitStateTitle;
    }
}

- (void)addStoreListAcvtCodeView {
    
    [self.storeListAcvtCodeView removeAllSubviews];
    [acvtdisServiceArray removeAllObjects];
    [acvtdisServiceArray addObjectsFromArray:[self.acvtdisService queryAcvtDisWithStoreId:_store.Id acvtCode:_acvtCode qstType:@"T"]];
    
    int i = 0;
    for (NSString *answer in acvtdisServiceArray) {
        
        UILabel *label = [[UILabel alloc]init];
        [self.storeListAcvtCodeView addSubview:label];
        label.frame = CGRectMake(0, i * ( kView_Height + 7), self.contentView.frame.size.width * 0.5, kView_Height);
        label.text = answer;
        label.textColor = CELL_DETAIL_TEXTCOLOR;
        label.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font10or15];
        i++;
    }
}

- (void)setPrepareStateWithPrepareFuncsBean:(WSFuncsBean *)funcBean prepareAcvtBean:(WSAcvtBean *)acvtBean {
    
    if ([self.store.state isEqualToString:@"0"]) {
        return;
    }

    WSNewStorePrepareState state = [WSNewStoreListTool getStorePrepareStateByStore:self.store withWSAcvtBean:acvtBean];
    self.prepareState = state;
    NSString *title = nil;
    if ([self.store.actionState isEqualToString:ActionNotStart]) {
        
        UIColor *stateColor = K_STATUS_GRAY_COLOR;
        if (state == WSStorePrepareStateNotPrepare) {
            
            title = NSLocalizedString( @"noalready_prepare", nil);
            [self.prepareAndVisitStateBtn setBackgroundImage:[UIImage imageNamed:@"bg_status_gray"] forState:UIControlStateNormal];
            [self.prepareAndVisitStateBtn setTitle:title forState:UIControlStateNormal];
            prepareAndVisitStateBtnText = title;
        }
        else if (state == WSStorePrepareStateReady) {
            
            if (![self.store.actionState isEqualToString:@"1"]) {
                
                if ([funcBean.iconOfDone length] > 0) {
                    
                    title = NSLocalizedString(@"already_prepare", nil);
                    stateColor = K_STATUS_LIME_COLOR;
                    [self.prepareAndVisitStateBtn setBackgroundImage:[UIImage imageNamed:@"bg_status_lime"] forState:UIControlStateNormal];
                }
                [self.prepareAndVisitStateBtn setTitle:title forState:UIControlStateNormal];
                prepareAndVisitStateBtnText = title;
            }
        }
        
        [self.prepareAndVisitStateBtn setTitleColor:stateColor forState:UIControlStateNormal];
    }
}

-(void)addChatImageAction {
    
    if (self.isChatVisible) {
        
        self.storeIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatButtonClick:)];
        singleFingerOne.numberOfTouchesRequired = 1;
        singleFingerOne.numberOfTapsRequired = 1;
        singleFingerOne.delegate = self;
        [self.storeIcon addGestureRecognizer:singleFingerOne];
    }
}

- (void)chatButtonClick:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatButtonPressDown:)]) {
        [self.delegate chatButtonPressDown:self.store];
    }
}

#pragma  mark - 导航按钮点击 应用跳转 到高地地图
- (void)navButtonClick:(UIButton *)button {
    
    if (self.store.latitude && self.store.longitude) {
        [WSTLAlertManager addMapNavigationCustomAlertViewWithStorebean:self.store];
    }
    else {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"无门店经纬度!", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
    }
}

-(void)readyprepareState {
    
    if ([_delegate respondsToSelector:@selector(storePrepareWith: withDate:)]) {
        [_delegate storePrepareWith:_store withDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    }
}

+ (CGFloat)heightForRowWithStore:(WSStoreBean *)store cellWidth:(CGFloat)cellWidth isHavePrepareButton:(BOOL)isHavePrepareButton withOpt:(WSFuncsBean_opt *)opt {
    
    CGFloat height = kViewForStoreList_Space_Top;
    CGFloat textWidthRatio;
    CGFloat storeAddressWidth;
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    
    if ([isUsePhotos isEqualToString:@"0"]) {
        textWidthRatio = INTERFACE_IS_PHONE ? 0.77 : 0.8;
        storeAddressWidth = cellWidth - kView_Space_Left - (kView_Height - 3) - 7 -kView_Space_Left;
    }
    else {
        textWidthRatio = INTERFACE_IS_PHONE ? 0.42 : 0.65;
        storeAddressWidth = cellWidth - kView_Space_Left - storeIconWidth - kView_Space_StoreName_Icon_Left - (kView_Height - 3) - 7 - kView_Space_Left;
    }
    
    CGFloat width = textWidthRatio * cellWidth;
    CGFloat storeNameWidth = width;
    // 没有距离的时候，门店名称的宽度需要改变
    if (store.distance.length == 0 && INTERFACE_IS_PHONE) {
        storeNameWidth = (textWidthRatio + 0.25) * cellWidth;
    }

    height += 22;
    height += 7;
    
    if (![opt.isCode isEqualToString:@"0"]) {
        height += kView_Height;
        height += 7;
    }
    
    CGFloat addrFontSize = INTERFACE_IS_PAD ? UI_SubViewForStoreList_Font13or15:UI_SubViewForStoreList_Font13or15;

    if (store.addr.length > 0) {
        height += kView_Height;
        height += 7;
    }
    
    if ([store.last_man length] > 0) {
        height += kView_Height;
        height += 7;
    }
    
    if ([store.last_date length] > 0) {
        height += kView_Height;
        height += 7;
    }
    
    if ([store.last_transaction length] > 0) {
        height += kView_Height;
        height += 7;
    }
    
    if ([store.store_month_visit_time length] > 0) {
        height += kView_Height;
        height += 7;
    }

    if (opt.storeListAcvtCode) {
        NSArray * array = [[[WSBaseAcvtdisDBService alloc]init] queryAcvtDisWithStoreId:store.Id acvtCode:opt.storeListAcvtCode qstType:@"T"];
        height += (array.count * kView_Height + 7);
        height += 7;
    }
    
    if ([store.visitcontent length] > 0) {
        CGSize size = [store.visitcontent stringSizeWithFont:[UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15] width: cellWidth -3*kView_Space_Left - 6];
        height += size.height + 2 *KLittleGap +  kViewForStoreList_Space_Top;
        
        if (height < storeIconWidth + kViewForStoreList_Space_Top*2) {
            return storeIconWidth + kViewForStoreList_Space_Top*3 + size.height + 2 *KLittleGap;
        }
    }

    if (height < 90) {
        height = 90;
    }
    
    return height;
}

- (UIImageView *)storeSelect {
    
    if (!_storeSelect) {
        
        _storeSelect = [[UIImageView alloc] init];
        _storeSelect.image = [UIImage imageForName:@"selected_no_radio@2x"];
    }
    return _storeSelect;
}

- (UIImageView *)storeIcon {
    
    if (!_storeIcon) {
        
        _storeIcon = [[UIImageView alloc] init];
        _storeIcon.image = [UIImage imageForName:@"shop_default@2x"];
        _storeIcon.layer.cornerRadius = 52/2;
        _storeIcon.clipsToBounds = YES;
    }
    return _storeIcon;
}

- (UILabel *)storeNameLabel {
    
    if (!_storeNameLabel) {
        
        _storeNameLabel = [[UILabel alloc] init];
        _storeNameLabel.font = ALL_STORE_CELL_FONT;
        _storeNameLabel.numberOfLines = 1;
        _storeNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _storeNameLabel.textColor = MAIN_TEXT_COLOR;
    }
    return _storeNameLabel;
}

- (UIImageView *)storeCodeImg {
    
    if (!_storeCodeImg) {
        
        _storeCodeImg = [[UIImageView alloc] init];
        _storeCodeImg.image = [UIImage imageNamed:@"info_bianma_icon"];
    }
    return _storeCodeImg;
}

- (UILabel *)storeCodeLabel {
    
    if (!_storeCodeLabel) {
        
        _storeCodeLabel = [[UILabel alloc] init];
        _storeCodeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeCodeLabel.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15];
    }
    return _storeCodeLabel;
}

- (UIScrollView *)storeAsattriView {
    
    if (!_storeAsattriView) {
        
        _storeAsattriView = [[UIScrollView alloc] init];
        _storeAsattriView.userInteractionEnabled = NO;

    }
    return _storeAsattriView;
}

- (UIImageView *)addressImg {
    
    if (!_addressImg) {
        
        _addressImg = [[UIImageView alloc] init];
        _addressImg.image = [UIImage imageNamed:@"info_dizhi_icon"];
    }
    return _addressImg;
}

- (UILabel *)addressLabel {
    
    if (!_addressLabel) {
        
        _addressLabel = [[UILabel alloc] init];
        CGFloat fontSize = INTERFACE_IS_PAD ? UI_SubViewForStoreList_Font13or15:UI_SubViewForStoreList_Font13or15;
        _addressLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        _addressLabel.font = [UIFont systemFontOfSize:fontSize];
        _addressLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _addressLabel;
}

- (UIImageView *)storeLastmanView {
    
    if (!_storeLastmanView) {
        
        _storeLastmanView = [[UIImageView alloc] init];
        _storeLastmanView.image = [UIImage imageNamed:@"icon_person"];
    }
    return _storeLastmanView;
}

- (UILabel *)storeLastmanLabel {
    
    if (!_storeLastmanLabel) {
        
        _storeLastmanLabel = [[UILabel alloc] init];
        _storeLastmanLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeLastmanLabel.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15];
    }
    return _storeLastmanLabel;
}

- (UIImageView *)lastDateImgView {
    
    if (!_lastDateImgView) {
        
        _lastDateImgView = [[UIImageView alloc] init];
        _lastDateImgView.image = [UIImage imageNamed:@"info_date_icon"];
    }
    return _lastDateImgView;
}

- (UILabel *)storeLastDateLabel {
    
    if (!_storeLastDateLabel) {
        
        _storeLastDateLabel = [[UILabel alloc] init];
        _storeLastDateLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeLastDateLabel.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15];
    }
    return _storeLastDateLabel;
}

- (UIImageView *)storeLastTransactionImgView {
    
    if (!_storeLastTransactionImgView) {
        
        _storeLastTransactionImgView = [[UIImageView alloc] init];
        _storeLastTransactionImgView.image = [UIImage imageNamed:@"info_date_icon"];
    }
    return _storeLastTransactionImgView;
}

- (UILabel *)storeLastTransactionLabe {
    
    if (!_storeLastTransactionLabe) {
        
        _storeLastTransactionLabe = [[UILabel alloc] init];
        _storeLastTransactionLabe.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeLastTransactionLabe.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15];
    }
    return _storeLastTransactionLabe;
}

- (UIImageView *)storeMonthVisitTimeImgView {
    
    if (!_storeMonthVisitTimeImgView) {
        
        _storeMonthVisitTimeImgView = [[UIImageView alloc] init];
        _storeMonthVisitTimeImgView.image = [UIImage imageNamed:@"icon_tag_grey"];
    }
    return _storeMonthVisitTimeImgView;
}

- (UILabel *)storeMonthVisitTimeLable {
    
    if (!_storeMonthVisitTimeLable) {
        
        _storeMonthVisitTimeLable = [[UILabel alloc] init];
        _storeMonthVisitTimeLable.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeMonthVisitTimeLable.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15];
    }
    return _storeMonthVisitTimeLable;
}

- (UIButton *)storeNavButton {
    
    if (!_storeNavButton) {
        
        _storeNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _storeNavButton.titleLabel.font = [UIFont systemFontOfSize:UI_SubViewForStoreList_Font13or15 -2];
        [_storeNavButton setTitleColor:CELL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        _storeNavButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    }
    return _storeNavButton;
}

- (UIImageView *)chatImage {
    
    if (!_chatImage) {
        
        _chatImage = [[UIImageView alloc] init];
        _chatImage.image = [UIImage imageNamed:@"ltfqan"];
        _chatImage.contentMode = UIViewContentModeLeft;
    }
    return _chatImage;
}

- (UIImageView *)visitPlanImgView {
    
    if (!_visitPlanImgView) {
        
        _visitPlanImgView = [[UIImageView alloc] init];
        _visitPlanImgView.image = [UIImage imageNamed:@"point_plan_icon"];//内
    }
    return _visitPlanImgView;
}

- (UIButton *)prepareAndVisitStateBtn {
    
    if (!_prepareAndVisitStateBtn) {
        
        _prepareAndVisitStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _prepareAndVisitStateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -8);
        _prepareAndVisitStateBtn.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font10or15 - 1.0];
        [_prepareAndVisitStateBtn addTarget:self action:@selector(readyprepareState) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prepareAndVisitStateBtn;
}

- (UIView *)storeListAcvtCodeView {
    
    if (!_storeListAcvtCodeView) {
        
        _storeListAcvtCodeView = [[UIView alloc] init];
    }
    return _storeListAcvtCodeView;
}

- (WSBaseAcvtDBService *)acvtService {
    
    if (!_acvtService) {
        
        _acvtService = [[WSBaseAcvtDBService alloc] init];
    }
    return _acvtService;
}

- (UIImageView *)loadTag {
    
    if (!_loadTag) {
        
        _loadTag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hasDownload"]];
    }
    return _loadTag;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

@end
