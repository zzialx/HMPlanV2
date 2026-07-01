//
//  WSVisitRecordListController.m
//  WinSFA
//
//  Created by Nemo on 14-3-25.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitRecordListController.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+TapAction.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"

#import "WSVisitRecord.h"
#import "WSVisitRecordDetailController.h"

@interface WSVisitRecordListController ()
{
    UITableView    *recordTableView;
}
@end

@implementation WSVisitRecordListController

-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store
{
    if(funcs==nil || store == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.currentStore = store;
        
        return self;
    }
    return nil;
}


/**
 * 请求数据
 */
- (void)updateDatas
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordResponse:) name:store_visit_record_notify object:nil];
    
    NSMutableDictionary *pamDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    [pamDic setObject:self.currentStore.sid forKey:@"storeId"];
    [pamDic setObject:self.currentFuncs.filter forKey:@"objId"];
    [pamDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];

    [[WSRequestHelper shareInstance] uploadDatasDictionary:pamDic urlString:URL_UPDATE notifyName:store_visit_record_notify md5:nil isUpload:NO];
}

- (void)loadView
{
    [super loadView];
    
    recordTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [recordTableView setBackgroundColor:[UIColor whiteColor]];
    [recordTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [recordTableView setDataSource:self];
    [recordTableView setDelegate:self];
    [[self view] addSubview:recordTableView];
    
    [MBProgressHUD showHUDAddedTo:recordTableView withText:NSLocalizedString(@"logining_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    [self updateDatas];
}


/**
 * 返回数据
 */
- (void)recordResponse:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:store_visit_record_notify object:nil];
    [MBProgressHUD hideAllHUDsForView:recordTableView animated:YES];
    NSString *objId = self.currentFuncs.filter;
    if (!objId) {   return; }
    
    NSArray *dataArray = [[[[sender userInfo] objectForKey:@"datas"] objectFromJSONString] objectForKey:objId];
    NSLog(@"%@",dataArray);
    if (!dataArray) {   return; }
    
    if (self.datas) {   [self.datas removeAllObjects];  }
    self.datas = nil;
    self.datas = [[NSMutableArray alloc] initWithCapacity:dataArray.count];
    
    for (NSDictionary *dic in dataArray)
    {
        WSVisitRecord *visitRecord = [[WSVisitRecord alloc] init];
        [visitRecord fillByDic:dic];
        if (visitRecord) {
            [self.datas addObject:visitRecord];
        }
    }
    
    [recordTableView reloadData];
}

#pragma mark tv delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.datas.count) {    return;   }

    WSVisitRecord *visitRecord = [self.datas objectAtIndex:indexPath.row];
    WSVisitRecordDetailController *visitDetailController = [[WSVisitRecordDetailController alloc] initWithDetailString:visitRecord.recordDetails];
    if (visitDetailController)
    {
        [[self navigationController] pushViewController:visitDetailController animated:YES];
    }
}


#pragma mark tv data source

- (NSInteger)tableView:tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    WSVisitRecord *visitRecord = [self.datas objectAtIndex:indexPath.row];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@",visitRecord.empName,visitRecord.bizDate]];
    
    return cell;
}
































@end
