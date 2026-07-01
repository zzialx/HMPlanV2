
//
//  NewStoreListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSNewStoreListViewController.h"
#import "WSAcvtBean.h"
#import "WSAcvtViewController.h"
#import "WSAddStoreTable.h"
#import "WSAddNewStoreViewController.h"
#import "WCOptionalSource.h"
#import "WSFuncsBeanArray.h"
#import "WSNewStoreVisitViewController.h"
#import "WinSFA.h"
#import "WSAcvtBean_qst.h"
#import "WSRequestHelper.h"
#import "WSAddStoreQstTable.h"
#import "WSStoreInfoTableViewCell.h"
#import "WSSmsController.h"
#import "WSAcvtBean_qst_opt.h"

#import "WSAcvtDisBean.h"
#import "WSAppDelegate.h"
#import "WSLocationArray.h"
#import "WSLocationSelectViewController.h"
#import "WSDictTable.h"
#import "WSBaseDictsTable.h"
#import "WSNavigationBar.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtListDataItem.h"
#import "WSAcvtQstDisItem.h"
#import "WSBaseSmsDataTable.h"
#import "WSSMSSendView.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseAcvtDBService.h"
#import "WSJSONBuilder.h"

#define kRedisPCount 3
#define k_Remote_Notify @"remoteSearch"
#define k_SearchHeaderViewDefaultHeight 44.0f
#define k_AddedHeight 26
#define LeftBarWidth 80.0


@interface WSNewStoreListViewController () <WSSmsControllerDelegate>
{
   

}


@property (nonatomic, assign) BOOL visitImmediately;

@property (nonatomic, strong) NSArray *filterAcvtdisArray;
@property (nonatomic, strong) NSMutableArray *searchedQsts;


@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong)UIButton *checkedAllButton;
@property (nonatomic, strong)UIButton *smsButton;
@property (nonatomic, assign)BOOL isCheckedALL;
@property (nonatomic, assign)NSInteger checkedAllNum;
//@property (nonatomic, strong)NSArray *storesExtendedInfo;

@property (nonatomic, strong)WSSmsController *smsController;
@property (nonatomic, strong) WSAcvtModel *currentDeleteAcvtModel;
@property (nonatomic, copy) NSString *notifyID;

@end

@implementation WSNewStoreListViewController

@synthesize addStoreStyle = _addStoreStyle;
@synthesize currentSearchType = _currentSearchType;

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean {
    self = [super initWithFuncs:aFuncsBean];
    if (self) {
        if (self.currentFuncs.submenu) {
            _visitImmediately = YES;
        }
    }
    return self;
}

-(void)receiveNewStore:(id)sender
{
    self.needRefresh = @"1";
    [self refreshData];
}

- (void)doRefreshData
{
    LogTrace();
    [self refreshData];
    self.needRefresh = @"1";
    if (!self.isCalenderPattern)
    [self createHeaderSearchView];
}

#pragma mark - View lifecycle


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:modifyStoreNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNewStore:) name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshData) name:modifyStoreNotification object:nil];

    self.selectedArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    if([self.currentFuncs.filter isEqualToString:@"dc_dnh&kdh_ZX"]){
        self.showActionTip = YES;
    }
    
    if ([self.currentFuncs.opt.isShowActionTip isEqualToString:@"Y"]) {
        self.showActionTip = YES;
    }
    
    if (self.currentFuncs.opt.isAcvtListCanDelete.length > 0 && ([self.currentFuncs.opt.isAcvtListCanDelete isEqualToString:@"1"] || [self.currentFuncs.opt.isAcvtListCanDelete isEqualToString:@"true"])) {
        [self.tableView setEditing:NO];
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
    }
    
    if (!self.isCalenderPattern)
        [self createSubView];
    
    self.isFirstLoad = YES;

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //SFA-25115
    
//    [MBProgressHUD showHUDAddedTo:self.view withText:NSLocalizedString(@"加载中…", nil) tips:nil tapTarget:self action:nil type:MBProgressHUDMessageTypeWaiting autoHideTime:0.2];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.needRefresh = nil;
}
-(void)subclassReloadData{
    [self reloadData];
    if (self.isFirstLoad) {
        if (!self.isCalenderPattern)
            [self autoJumpToNextViewController]; //MN-1863_2018-04-19 逻辑统一挪到WSBaseNewAcvtListViewController
    }
    else
    {
        if(self.dataArray.count == 0  && !self.isPageSegmentView &&
           ([self.currentFuncs.buttonName isKindOfClass:[NSString class]] && [self.currentFuncs.buttonName length] > 0 && [self.addAcvtArray count] == 1) &&
           !self.hasSegment && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"])
            [self.navigationController popViewControllerAnimated:YES];
    }

    self.isFirstLoad = NO;
}
//// MENGNIU-1468 判定是否是实时请求数据，如果是则在请求完成之后再进行自动跳转的动作
//- (void)autoJumpToNextViewController
//{
//    if(self.dataArray.count == 0 && !self.isPageSegmentView &&
//       ([self.currentFuncs.buttonName isKindOfClass:[NSString class]] && [self.currentFuncs.buttonName length] > 0 && [self.addAcvtArray count] == 1) &&
//       !self.hasSegment && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"]){
//
//        [self performSelector:@selector(addNewAcvt:) withObject:nil afterDelay:0.1];
//    }
//}

/*根据数据创建子视图*/
- (void)createSubView{
    
    CGFloat y = 0;
    if (self.currentFuncs.opt.isSearchable.length > 0) {
        [self createHeaderSearchView];
    }
    
    y = CGRectGetHeight(self.headerSearchView.frame);
    
    //加载 SMS短信沟通功能以及相关视图
    if ([self isValidSMSNode]) {
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.frame), 30)];
        middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
        editButton.frame = CGRectMake(15., 0, 95, 30.);
        [editButton setTitle:NSLocalizedString(@"chat_mode", nil) forState:UIControlStateNormal];
       [editButton setTitleColor:[UIColor colorWithHexString:@"#3983f8"] forState:UIControlStateNormal];
        editButton.titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(15);
        editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [editButton addTarget:self action:@selector(openOrCloseCheckedButton:) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:editButton];
        
        self.checkedAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.checkedAllButton.frame = CGRectMake(CGRectGetMaxX(editButton.frame) + 12.0, 0, 65., 30.);
        [self.checkedAllButton setTitleColor:[UIColor colorWithHexString:@"#3983f8"] forState:UIControlStateNormal];
        [self.checkedAllButton setTitleColor:[UIColor colorWithHexString:@"#d5d5d5"] forState:UIControlStateDisabled];
        self.checkedAllButton.titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(15);
        [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil)  forState:UIControlStateNormal];
        [self.checkedAllButton addTarget:self action:@selector(checkedAll:) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:self.checkedAllButton];
        [self.checkedAllButton setEnabled:NO];
        
        self.smsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.smsButton.frame = CGRectMake(CGRectGetWidth(middleView.frame) - 60. , 0, 60., 30.);
        [self.smsButton setTitleColor:[UIColor colorWithHexString:@"#3983f8"] forState:UIControlStateNormal];
        [self.smsButton setTitleColor:[UIColor colorWithHexString:@"#d5d5d5"] forState:UIControlStateDisabled];
        self.smsButton.titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(15);
        [self.smsButton setTitle:self.currentFuncs.opt.SMS forState:UIControlStateNormal];
        [self.smsButton setEnabled:NO];
        [self.smsButton addTarget:self action:@selector(pushSMSController:) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:self.smsButton];
        self.isCheckedALL = NO;
        self.checkedAllNum=0;
        [self.view addSubview:middleView];
        y = y + CGRectGetHeight(middleView.frame);
        
    }
    
    self.tableView.frame = CGRectMake(0,y, self.view.width,self.view.height - y);

}


#pragma  mark - action
- (void) pushSMSController:(id)sender
{
 
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (WSAcvtListDataItem* item in self.dataArray) {
        if (item.isChecked) {
            NSString* phoneNumber = [self phoneNumberForItem:item];
            if (phoneNumber) {
                [phones addObject:phoneNumber];
            }
        }
    }
    if (phones.count > 0) {
        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIView *rootView = delegate.window.rootViewController.view;
        WSSMSSendView * sendView = [[WSSMSSendView alloc]initWithFrame:rootView.bounds phones:[phones componentsJoinedByString:@","]];
        [rootView addSubview:sendView];
        
        sendView.top = 1000;
        
        [UIView animateWithDuration:0.5 animations:^{
            sendView.top = 0;
            [sendView selectAllPhone];
        } completion:^(BOOL finished) {
            
        }];
        
        
        
        sendView.sendSMS =^(NSString * detail,NSArray * phones){
            
            if ([phones count] > 0) {
                self.smsController= [[WSSmsController alloc] initWithDelegate:self withParentVC:self];
                [self.smsController presentSMSPageWithPhones:phones withContent:detail withIscanned:NO];
            }else{
                NSString *alterString = NSLocalizedString(@"please_select_phone", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            
        };
    }else{
        NSString *alterString = NSLocalizedString(@"please_select_phone", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
  
//    if ([phones count] > 0) {
//        self.smsController= [[WSSmsController alloc] initWithDelegate:self withParentVC:self];
//        [self.smsController presentSMSPageWithPhones:phones withContent:@"" withIscanned:NO];
//    }else{
//        NSString *alterString = NSLocalizedString(@"please_select_phone", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }
    
}

- (void) openOrCloseCheckedButton: (UIButton *)sender
{
    if (self.tableView.editing) {
        
        self.tableView.editing = NO;
        [sender setTitle:NSLocalizedString(@"chat_mode", nil) forState:UIControlStateNormal];
        [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil) forState:UIControlStateNormal];
        [self.smsButton setEnabled:NO];
        [self.checkedAllButton setEnabled:NO];
        self.isCheckedALL = NO;
        NSArray * array = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath * indexPath in array) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        for (WSAcvtListDataItem* item in self.dataArray) {
            item.isChecked = NO;
        }
    }else{
        self.tableView.editing = YES;
        [sender setTitle:NSLocalizedString(@"cancel_chat_mode", nil) forState:UIControlStateNormal];
        [self.smsButton setEnabled:YES];
        [self.checkedAllButton setEnabled:YES];
    }
    [self updateSMSButtonTitle];

}
- (void) checkedAll:(id)sender
{
    if ([self  isValidSMSNode]) {
        if (self.isCheckedALL) {
            [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil) forState:UIControlStateNormal];
            self.isCheckedALL = NO;
            NSArray * array = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath * indexPath in array) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            for (WSAcvtListDataItem* item in self.dataArray) {
                item.isChecked = NO;
            }
        }else{
            self.isCheckedALL = YES;
            self.checkedAllNum=0;
            for (WSAcvtListDataItem* item in self.dataArray) {
                BOOL allowChecked = NO;
                NSString* phoneNumber = [self phoneNumberForItem:item];
                if (phoneNumber) {
                    allowChecked = YES;
                }
                if (allowChecked) {
                    item.isChecked = YES;
                    self.checkedAllNum++;
                }else{
                    item.isChecked = NO;
                }
            }
            
            NSArray * array = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath * indexPath in array) {
                WSAcvtListDataItem *acvtItem = [self.dataArray objectAtIndex:indexPath.row];
                if (acvtItem.isChecked) {
                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }else{
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                }
                
            }
            [self.checkedAllButton setTitle:NSLocalizedString(@"check_all_cancel", nil) forState:UIControlStateNormal];
            
        }
        [self updateSMSButtonTitle];
    }

}

- (void)addDutyPlanNewAcvt:(WSAcvtBean *)acvtBean {
    [self showAcvtViewController:acvtBean];
}


- (void)showAcvtViewController:(WSAcvtBean *)acvtBean
{
    WSAddNewStoreViewController *l_newStoreVC = [[WSAddNewStoreViewController alloc] initWithFuncs:self.currentFuncs acvtBean:acvtBean storeBean:self.currentStore];
    l_newStoreVC.title = ((acvtBean.acvtName.length > 0) ? acvtBean.acvtName : l_newStoreVC.title);//MMSH-3888 2018-03-26
    
    if (!l_newStoreVC.currentVisitAction) {
        l_newStoreVC.currentVisitAction = self.currentVisitAction;
    }
    LogInfo(@"Go into class WSAddNewStoreViewController");
    
    if (INTERFACE_IS_PAD) {
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:l_newStoreVC];
        [l_newStoreVC leftItemImage:@"icon_back" target:l_newStoreVC action:@selector(backAction)];
        
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        
        l_newStoreVC.hidesBottomBarWhenPushed = YES;
        
        if(self.ownParentViewController)
        {
            [self.ownParentViewController.navigationController pushViewController:l_newStoreVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:l_newStoreVC animated:YES];
        }
    }
    
}


// 删除门店成功时候重新加载数据
- (void)deleteStoreSucceed:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteNewAddStoreSucceed object:nil];
    
    NSString *deleteStoreMd5 = [[notification userInfo] objectForKey:DelteStoreMD5_Key];
    if (self.dataArray) {
        NSPredicate* pre = [NSPredicate predicateWithFormat:@"self.genID!=%@",deleteStoreMd5];
        NSArray *filterArray = [self.dataArray filteredArrayUsingPredicate:pre];
        self.dataArray = [NSMutableArray arrayWithArray:filterArray];
        
        [self.tableView reloadData];
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count <= 0)
        return;
    
    if (tableView.isEditing) {
        self.isCheckedALL = NO;
        if (indexPath.row < [self.dataArray count] && [self isValidSMSNode]) {
            WSAcvtListDataItem *item = [self.dataArray objectAtIndex:indexPath.row];
            item.isChecked = NO;
            [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil) forState:UIControlStateNormal];
            [self updateSMSButtonTitle];
        }
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count <= 0)
        return;
    
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
        // 是否立即拜访
        if (!_visitImmediately) {
            [self editIndexPath:indexPath];
        } else {
            WSAcvtListDataItem *item = [self.dataArray objectAtIndex:indexPath.row];
            if (item) {
                WSNewStoreVisitViewController *nsvc = [[WSNewStoreVisitViewController alloc] initWithFuncs:self.currentFuncs acvtListItem:item];
                nsvc.currentStore = self.currentStore;
                LogInfo(@"Going to class WSNewStoreVisitViewController");
                if (self.ownParentViewController.navigationController) {
                    [self.ownParentViewController.navigationController pushViewController:nsvc animated:YES];
                } else if (self.navigationController) {
                    [self.navigationController pushViewController:nsvc animated:YES];
                }
            }
        }
    }else{
        if (indexPath.row < [self.dataArray count] && [self  isValidSMSNode]) {
                WSAcvtListDataItem *item = [self.dataArray objectAtIndex:indexPath.row];
                NSString *phoneNumber = [self phoneNumberForItem:item];
                if (phoneNumber) {
                    item.isChecked = YES;
                    [self updateSMSButtonTitle];
                }else{
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    NSString *alterString = NSLocalizedString(@"need_input_mobile", nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:alterString,item.mainTitle] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
                }
            
        }
    
    }
}

- (void)editIndexPath:(NSIndexPath *)indexPath {
    if ([self.addStoreStyle isEqualToString:@"sp_style"])
    {

    } else {
        
        WSAcvtListDataItem *item = self.dataArray[indexPath.row];
        
//        WSAddStoreObject* addStore = nil;//[self.addNewAcvtList objectAtIndex:indexPath.row];
//        NSString* nid = addStore.update_md5id;
//        NSArray *storeinfo = nil;
        WSAddNewStoreViewController *ansVC  = nil;
        
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = _subempid;
        
        action.func_code = self.currentFuncs.fc;
        action.dict_id = item.acvtID;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = item.genID;
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
        }else{
            
            action.module_fc = action.func_code;
        }
        
        ansVC = [[WSAddNewStoreViewController alloc] initWithFuncs:self.currentFuncs acvtId:item.acvtID genId:item.genID newStoreId:item.newstoreid];
        
        ansVC.acvtNameMainTitle = item.mainTitle;
        
        ansVC.currentVisitAction=action;
        //无法理解此代码逻辑。先移动到此。
        if (self.currentStore) {
            ansVC.currentStore=self.currentStore;
        }
        if (_subempid) {
            ansVC.currentStore.srid=_subempid;
        }
//        if (storeinfo != nil) {
        
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            
            LogInfo(@"Going into class:%@, md5:%@,mainTitle:%@", ansVC, item.genID, item.mainTitle);
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteStoreSucceed:) name:DeleteNewAddStoreSucceed object:nil];
            if (!ansVC.currentVisitAction) {
                ansVC.currentVisitAction = self.currentVisitAction;
            }
            
            if (INTERFACE_IS_PAD) {
                WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:ansVC];
                [ansVC leftItemImage:@"icon_back" target:ansVC action:@selector(backAction)];
                
                [self presentViewController:nav animated:YES completion:nil];
            }else {
                if (self.ownParentViewController) {
                    
                    [self.ownParentViewController.navigationController pushViewController:ansVC animated:YES];
                }else if(self.navigationController){
                    
                    [self.navigationController pushViewController:ansVC animated:YES];
                }
            }
            
            
//        }
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count <= 0)
        return @[];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        WSAcvtListDataItem *acvtListDataItem = (WSAcvtListDataItem *)[self.dataArray objectAtIndex:indexPath.row];

        [self deleteAcvtDatasWithAcvtListDataItem:acvtListDataItem];

        [self.dataArray removeObjectAtIndex:indexPath.row];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [tableView deleteRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationFade];

    }];

    if (self.currentFuncs.opt.isAcvtListCanDelete.length > 0 && ([self.currentFuncs.opt.isAcvtListCanDelete isEqualToString:@"1"] || [self.currentFuncs.opt.isAcvtListCanDelete isEqualToString:@"true"])) {
        return @[action1];
    }else
        return @[];
}

- (void)deleteAcvtDatasWithAcvtListDataItem:(WSAcvtListDataItem *)acvtListDataItem
{
    
    [self deleteAcvtDatasWithAcvtModel:[self getAcvtModelWithAcvtListDataItem:acvtListDataItem]];
}

- (WSAcvtModel *)getAcvtModelWithAcvtListDataItem:(WSAcvtListDataItem *)acvtListDataItem
{
    WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
    acvtModel.currentFuncs = self.currentFuncs;
    acvtModel.currentStore = self.currentStore;
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtID:acvtListDataItem.acvtID];
    acvtBean.isBlock = @"1";
    acvtModel.currentAcvtBean = acvtBean;
    acvtModel.isNewAddAcvt = NO;
    acvtModel.md5 = acvtListDataItem.genID;
    
    return acvtModel;
}

- (BOOL)deleteAcvtDatasWithAcvtModel:(WSAcvtModel *)acvtModel
{
    LogTrace();
    
    WSAcvtModel *model = acvtModel;
    self.currentDeleteAcvtModel = acvtModel;
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix_DeleteNewsAcvt, [WSJSONBuilder gen_uuid]];
    
    self.notifyID = notifyID;
    
    // "删除门店"按钮，则注册返回当前页面的通知
    if ([model isSynchronizeRequest]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNewAddAcvtDatasFinish:) name:notifyID object:nil];
    }
    
    NSString *md5String = model.md5;
    
    NSMutableDictionary *deleteDic = [[NSMutableDictionary alloc] init];
    
    [deleteDic setObject:@"1" forKey:@"isDeleteAcvt"];
    
    NSString* postData = nil;
    NSString *delReason = nil;
    
    postData = [WSJSONBuilder buildDeleteAcvtDatasbyFuncs:model.currentFuncs acvt:model.currentAcvtBean isPhoto:NO Store:model.currentStore qstValuesDic:deleteDic md5:md5String submitId:model.md5 Others:nil addedAcvtForStore:model.currentNewStore tableDatas:nil delReason:delReason];
    
    
    [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                              notifyName:notifyID
                                                     md5:model.md5
                                    isSynchronizeRequest:[model isSynchronizeRequest]];
    
    return YES;
}

#pragma mark -
// 点击删除按钮请求数据完成
- (void)deleteNewAddAcvtDatasFinish:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notifyID object:nil];
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    NSString *result = [infoDic objectForKey:@"result"];
    
    if ([result isEqualToString:@"1"] || [result isEqualToString:@"0"]) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:result forKey:@"flag"];
        result = [tempDic JSONString];
    }
    
    NSDictionary *resultDic = [result objectFromJSONString];
    NSString *tip = nil;
    if (resultDic) {
        NSString *flag = [resultDic objectForKey:@"flag"];
        if (flag && [flag isKindOfClass:[NSString class]] && [flag intValue] == 1) {
            // 服务器删除成功提示
            tip = NSLocalizedString(@"deleted_success_label",nil);
            
            // 用Md5删除本地数据库中的此门店
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            [service deleteServerDataWithGenId:self.currentDeleteAcvtModel.md5];
            [service deleteLocalDataWithGenId:self.currentDeleteAcvtModel.md5];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringNotNilWithValue:self.currentDeleteAcvtModel.md5 ]forKey:DelteStoreMD5_Key];
            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteNewAddStoreSucceed object:self userInfo:userInfo];
        } else {
            // 服务器删除失败提示
            tip = NSLocalizedString(@"deleted_failure_label",nil);
            
        }
    } else {
        tip = NSLocalizedString(@"server_reponse_error",nil);
    }
    
    [self refreshData];
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
}

//  与父类重复=----SFA-16456
// 服务器搜索返回数据
//- (void)remoteSearchFinish:(id)sender {
//    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_Remote_Notify object:nil];
//    // 解析数据
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//    NSDictionary *dic = [info objectFromJSONString];
//
//    NSString *ds = self.currentFuncs.ds;
//    if (ds == nil) {
//        ds = ACVTDIS;
//    }
//
//    for (NSString *key in dic.allKeys) {
//        if ([key rangeOfString:ACVTDIS].location != NSNotFound) {
//            ds = key;
//        }
//    }
//
//    NSArray *remoteAcvtdis = [dic objectForKey:ds];
//    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
//
//    if ([flag isEqualToString:@"0"]) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
//        return;
//    }
//
//    NSString *alterString = nil;
//
//    if (remoteAcvtdis && [remoteAcvtdis count] > 0) {
//
//        self.currentSaveDataType = WSSaveSeachedData;
//
//        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
//        if ([self.currentFuncs.opt.sendRequest isEqualToString:@"remote"]) {
//            NSDictionary *storeDicInfo = nil;
//            if ([remoteAcvtdis isKindOfClass:[NSDictionary class]]) {
//                storeDicInfo = (NSDictionary *)remoteAcvtdis;
//            }else if ([remoteAcvtdis isKindOfClass:[NSArray class]]) {
//                storeDicInfo = [(NSArray *)remoteAcvtdis firstObject];
//            }
////            MENGNIU-1021 董宏 获取服务器数据
//            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo genId:nil isRemoteSearch:YES];
//
//        }else{
//            [service replaceToTableWithDicts:remoteAcvtdis FromNode:ACVTDIS hasNewData:YES storeID:nil isRemoteSearch:YES];
//
//        }
//
//        WSBaseAcvtdisDBService *processServer = [[WSBaseAcvtdisDBService alloc] init];
//        if (![processServer processServerAcvtDisValue]) {
//            LogError(@"processServerAcvtDisValue 失败");
//        }
//
//        [self reloadData];
//
////        alterString = NSLocalizedString(@"update_done_label",nil);
////        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
//
//    } else {
//        // 提示没有搜出来结果
//        self.dataArray = nil;
//        [self.tableView reloadData];
//        alterString = NSLocalizedString(@"no_result", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }
//
//    if (self.isFirstLoad) {
//        [self autoJumpToNextViewController];
//        self.isFirstLoad = NO;
//    }
//
//}



#pragma  mark - checkBox business
- (BOOL) isValidSMSNode
{
    if (self.currentFuncs
        && self.currentFuncs.opt
        && self.currentFuncs.opt.SMS
        && [self.currentFuncs.opt.SMS length] > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)phoneNumberForItem:(WSAcvtListDataItem *)item
{
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *qstDisArray = [service queryAcvtQstDatasByGenId:item.genID];
    if ([qstDisArray count] > 0) {
        for (WSAcvtQstDisItem *qstItem in qstDisArray) {
            if ([qstItem.qsttype isEqualToString:QST_TYPE_M]
                && (qstItem.acvtanswer && [qstItem.acvtanswer length] > 0)) {
                return qstItem.acvtanswer;
            }
        }
    }
    
    return nil;
}

- (void) addUnExistString:(NSString*)str toArray:(NSMutableArray*)sourceArray
{
    if (!str || !sourceArray) {
        return;
    }
    
    __block BOOL isExist = NO;
    [sourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([str isEqualToString:obj]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    
    if (!isExist) {
        [sourceArray addObject:str];
    }
}

- (void) updateSMSButtonTitle
{
    if ([self isValidSMSNode]) {
        NSUInteger count = 0;
        
        for (WSAcvtListDataItem *item in self.dataArray) {
            if (item.isChecked) {
                count = count + 1;
            }
        }
        
        if (count > 0) {
             [self.smsButton setTitle:[NSString stringWithFormat:@"%@(%lu)",self.currentFuncs.opt.SMS,(unsigned long)count] forState:UIControlStateNormal];
            if(self.checkedAllNum==count){
                self.isCheckedALL = YES;
                [self.checkedAllButton setTitle:NSLocalizedString(@"check_all_cancel", nil) forState:UIControlStateNormal];
            }
        }else{
            [self.smsButton setTitle:self.currentFuncs.opt.SMS forState:UIControlStateNormal];
            self.isCheckedALL = NO;
            self.checkedAllNum = 0;
            [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil) forState:UIControlStateNormal];
        }
    }
}

#pragma mark - WSSmsControllerDelegate
-(void) SmsFinishedWithResult:(ESmsComposeResult)result withContent:(NSString*) contentStr
{
//    if (self.addNewAcvtList && [self.addNewAcvtList count] > 0) {
//        [self.addNewAcvtList removeAllObjects];
//    }

//    self.dataArray = nil;
    WSBaseSmsDataTable * baseTable = [[WSBaseSmsDataTable alloc]init];

    for (NSString * phoneNum in self.smsController.phones) {
        NSString  *resultStr;
        if (result == ESmsComposeResultSent) {  // 现在不能获取到短信是否发送成功与失败，如果是取消发送的不入库
            resultStr = @"-1";
        }else if (result == ESmsComposeResultFailed){
            resultStr = @"-1";
        }else{
            resultStr = @"1";

        }
        if ([resultStr isEqualToString:@"-1"]) {
            
            [baseTable insertDataWithContent:contentStr receiver:@[phoneNum] result:resultStr];
        }
    }
    
    [self updateSMSButtonTitle];
    [self.checkedAllButton setTitle:NSLocalizedString(@"check_all", nil) forState:UIControlStateNormal];
}
@end
