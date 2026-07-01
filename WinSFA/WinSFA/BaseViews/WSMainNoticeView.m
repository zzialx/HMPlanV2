//
//  WSMainNoticeView.m
//  WinSFA
//
//  Created by Alicia on 2017/3/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMainNoticeView.h"
#import "WSFuncsBean.h"
#import "WSBaseStoreDBService.h"
#import "WSWorkFlowViewController.h"
#import "WSSubempstoreBeanArray.h"
#define kFC_TAB_V2001   @"TAB_V2001"

@interface WSMainNoticeView ()

@property (nonatomic, strong) UIImageView *noticeImageView;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) WSInoutStoreObject *store;
@property (nonatomic, strong) WSSubempstoreBean *subempStore;

@end

@implementation WSMainNoticeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIColor *textColor = [UIColor colorForKey:@"MainNoticeBackgroudColor"] ? [UIColor colorForKey:@"MainNoticeBackgroudColor"]  : MAIN_TINT_COLOR;
    UIColor *bgColor = [UIColor colorForKey:@"MainNoticeTextColor"] ? [UIColor colorForKey:@"MainNoticeTextColor"]  : [textColor colorWithAlphaComponent:0.2];
    [self setBackgroundColor:bgColor];
    
    UIImageView *noticeImageView = [[UIImageView alloc] init];
    UIImage *noticeImage = [[UIImage imageNamed:@"message_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    noticeImageView.image = noticeImage;
    noticeImageView.tintColor = textColor;
    [self addSubview:noticeImageView];
    self.noticeImageView = noticeImageView;
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    [noticeLabel setTextColor:textColor];
    [noticeLabel setFont:[UIFont systemFontOfSize:12]];
    [self addSubview:noticeLabel];
    self.noticeLabel = noticeLabel;
    
    [self setHidden:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageWH = 20;
    self.noticeImageView.frame = CGRectMake(MAIN_PADDING, (self.height - imageWH) / 2, imageWH, imageWH);
    
    CGFloat leftPadding = CGRectGetMaxX(self.noticeImageView.frame) + MAIN_PADDING / 2;
    self.noticeLabel.frame = CGRectMake(leftPadding, 0, self.width - leftPadding - MAIN_PADDING , self.height);
}

#pragma mark - Public Method
- (void)setNotLeaveStore:(WSInoutStoreObject *)store {
    self.store = store;
    
    NSString *tips = NSLocalizedString(@"未离开，请先离开，谢谢", nil);
    NSString *notice = [NSString stringWithFormat:@"%@%@", store.memo1, tips];
    [self.noticeLabel setText:notice];
}

#pragma mark - Actions
- (void)viewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    if ([self.store.sr_id length] > 0 && ![self.store.sr_id isEqualToString:@"null"]) {
        empId = self.store.sr_id;
    }
    
    NSArray *storesArray  = [storeService queryStoreWithId:self.store.store_id andEmpId:empId];
    WSStoreBean *storeBean = [storesArray firstObject];
    storeBean.plan = [self.store.is_planed isEqualToString:@"1"] ? YES : NO;
    
    //判断是否是随访的店
    if (![storeBean.empId isEqualToString:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]]) {
        WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:SUBEMPSTORES];
        self.subempStore = [subBeanArr getSubempstoreById:storeBean.empId];
    }

    [self goNextWorkView:storeBean];
}


- (void)goNextWorkView:(WSStoreBean *)storeBean {
    NSString *modulefc = self.store.modulefc;
    
    WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
    
    WSFuncsBean *currectFunc = [fba getFuncsBeanWithFC:modulefc];
    if (!currectFunc) {
        LogError(@"Can not find the current func");
        return;
    }
    if (![currectFunc.fv isEqualToString:kFC_TAB_V2001] && currectFunc.funcsArray && currectFunc.funcsArray.count > 0) {
        WSFuncsBean *nextFuncsBean = currectFunc.funcsArray[0];
        if ([nextFuncsBean.fv isEqualToString:FV_TAB_V21001]) {
            currectFunc = currectFunc.funcsArray[0];
        }
    }
    
    //设置访问节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.store_id = self.store.store_id;
    action.func_code = self.store.func_code;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = currectFunc.name;
    
    action.module_fc =  modulefc;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    WSWorkFlowViewController *wfvc = nil;
    if (self.subempStore && [self.subempStore.Id length] > 0) {
       wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:currectFunc Store:storeBean subEmpStore:self.subempStore];
    }else{
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:currectFunc Store:storeBean];
    }
    
    wfvc.title = self.store.memo1;
    wfvc.currentVisitAction = action;
    wfvc.moduleFC = action.module_fc;
    
    [[[self viewController] navigationController] pushViewController:wfvc animated:YES];
}

@end
