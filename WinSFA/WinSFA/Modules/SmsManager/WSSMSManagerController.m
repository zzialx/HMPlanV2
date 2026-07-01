//
//  WSSMSManagerController.m
//  WinSFA
//
//  Created by mac on 16/12/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSMSManagerController.h"
#import "WSSMSSendView.h"
#import "WSSmsController.h"
#import "WSBaseSmsDataTable.h"
#import "WSMappingObject.h"
#import "WSSMSManagerModel.h"
#import "WSSMSDetailCell.h"
#import "WSBaseSmsDBService.h"
#import "WSEmptyView.h"

#define cell_hight    80.0f
#define DELETE_TITLE_FONTSIZE  (INTERFACE_IS_PHONE ? 14.0 : 16.0)
//=============================================================================================================================================================

@interface WSSMSManagerController () <UITableViewDelegate,UITableViewDataSource, WSSmsControllerDelegate>

@property (nonatomic , strong) WSSmsController *smsController;
@property (nonatomic , strong) UITableView * treeTableView;
@property (nonatomic , strong) UILabel * allSelectLabel;
@property (nonatomic , strong) UIButton * selectButton;
@property (nonatomic , strong) UIButton * delectButton;
@property (nonatomic , strong) WSBaseSmsDataTable * baseTable;
@property (nonatomic , assign) BOOL allButtonIsSelct;
@property (nonatomic , strong) WSEmptyView *msgEmptyView;

@end
//=============================================================================================================================================================

@implementation WSSMSManagerController

-(NSMutableArray *)dataSource
{
    if (!_dataSource)
        _dataSource = [[NSMutableArray alloc]init];
    
    return _dataSource;
}

-(WSBaseSmsDataTable *)baseTable
{
    if (!_baseTable)
        _baseTable = [[WSBaseSmsDataTable alloc]init];
    
    return _baseTable;
}

-(id)initWithFuncs:(WSFuncsBean *)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        return self;
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.currentFuncs)
    {
        WSBaseSmsDBService * smsDBService = [[WSBaseSmsDBService alloc]init];
        self.dataSource = [smsDBService getAllSMSManagerFromDB];
        _delectButton.hidden = YES;
        
        [self checkIfNoData];
        [self.treeTableView reloadData];
    }
    
    [self setSelectButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem *buttonItem = nil;
    NSString *buttonName =  self.currentFuncs.buttonName;
    buttonName = [buttonName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *isAddString = self.currentFuncs.opt.isAdd;
    BOOL isAdd = YES;
    if (isAddString && [isAddString isEqualToString:@"N"])
        isAdd = NO;
    
    if (buttonName && [buttonName length] > 0 && isAdd)
        buttonItem = [self barButtonItemTitle:buttonName target:self action:@selector(addNewAcvt:)];
    
    if (self.ownParentViewController)
        self.ownParentViewController.navigationItem.rightBarButtonItem = buttonItem;
    else
        self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)addNewAcvt:(id)sender
{
}

- (void)checkIfNoData
{
    if (_dataSource && _dataSource.count > 0)
        self.msgEmptyView.hidden = YES;
    else
    {
        [self.msgEmptyView updateFromFuncsBean:self.currentFuncs];
        self.msgEmptyView.hidden = NO;
    }
}

-(void)setSelectButton
{
    int i = 0;
    for (id model  in _dataSource)
    {
        if ([model isKindOfClass:[WSSMSManagerModel class]])
        {
            WSSMSManagerModel * data = (WSSMSManagerModel *)model;
            if (data.lastObject.isSelect)
                i++;
        }
        else
        {
            WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
            if (data.isSelect)
                i++;
        }
    }
    
    if (i == _dataSource.count && i != 0)
    {
        self.allButtonIsSelct = YES;
        _delectButton.hidden = NO;
    }
    else
        self.allButtonIsSelct = NO;
    _selectButton.selected = self.allButtonIsSelct;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *titleBgColor = [UIColor colorForKey:@"GridHeaderBackgroundColor"];
    if (!titleBgColor)
        titleBgColor = [UIColor colorWithHexString:@"0xeeeeee"];
    
    self.view.backgroundColor = titleBgColor;
    
    _selectButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 8, 30, 30)];
    _selectButton.selected = self.allButtonIsSelct;
    [_selectButton addTarget:self action:@selector(selectAllData:) forControlEvents:UIControlEventTouchUpInside];
    [_selectButton setImage:[UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage scaledImageForName:@"icn_check" ofType:@"png"] forState:UIControlStateSelected];
    _allSelectLabel = [[UILabel alloc]initWithFrame:CGRectMake(_selectButton.right + 12 , 2, 60, 40)];
    _allSelectLabel.text = NSLocalizedString(@"check_all", nil);
    _allSelectLabel.font = [UIFont systemFontOfSize:DELETE_TITLE_FONTSIZE];
    _allSelectLabel.textColor = [UIColor colorWithHexString:@"0x282828"];
    _delectButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width - 75 , 2, 60, 40)];
    _delectButton.hidden = YES;
    [_delectButton addTarget:self action:@selector(delectDataShip) forControlEvents:UIControlEventTouchUpInside];
    [_delectButton setTitle:NSLocalizedString(@"delete_label", nil) forState:UIControlStateNormal];
    _delectButton.titleLabel.font = [UIFont systemFontOfSize:DELETE_TITLE_FONTSIZE];
    [_delectButton setTitleColor:[UIColor colorWithHexString:@"0x282828"] forState:UIControlStateNormal];
    
    [self.view addSubview:_selectButton];
    [self.view addSubview:_allSelectLabel];
    [self.view addSubview:_delectButton];
    
    _treeTableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.origin.x, 44, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _treeTableView.delegate = self;
    _treeTableView.dataSource = self;
    _treeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _treeTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    if (IOS7_OR_LATER)
        _treeTableView.height = self.view.height - 64 - 20;
    else
        _treeTableView.height = self.view.width - 64 - 44;
    [self.view addSubview:_treeTableView];
    
    self.msgEmptyView = [[WSEmptyView alloc] initWithFrame:self.view.bounds];
    self.msgEmptyView.backgroundColor = [UIColor whiteColor];
    self.msgEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.msgEmptyView.hidden = YES;
    
    [self.view addSubview:self.msgEmptyView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WSSMSDetailCell cellHeightWith:_dataSource[indexPath.row]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString * reuserId = @"treeTableCell";
    WSSMSDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    WSSMSDetailCellType type ;
    
    if (self.currentFuncs)
        type = WSSMSDetailCellTypeGroup;
    else
        type = WSSMSDetailCellTypeDetail;
    
    if (!cell)
        cell = [[WSSMSDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId type:type];
    
    id model = _dataSource[indexPath.row];
    cell.buttonClick = ^(){
        if ([model isKindOfClass:[WSSMSManagerModel class]]) {
            WSSMSManagerModel * data = (WSSMSManagerModel *)model;
            data.lastObject.isSelect = data.lastObject.isSelect?0:1;
            for (WSBaseSmsDataObject * obj in data.array)
                obj.isSelect = data.lastObject.isSelect;
        }
        else
        {
            WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
            data.isSelect = data.isSelect?0:1;
        }
        
        int i = 0;
        for (id model  in _dataSource)
        {
            if ([model isKindOfClass:[WSSMSManagerModel class]])
            {
                WSSMSManagerModel * data = (WSSMSManagerModel *)model;
                if (data.lastObject.isSelect)
                    i++;
            }
            else
            {
                WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
                if (data.isSelect)
                    i++;
            }
        }
        // 设置删除按钮是隐藏还是显示
        if (i == _dataSource.count)
        {
            _selectButton.selected = YES;
            _delectButton.hidden = NO;
        }
        else if (i == 0)
        {
            _selectButton.selected = NO;
            _delectButton.hidden = YES;
        }
        else
        {
            _selectButton.selected = NO;
            _delectButton.hidden = NO;
        }
        
        [self.treeTableView reloadData];
    };
    
    cell.model = model;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.currentFuncs)
    {
        WSSMSManagerModel *model = _dataSource[indexPath.row];
        WSSMSManagerController * subSmsController = [[WSSMSManagerController alloc]init];
        subSmsController.title = model.lastObject.receiver_num;
        subSmsController.dataSource = [model.array mutableCopy];
        [self.navigationController pushViewController:subSmsController animated:YES];
    }
    else
    {
        WSBaseSmsDataObject *model = _dataSource[indexPath.row];
        BlockAlertView * alertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"是否需要重新发送短信？", nil)];
        [alertView setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [alertView addButtonWithTitle:NSLocalizedString(@"send_lable", nil) block:^{
            self.smsController= [[WSSmsController alloc] initWithDelegate:self withParentVC:self];
            [self.smsController presentSMSPageWithPhones:@[model.receiver_num] withContent:model.content withIscanned:NO];
        }];
        [alertView show];
    }
}

-(void) SmsFinishedWithResult:(ESmsComposeResult)result withContent:(NSString*) contentStr
{
    NSString  *resultStr;
    if (result == ESmsComposeResultSent)
        resultStr = @"-1";
    else if (result == ESmsComposeResultFailed)
        resultStr = @"-1";
    else
        resultStr = @"1";

    if ([resultStr isEqualToString:@"-1"])
        [self.baseTable insertDataWithContent:contentStr receiver:self.smsController.phones result:resultStr];
}

-(void)selectAllData:(UIButton *)sender
{
    sender.selected = !sender.selected;
    for (id model in _dataSource)
    {
        if ([model isKindOfClass:[WSSMSManagerModel class]])
        {
            WSSMSManagerModel * data = (WSSMSManagerModel *)model;
            data.lastObject.isSelect = sender.selected;
            for (WSBaseSmsDataObject * obj in data.array)
                obj.isSelect = data.lastObject.isSelect;
        }
        else
        {
            WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
            data.isSelect = sender.selected;
        }
    }
    _delectButton.hidden = !sender.selected;
    [self.treeTableView reloadData];
}

-(void)delectDataShip
{
    BlockAlertView * alterView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"确定要删除吗？", nil)];
    [alterView setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    [alterView addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
        [self delectData];
    }];
    [alterView show];
}

-(void)delectData
{
    for (int i = 0; i < _dataSource.count; i++)
    {
        id model = _dataSource[i];
        if ([model isKindOfClass:[WSSMSManagerModel class]])
        {
            WSSMSManagerModel * data = (WSSMSManagerModel *)model;
            if (data.lastObject.isSelect)
            {
                [self.baseTable deleteWithNames:@[@"receiver_num"] ArgumentsValue:@[data.lastObject.receiver_num]];
                [_dataSource removeObject:data];
                i--;
            }
        }
        else
        {
            WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
            if (data.isSelect)
            {
                [self.baseTable deleteWithNames:@[@"receiver_num",@"result_time",@"content",@"genId"]
                                 ArgumentsValue:@[data.receiver_num,data.result_time,data.content,data.genId]];
                [_dataSource removeObject:data];
                i--;
            }
        }
    }
    
    [self.treeTableView reloadData];
    [self checkIfNoData];
}

@end
//=============================================================================================================================================================
