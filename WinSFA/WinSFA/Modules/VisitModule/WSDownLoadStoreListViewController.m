//
//  WSDownLoadStoreListViewController.m
//  WinSFA
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDownLoadStoreListViewController.h"
#import "WSDownLoadStoreListTableViewCell.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSNewLocationSelectViewController.h"
#import "WSStoreHttpService.h"
#import "WSDownloadDataProgressView.h"
#import "WSDropListView.h"
#import "WSBaseOptionDataItem.h"

#define TABLE_HEIGHT        45.0
#define kLocateCityName       @"locate_cityName"



@interface WSDownLoadStoreListViewController ()<UITableViewDelegate,UITableViewDataSource,WSLocationNewSelectViewControllerDelegate,WSDropListViewDelegate>
{
    
    BOOL isBranchDownLoadStoreList;//是否是城市下载门店
}
@property (nonatomic , strong) WSStoreHttpService * storeHttpService;  // 门店请求工具
@property (nonatomic, strong) WSDownloadDataProgressView *listProgress; //门店列表的下载进度条
@property (nonatomic, strong) WSDropListView *dropListView;//下拉框

@property (nonatomic,copy)  NSString *storeDownloadType;//门店下载类型

@end
@implementation WSDownLoadStoreListViewController
{
    NSMutableArray *_dataArray;
    
    UIButton *_btnDown;
    
    UITableView *_table;
    
    UIButton *_cityBtn;
    
    WSDictBean *_dictBean;
    
    NSObject<I_W_OptionDataItem> *_branchItem;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    isBranchDownLoadStoreList = self.currentFuncs.opt.isBranchStoreDownload;
    if (isBranchDownLoadStoreList) {
        self.storeDownloadType = WSCQVC_QUERY_STORE_ORG_LIST;
    } else {
        self.storeDownloadType = WSCQVC_QUERY_STORE_CITY_LIST;
    }
    _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadData];
    [self addTable];
    
}
-(WSStoreHttpService *)storeHttpService{
    if (!_storeHttpService) {
        _storeHttpService = [[WSStoreHttpService alloc]init];
    }
    return _storeHttpService;
}
- (void)viewWillAppear:(BOOL)animated
{
    if (_table) {
        [self loadData];
    }
}
- (void)loadData
{
    WSBaseStoreOtherDataDBService *dbService = [[WSBaseStoreOtherDataDBService alloc] init];

    _dataArray =  (NSMutableArray*)[dbService queryWithType:self.storeDownloadType];
    _dataArray = (NSMutableArray *)[[_dataArray reverseObjectEnumerator] allObjects];
    
    [_table reloadData];
    
}
- (void)addTable
{
    UITableView  *table= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- UI_NAVIGATION_BAR_HEIGHT - UI_STATUS_BAR_HEIGHT - TABLE_HEIGHT  - MAIN_SECTION_HEIGHT -  2 * MAIN_BIG_PADDING) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    _table = table;
    _table.tableHeaderView = [self makeHeaderView];
    [self.view addSubview:table];
    
    _btnDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnDown.frame = CGRectMake(MAIN_BIG_PADDING,CGRectGetMaxY(table.frame) + MAIN_BIG_PADDING, self.view.frame.size.width - 2 * MAIN_BIG_PADDING , MAIN_SECTION_HEIGHT);
    _btnDown.backgroundColor = MAIN_TINT_COLOT;
    _btnDown.tintColor = [UIColor whiteColor];
    _btnDown.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [_btnDown setTitle:@"确认" forState:UIControlStateNormal];
    [_btnDown addTarget:self action:@selector(btnDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDown];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TABLE_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_HEIGHT;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *SimpleTableIdentifier = @"DownLoadTableIdentifier";
    
    WSDownLoadStoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[WSDownLoadStoreListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: SimpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.storeOther = _dataArray[indexPath.row];
    
    return cell;
    
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TABLE_HEIGHT)];

    view.backgroundColor = [UIColor whiteColor];
    
    CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
    CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING, 0, titleWidth, TABLE_HEIGHT);
    UILabel *labL = [[UILabel alloc] initWithFrame:titleFrame];
    [labL setTextColor:[UIColor colorWithHexString:@"000000"]];
    [labL setFont:[UIFont boldSystemFontOfSize:UI_Font]];
    labL.text = isBranchDownLoadStoreList ? @"已下载门店列表的分公司" : @"已下载门店列表城市";;
    [view addSubview:labL];
    
    
    titleFrame = CGRectMake( FRAME_WIDTH/2, 0, titleWidth, TABLE_HEIGHT);
    UILabel *labR = [[UILabel alloc] initWithFrame:titleFrame];
    [labR setTextColor:[UIColor colorWithHexString:@"000000"]];
    [labR setFont:[UIFont boldSystemFontOfSize:UI_Font]];
    labR.textAlignment = NSTextAlignmentRight;
    labR.text = @"最新下载时间";
    [view addSubview:labR];
    
    return view;
}
- (UIView*)makeHeaderView
{

    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TABLE_HEIGHT)];
    
    CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
    CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING, 0, titleWidth, TABLE_HEIGHT);
    UILabel *cityLab = [[UILabel alloc] initWithFrame:titleFrame];
    [cityLab setTextColor:GRAY_TEXT_COLOR];
    [cityLab setFont:[UIFont systemFontOfSize:UI_Font]];
    cityLab.text = isBranchDownLoadStoreList ? @"分公司" : @"城市";
    [viewHeader addSubview:cityLab];
    
    titleFrame = CGRectMake( FRAME_WIDTH/2, 0, titleWidth, TABLE_HEIGHT);
    if (isBranchDownLoadStoreList) {
        self.dropListView = [[WSDropListView alloc] initWithFrame:titleFrame selectMode:WSDropListViewSelectModeSingleSelection];
        self.dropListView.dropListDelegate = self;
        //获取所有分公司
        NSArray *orgs = [service queryBranchDownLoadList];
        if (orgs.count > 0) {
            _dictBean = orgs[0];
            WSBaseOptionDataItem *optItem = [[WSBaseOptionDataItem alloc] init];
            optItem.itemID = [NSString stringWithValue:_dictBean.Id];
            optItem.itemName = _dictBean.name;
            self.dropListView.selectedItem = optItem;
        }
        
        [self.dropListView refreshListWithDataSourceArray:orgs];
        [viewHeader addSubview:self.dropListView];
    } else {

        NSString *lastCurrentCity = [[NSUserDefaults standardUserDefaults] objectForKey:kLocateCityName];
        NSString *levelCod = self.currentFuncs.opt.gpsCityLevel ? self.currentFuncs.opt.gpsCityLevel : @"2";
        NSArray *arr = [service queryCityListByFilter:@"geography" levelCode:levelCod];
        
        _dictBean = [[arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",lastCurrentCity]] firstObject];

        UIImage *img = [UIImage imageNamed:@"icon_arrow_down"];
        CGFloat titleW = [_dictBean.name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]}].width;
        UIButton *btnCity = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCity.frame = titleFrame;
        btnCity.tintColor = [UIColor colorWithHexString:@"000000"];
        btnCity.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        btnCity.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnCity setTitle:_dictBean.name forState:UIControlStateNormal];
        [btnCity setImage:img forState:UIControlStateNormal];
        [btnCity addTarget:self action:@selector(cityBtnDown:) forControlEvents:UIControlEventTouchUpInside];
        [btnCity setTitleEdgeInsets:UIEdgeInsetsMake(0, -24, 0, 24)];
        [btnCity setImageEdgeInsets:UIEdgeInsetsMake(0, titleW, 0, - titleW)];
        _cityBtn = btnCity;
        [viewHeader addSubview:btnCity];
    }
    return viewHeader;
}
- (void)btnDown
{
    BOOL isStoreCityDownloadType = [self.storeDownloadType isEqualToString:WSCQVC_QUERY_STORE_CITY_LIST];
    if (_dictBean || _branchItem) {
        self.storeHttpService.objID = self.currentFuncs.ds ? : @"";
        self.storeHttpService.downLoadStoreListType = self.storeDownloadType;
        if (isStoreCityDownloadType) {
            self.storeHttpService.currentCity = _dictBean.name;
            self.storeHttpService.cityCode = _dictBean._id ? _dictBean._id :_dictBean.Id;;
        } else {
            self.storeHttpService.currentOrg = _branchItem.getDataItemName;
            self.storeHttpService.orgId = _branchItem.getDataItemID;
        }
            __weak typeof(self)weakSelf = self;
        // 请求门店数据
        //        NSString *AccessInforString = NSLocalizedString(@"update_data_tip",nil);
        //        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
        //益海嘉里200家门店功能，弹出特定进度条 --zhangmin
        [self initListProgress];
        
        [self.storeHttpService getCustomerQueryStoreListDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
//        YIHAIKERRY-3437    添加没有结果的提示
            if (dic && !error) {
                
                self.listProgress.progress = 100;
                
                if (![dic objectForKey:self.currentFuncs.ds]) {
                    NSString *message = NSLocalizedString(@"no_store_in_city", nil);
                    if (!isStoreCityDownloadType) {
                        message = NSLocalizedString(@"no_store_in_branch", nil);
                    }
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
                    return ;
                }
                [weakSelf loadData];
                [[NSNotificationCenter defaultCenter]postNotificationName:DOWN_OR_ClEAR_RELOAD_STORE_LIST object:nil];

            }
            else
            {
                [self.listProgress  closeListProgress];
                
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
                NSString *tipsString = NSLocalizedString(@"data_download_failure", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
        }];
        
    }
}

- (void)cityBtnDown:(UIButton*)cityBtnDown
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *arrCity = [service queryCityDownLoadList];
    if ([arrCity count] > 0) {
        WSNewLocationSelectViewController *lsvc = [[WSNewLocationSelectViewController alloc] initWithCurrentLocationItem:_dictBean selectedItem:nil dicts:arrCity];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:lsvc];
        lsvc.selectDelegate = self;
        [self presentViewController:navc  animated:YES completion:nil];
    }
}

- (void)viewController:(WSNewLocationSelectViewController *)viewController didselectedItem:(WSDictBean *)item {
    _dictBean = item;
    [_cityBtn setTitle:item.name forState:UIControlStateNormal];
    CGFloat titleW = [_dictBean.name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]}].width;
    [_cityBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -24, 0, 24)];
    [_cityBtn setImageEdgeInsets:UIEdgeInsetsMake(0, titleW, 0, - titleW)];

}
//YIHAIKERRY-3590 SFA 益海嘉里-传统渠道【门店列表】自动和手动加载门店列表、门店下载中心下载门店列表， 增加进度的显示效果
- (void)initListProgress {
    self.listProgress =  [[WSDownloadDataProgressView alloc] initWithSelect:0];
    [self.listProgress  showDownListAlertView];
    
}

#pragma mark-WSDropListViewDelegate
- (void)dropListViewDidChangeSelect:(WSBaseDropListView *)dropListView
{
    _branchItem = dropListView.selectedItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
