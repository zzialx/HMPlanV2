//
//  WSTypListMsgViewController.m
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTypListMsgViewController.h"
#import "WSSubMsgsViewController.h"
#import "WSMsgsBean.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean_msg.h"
#import "WSBaseMsgTypeTable.h"
#import "WSListMsgViewController.h"
#import "WSTypeMsgTableViewCell.h"
#import "WSStatisticsManager.h"
#define TABLE_HEIGHT        45.0


@interface WSTypListMsgViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WSTypListMsgViewController

#pragma mark - system mathod

-(id)initWithFuncs:(WSFuncsBean*)funcs
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

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self setCompanyInfo];
    [self.titlesTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setCompanyInfo];

    UITableView* tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tv setDelegate:self];
    [tv setDataSource:self];
    tv.tableFooterView = [[UIView alloc]init];
    self.titlesTableView = tv;
    self.titlesTableView.scrollEnabled = YES;
    [self.view addSubview:self.titlesTableView];

    // Do any additional setup after loading the view.
}
- (void)setCompanyInfo
{
    WSMsgBeanArray * messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType] storeId:self.currentStore.Id];// messageArray中存储的是 公司分类信息
    self.dataArray = [[NSMutableArray alloc] init];//存储分类数据信息
    self.dataArray = messageArray.msgArray;
    
    if (messageArray.msgArray.count == 0)
        return;
    
    NSArray *msgsArray = nil;
    __block WSMsgsBean * workMsgBean = nil;
//    __block WSMsgsBean_msg * msgsB_msg = nil;
//    董宏 SFA-25530 
    NSMutableArray *filterArray = [NSMutableArray array];
    if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0)
    {
        msgsArray = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
        if (msgsArray != nil)
        {
            WSFuncsBean* subfuncs = self.currentFuncs;
            if (self.currentFuncs.funcsArray.count > 0)
                subfuncs   = [self.currentFuncs.funcsArray objectAtIndex:0];
            
            [msgsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                workMsgBean = (WSMsgsBean*)obj;
                if(workMsgBean.msg.count>0)
                {
                    [filterArray addObject:obj];
                }

            }];
            self.dataArray = [filterArray mutableCopy];
        }
    }
    
    
    
    if (self.titlesTableView) {
        [self.titlesTableView reloadData];
    }
}


#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_HEIGHT;
}
//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    
    
    WSTypeMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                           SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[WSTypeMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier: SimpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.storeId = self.currentStore.Id;
    WSMsgsBean* message = [self.dataArray objectAtIndex:indexPath.row];
    [cell setMsgBean:message];

    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSMsgsBean* message = [self.dataArray objectAtIndex:indexPath.row];
    NSInteger subcount = [message.msg count];
    if(subcount == 0)
    {
        NSString *tmpString = NSLocalizedString(@"无消息",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    WSListMsgViewController *subMsgsVC = [[WSListMsgViewController alloc] init];
    subMsgsVC.sourceArray = message.msg;
    subMsgsVC.msgArray = self.dataArray;
    subMsgsVC.storeId = self.currentStore.Id;
    
    LogInfo(@"Going to class WSListMsgViewController");
    subMsgsVC.title = message.name;
    subMsgsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:subMsgsVC animated:YES];
    
    [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs store:self.currentStore eventValue:message.name startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
