//
//  WS NewAddAcvtViewController.m
//  WinSFA
//
//  Created by heju on 14-4-10.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSNewAddAcvtViewController.h"
#import "WSAcvtModel.h"
#import "WSEnvrionment.h"
#import "WSAddNewAcvtModel.h"
#import "WSDataSourceManager.h"

@interface WSNewAddAcvtViewController ()

@end

@implementation WSNewAddAcvtViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store md5:(NSString *)acvtMd5 withReplayDic:(NSMutableDictionary*)dic
{
    if(anAcvt==nil)
        return nil;
    // MSTD-5834 修复只读页面表格滑动表头不冻结的问题（其实为WSNewAddAcvtViewController页面初始化未调用父类WSAcvtViewController的初始化方法，导致未初始化_acvtDataGridViewPanelsMArray）
//    self = [super initWithFuncs:funcs];
    self = [super initWithAcvt:anAcvt Funcs:funcs Store:store];
    if(self != nil)
    {
        if (!acvtMd5) {
            self.isNewAddAcvt = YES;
        }
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.replayDic = dic;
        self.md5 = acvtMd5;
        self.updateGenID = acvtMd5;
        
        [self initAcvtModel];
        
        return self;
    }
    
    return nil;
}


-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore newStoreAcvtInfos:(NSArray *)acvtInfos md5:(NSString *)acvtMd5{
    
    if(anAcvt==nil)
        return nil;
    
//    self = [super initWithFuncs:funcs];
    self = [super initWithAcvt:anAcvt Funcs:funcs Store:store acvtNewStore:acvtNewStore];

    if(self != nil)
    {
        if (!acvtMd5) {
            self.isNewAddAcvt = YES;
        }
        
        self.m_currentAcvt = anAcvt;
        self.currentStore = store;
        self.currentNewStore = acvtNewStore;
        self.acvtNewStoreQstInfos = acvtInfos;
        self.md5 = acvtMd5;
        self.updateGenID = acvtMd5;
        
        [self initAcvtModel];
        
        return self;
    }
    return nil;
}

- (void) initAcvtModel
{
    [super initAcvtModel];
    self.model.md5 = self.md5;
    ((WSAddNewAcvtModel *)self.model).acvtNewStoreQstInfos  = self.acvtNewStoreQstInfos;
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    model.currentNewStore = self.currentNewStore;
}

- (void)createModel {
    self.model = [[WSAddNewAcvtModel alloc] init];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isNewAddAcvt && [self.currentFuncs.unredo integerValue] == 1) {
        if(self.m_ParentViewController != nil) {
            self.m_ParentViewController.navigationItem.rightBarButtonItem = nil;
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}


@end
