//
//  WSAddFollowUpStoreListViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/12.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSAddFollowUpStoreListViewController.h"
#import "WSStoreFollowUpHeaderFooterView.h"
#import "WSFollowUpStoreListTableViewCell.h"
#import "WSStoreListAddFollowUpDataModel.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "NSDate+Formatter.h"

static CGFloat const kStoreListFollowUpCellHeight    = 60;

static NSString * const kStoreListFollowUpCellId     = @"StoreListFollowUpCellId";
static NSString * const kStoreListFollowUpHeaderId    = @"StoreListFollowUpHeaderId";

@interface WSAddFollowUpStoreListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *followUpDataArray;

@end

@implementation WSAddFollowUpStoreListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"随访";
    [self addControls];
    [self loadStoreFollowUp];
}
- (void)addControls {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    tableView.rowHeight = kStoreListFollowUpCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSFollowUpStoreListTableViewCell class] forCellReuseIdentifier:kStoreListFollowUpCellId];
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}
- (void)loadStoreFollowUp
{
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    if(self.currentFuncs.opt.refreshNodeName.length>0){
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.refreshNodeName] forKey:@"objId"];
    }else{
        [paramDic setObject:[NSString stringNotNilWithValue:@"addFollowUpStoreSearchList"] forKey:@"objId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:self.filter] forKey:@"filter"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"addFollowUpStoreSearchList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    self.tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
}
-(void)uploadFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    NSString * objid = self.currentFuncs.opt.refreshNodeName.length>0?self.currentFuncs.opt.refreshNodeName:@"addFollowUpStoreSearchList";
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if(dic && [dic objectForKey:objid])
        {
            WSStoreListAddFollowUpDataModel *model = [WSStoreListAddFollowUpDataModel yy_modelWithDictionary:dic];
            if(self.currentFuncs.opt.refreshNodeName.length>0){
                self.followUpDataArray = [NSMutableArray arrayWithArray:model.addTskfFollowUpStoreSearchList];
            }else{
                self.followUpDataArray = [NSMutableArray arrayWithArray:model.addFollowUpStoreSearchList];
                  
            }
            [self.tableView reloadData];
        }else{
            if(self.followUpDataArray && self.followUpDataArray.count > 0)
            {
                [self.empty removeFromSuperview];
                self.empty = nil;
            }
            else{
                if (!self.empty)
                {
                    [self addEmptyView];
                    self.empty.frame = CGRectMake(self.empty.frame.origin.x, self.empty.frame.origin.y , self.empty.frame.size.width, self.empty.frame.size.height);
                }
            }
            
            [MBProgressHUD showHUDAddedTo:self.view withText:@"没有正在随访的门店" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followUpDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSFollowUpStoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoreListFollowUpCellId forIndexPath:indexPath];
    cell.model = self.followUpDataArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
     WSStoreListAddFollowUpDataInfoModel *infoModel = self.followUpDataArray[indexPath.row];
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    NSDate *date = [NSDate date];
    if(self.currentFuncs.opt.saveNode.length>0){
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.saveNode] forKey:@"objId"];
    }else{
        [paramDic setObject:[NSString stringNotNilWithValue:@"saveFollowUpStore"] forKey:@"objId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:infoModel.storeId] forKey:@"storeId"];
    if(infoModel.leaderId){
        [paramDic setObject:[NSString stringNotNilWithValue:infoModel.leaderId] forKey:@"leaderId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:infoModel.empId] forKey:@"salesId"];
    [paramDic setObject:[NSString stringNotNilWithValue:date.yyyyMMddByLineWithDate] forKey:@"bizDate"];
    [paramDic setObject:[NSString stringNotNilWithValue:@"1"] forKey:@"type"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"saveFollowUpStore";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSaveFollowUpStoreFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellH = kStoreListFollowUpCellHeight;
    WSStoreListAddFollowUpDataInfoModel *infoModel = self.followUpDataArray[indexPath.row];
    if (infoModel.leaderId && infoModel.leaderId.length > 0) {
        cellH+=25;
    }
    return cellH;
}
-(void)uploadSaveFollowUpStoreFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        NSString * objid = self.currentFuncs.opt.saveNode.length>0?self.currentFuncs.opt.saveNode:@"saveFollowUpStore";
        if(dic && [dic objectForKey:objid]&& [[dic objectForKey:objid] integerValue] == 1)
        {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"添加随访成功！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"添加随访失败！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

@end

