//
//  WSSelectStorePanel.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/19.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSSelectStorePanel.h"
#import "I_M_View.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "WSStoreManageSearchViewController.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "WSAddStoreView.h"
#import "WSStoresSearchDataModel.h"
#import "I_W_DisplayValue.h"
#import "YYModel.h"

@interface WSSelectStorePanel ()<WSStoreManageSearchViewControllerDelegate,WSAddStoreViewDelegate>

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) WSAddStoreView *addView;
@property (nonatomic, strong) WSStoresSearchDataInfoModel *dataInfoModel;

@end

@implementation WSSelectStorePanel

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        return self;
    }
    return nil;
}

- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    CGFloat y = self.titleLabel.frame.size.height;

    self.addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addButton.frame = CGRectMake(0, y, self.width, 85);
    [self.addButton setTitle:@"添加客户" forState:UIControlStateNormal];
    [self.addButton setTitle:@"添加客户" forState:UIControlStateSelected];
    self.addButton.tintColor = MAIN_TINT_COLOT;
    self.addButton.titleLabel.tintColor = MAIN_TINT_COLOT;
    [self.addButton addTarget:self action:@selector(addBtnDown) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];
    
    self.addView = [[WSAddStoreView alloc] init];
    self.addView.frame = CGRectMake(0, y, self.width, 85);
    self.addView.hidden = YES;
    self.addView.addStoreViewDelegate = self;
    [self addSubview:self.addView];
    
    NSString *l_dis = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];

    if (l_dis && l_dis.length > 0) {
        NSDictionary *dic = (NSDictionary*)[l_dis objectFromJSONString];
        WSStoresSearchDataInfoModel *dataModel =  [WSStoresSearchDataInfoModel yy_modelWithDictionary:dic];
        [self sotreDataInfoModel:dataModel];
    }
    
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds),  85 + y)];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat y = self.titleLabel.frame.size.height;
    self.addView.frame = CGRectMake(0, y, self.width, 85);
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds),  85 + y)];
}

- (void)addBtnDown {
    
    WSInterAction *interaction = [[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    WSStoreManageSearchViewController *searchManage = [[WSStoreManageSearchViewController alloc] init];
    searchManage.currentFuncs = model.currentFuncs;
    searchManage.currentAcvt = model.currentAcvtBean;
    searchManage.hidesBottomBarWhenPushed = YES;
    searchManage.storeManageDelegate = self;
    [interaction setExecute_controller:searchManage];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

- (void)sotreDataInfoModel:(WSStoresSearchDataInfoModel*)storesSearchDataInfoModel {
    
    self.addView.hidden = NO;
    self.addButton.hidden = YES;
    self.dataInfoModel = storesSearchDataInfoModel;
    [self.addView setWithCode:storesSearchDataInfoModel.code andName:storesSearchDataInfoModel.name andAddr:storesSearchDataInfoModel.addr];
    
    if ([xbuildInfo getLuaScript]!=nil && [[xbuildInfo getLuaScript] length] > 0) {
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            
            _resultCheck = [NSString stringWithFormat:@"%@@#%@@#%@@#%@",
                            [NSString stringNotNilWithValue:@(storesSearchDataInfoModel.storeId)],
                            [NSString stringNotNilWithValue:storesSearchDataInfoModel.name],
                            [NSString stringNotNilWithValue:storesSearchDataInfoModel.code],
                            [NSString stringNotNilWithValue: storesSearchDataInfoModel.addr]];
            [delegate executeLuaScript:xbuildInfo script:[xbuildInfo getLuaScript] funcName:@"function onChange(" widget:self];
        }
    }
}

- (void)deleteStore {
    
    self.dataInfoModel = nil;
    self.addView.hidden = YES;
    self.addButton.hidden = NO;
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    if (!valuePresentation || [valuePresentation length] == 0) {
        self.dataInfoModel = nil;
        self.addView.hidden = YES;
        self.addButton.hidden = NO;
    }
}

- (NSObject *)getCurrentValuePresentation {
    
    return [NSString stringNotNilWithValue:@(self.dataInfoModel.storeId)];
}

- (NSObject *)getResultDirectly {
    
    if (self.dataInfoModel) {
        
        return [@{@"id" : [NSString stringNotNilWithValue:@(self.dataInfoModel.storeId)],
                  @"name" : [NSString stringNotNilWithValue:self.dataInfoModel.name],
                  @"code" : [NSString stringNotNilWithValue:self.dataInfoModel.code],
                  @"addr" : [NSString stringNotNilWithValue:self.dataInfoModel.addr]} JSONString];
    }
    return nil;
}

- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

@end
