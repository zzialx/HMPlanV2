//
//  WSClearStoreListViewController.m
//  WinSFA
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSClearStoreListViewController.h"
#import "WSClearstoreListTableViewCell.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreDBService.h"

#define TABLE_HEIGHT        45.0
@interface WSClearStoreListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)  NSString *storeDownloadType;//门店下载类型

@end

@implementation WSClearStoreListViewController
{
    NSArray *_dataArray;
    
    UIButton *_btnDown;
    
    UITableView *_table;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.currentFuncs.opt.isBranchStoreDownload) {
        self.storeDownloadType = WSCQVC_QUERY_STORE_ORG_LIST;
    } else {
        self.storeDownloadType = WSCQVC_QUERY_STORE_CITY_LIST;
    }
    [self loadData];
    [self addTable];
    // Do any additional setup after loading the view.
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
    
    _dataArray = [dbService queryWithType:self.storeDownloadType];

    [_table reloadData];
    
}
- (void)addTable
{
    UITableView  *table= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- UI_NAVIGATION_BAR_HEIGHT - UI_STATUS_BAR_HEIGHT - TABLE_HEIGHT - MAIN_SECTION_HEIGHT -  2 * MAIN_BIG_PADDING) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    _table = table;
    [self.view addSubview:table];
    
    _btnDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnDown.frame = CGRectMake(MAIN_BIG_PADDING,CGRectGetMaxY(table.frame) + MAIN_BIG_PADDING, self.view.frame.size.width - 2 * MAIN_BIG_PADDING , MAIN_SECTION_HEIGHT);
    _btnDown.backgroundColor = MAIN_TINT_COLOT;
    _btnDown.tintColor = [UIColor whiteColor];
    _btnDown.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [_btnDown setTitle:@"清除" forState:UIControlStateNormal];
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
    
    static NSString *SimpleTableIdentifier = @"ClearLoadTableIdentifier";
    
    WSClearstoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                              SimpleTableIdentifier];
    

    if (cell == nil) {
        cell = [[WSClearstoreListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
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
    [labL setTextColor:GRAY_TEXT_COLOR];
    [labL setFont:[UIFont boldSystemFontOfSize:UI_Font]];
    labL.text = [self.storeDownloadType isEqualToString:WSCQVC_QUERY_STORE_ORG_LIST] ? @"已下载门店列表的分公司" : @"已下载门店列表城市";
    [view addSubview:labL];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSBaseStoreOtherDataObject *storeDate = _dataArray[indexPath.row];
    if([storeDate.item20 isEqualToString:@"1"])
    {
        storeDate.item20 = @"0";
    }
    else
    {
        storeDate.item20 = @"1";
    }
    WSClearstoreListTableViewCell * cell = (WSClearstoreListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.storeOther = storeDate;
}

- (void)btnDown
{
    [self deleteStoresWithStoreListType:self.storeDownloadType storeArray:_dataArray];
    [self loadData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DOWN_OR_ClEAR_RELOAD_STORE_LIST object:nil];
}

#pragma mark-根据门店类型删除
- (void)deleteStoresWithStoreListType:(NSString *)storeListType storeArray:(NSArray *)storeArray {
    WSBaseStoreOtherDataDBService *storeOther = [[WSBaseStoreOtherDataDBService alloc] init];
    WSBaseStoreDBService *storeList = [[WSBaseStoreDBService alloc] init];
    NSString *search_obj = self.currentFuncs.ds;
    if ([self.currentFuncs.ds isEqualToString:@"autostoreinfofororg"]) {
        search_obj =  @"autostoreinfo";
    }
    for (WSBaseStoreOtherDataObject  * storeDate in storeArray) {
        if ([storeDate.item20 isEqualToString:@"1"] && storeDate.item2.length > 0) {
            [storeOther deleteStoreCityCode:storeDate.item2 empId:[WSAppData getObjectbyKey:APPDATA_EMPID] type:storeListType];
            [storeList deleteBaseStoreTableCity:storeDate.item2 type:storeListType search_obj:search_obj];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
