//
//  WSListMsgViewController.m
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSListMsgViewController.h"
#import "WSMsgsBean.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean_msg.h"
#import "WSMessageForNewUICell.h"
#import "WSReportFormController.h"
#import "WSDetalViewController.h"
#import "WSBaseMsgTable.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSRequestHelper.h"
#import "WSBaseMsgStoreTable.h"

@interface WSListMsgViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * unReadMsgArray;  //未读消息
@property (nonatomic, strong) NSMutableArray * isReadArray;
@property (nonatomic, strong) UITableView    * tableView;


@end

@implementation WSListMsgViewController
- (NSMutableArray *)isReadArray
{
    if (!_isReadArray)
        _isReadArray = [[NSMutableArray alloc]init];
    
    return _isReadArray;
}

- (NSMutableArray *)unReadMsgArray
{
    if (!_unReadMsgArray)
        _unReadMsgArray = [[NSMutableArray alloc]init];
    
    return _unReadMsgArray;
}

- (NSMutableArray *)sourceArray
{
    if (!_sourceArray)
        _sourceArray = [[NSMutableArray alloc]init];
    
    return _sourceArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self orderByPubdateDate];
    CGRect tableViewRect;

    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self ;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.frame =  self.view.bounds;
    tableViewRect = self.view.bounds;
    self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}
-(void)orderByPubdateDate
{
    [self.isReadArray removeAllObjects];;
    [self.unReadMsgArray removeAllObjects];;
    
    for (WSMsgsBean_msg * tempMsg in self.sourceArray)
    {
        tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@#%@", tempMsg.s, tempMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID],self.storeId];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
        NSNumber *number = [dic objectForKey:key];
        if ([tempMsg.isread isEqualToString:@"1"] || (number && [number boolValue]))
            [self.isReadArray addObject:tempMsg];
        else
            [self.unReadMsgArray addObject:tempMsg];
    }
    
//    NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO];
//    NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
//    self.isReadArray = [[self.isReadArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
//    self.unReadMsgArray = [[self.unReadMsgArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
    
    [self.sourceArray removeAllObjects];
    [self.sourceArray addObjectsFromArray:self.unReadMsgArray];  //未读在前，已读在后
    [self.sourceArray addObjectsFromArray:self.isReadArray];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((self.sourceArray.count > 0) ? self.sourceArray.count : 1);
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        WSMsgsBean_msg *allMsgModel = self.sourceArray[indexPath.row];
        WSMessageForNewUICell *cell = [WSMessageForNewUICell cellWithTableView:tableView];
        cell.storeId = self.storeId;
        cell.msgBean = self.msgArray;
        cell.MsgsBean_msg = allMsgModel;
        return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sourceArray.count > 0) {
            return [WSMessageForNewUICell cellHeightForRow:self.sourceArray[indexPath.row] with:self.view.width];
    }
    return CGRectGetHeight(tableView.bounds);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    WCBaseViewController *detalCtrl = nil;
    WSMsgsBean_msg *msgBean = self.sourceArray[indexPath.row];
    if ([msgBean.cont length] > 0 && [msgBean.cont hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:msgBean.cont];
        detalCtrl = [[WSReportFormController alloc] initWithURL:url];
    } else {
        detalCtrl = [[WSDetalViewController alloc]init];
        ((WSDetalViewController *)detalCtrl).srid = self.storeId;
        ((WSDetalViewController *)detalCtrl).model = self.sourceArray[indexPath.row] ;
        ((WSDetalViewController *)detalCtrl).msgBean = self.msgArray;

    }
    [self markAsReadedByMsg:msgBean];
//    SFA-25703 donghong
    [self orderByPubdateDate];
    [self.tableView reloadData];
    detalCtrl.hidesBottomBarWhenPushed = YES;
    [[self getNavigationController] pushViewController:detalCtrl animated:YES];
    
}

- (void)markAsReadedByMsg:(WSMsgsBean_msg *)msg {
    if (!msg || !msg.s || !msg.Id) {
        return;
    }
    
    if (![msg.isread isEqualToString:@"1"]) {
//        [[WSBaseMsgTable sharedTable] updateWithNames:@[@"isread"] values:@[@"1"] whereName:@[@"_id"] whereValue:@[msg.Id]];
        [[WSBaseMsgStoreTable sharedTable] updateWithNames:@[@"isread"] values:@[@"1"] whereName:@[@"msg_id",@"store_id"] whereValue:@[msg.Id,msg.store_id]];

    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID],msg.store_id];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    
    NSNumber *number = [dic objectForKey:key];
    if (number == nil || ![number boolValue]) {
        [self sendReadedMessageRequestByMsg:msg];
    }
    
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (value) {
        [dicInfo setObject:value forKey:key];
    }
    
    if (dicInfo) {
        [user setObject:dicInfo forKey:kWSMessageDomainName];
    }
    
    [user synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}
- (void)sendReadedMessageRequestByMsg:(WSMsgsBean_msg *)msg {
    if (!msg || !msg.s || !msg.Id) {
        return;
    }
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *md5 = [NSString md5:[NSString stringWithFormat:@"%@%@%@%@",empId,bizDate, msg.s, msg.Id]];
    
    NSString  *strData = [WSJSONBuilder  buildSendRedMessageWithMsgId:msg.Id andNotifyName:notifyID andMD5:md5];
    // 先插入数据库
    [self insertUploadData:strData URL:URL_UPLOAD MD5:md5 IsPhoto:NO NotifyName:notifyID];
    
    // 再上传数据，后更新upload_flag
    WSRequestHelper *uploadHandler = [WSRequestHelper shareInstance];
    [uploadHandler sendReadedMessageRequestWithMsgId:msg.Id andNotifyName:notifyID andMD5:md5];
}
#pragma mark - insert off line table
-(void) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return;
    }
    
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
        
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 为保存向前兼容，不修改其它调用此方法的类，将之前使用此方法保存的数据都定为 D 类型
    [l_Values addObject:@"D"];
    
    //图片类型的存储图片路径，其他类型不需要使用，保持兼容，存个null
    [l_Values addObject:[NSNull null]];
    
    [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
}

//-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    WSMsgsBean_msg *fliter_msg = [self filterIs_SlideMessage];
//    if (!(fliter_msg && [fliter_msg.headrail isEqualToString:@"1"]))
//        view.tintColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (INTERFACE_IS_PHONE) {
//        CGFloat height = INTERFACE_IS_PAD ? 200 : 130;
//        WSServerIPList *svip =  [WSAppData getObjectbyKey:SERVERURL];
//        WSServerIPController *serverIP =[svip.serverIPArray firstObject];
//        WSMsgsBean_msg *msg_model = [self filterIs_SlideMessage];
//        NSString *stringURL = nil;
//
//        if ([msg_model.headrail isEqualToString:@"1"])
//        {
//            NSArray *urlArray = [msg_model.url componentsSeparatedByString:@","];
//            stringURL = [urlArray firstObject];
//            stringURL = [NSString stringWithFormat:@"%@%@",[serverIP ServerIPString],stringURL];
//            stringURL = [stringURL stringByReplacingOccurrencesOfString:@"//" withString:@"/"];//字符转换
//            UIImageView *headView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
//            headView.userInteractionEnabled = YES;
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
//            [headView addGestureRecognizer:tapGesture];
//            [[WSRequestHelper shareInstance] downloadImageWithUrl:stringURL imageView:headView];
//
//            return headView;
//        }
//        if(self.sourceArray.count > 0)
//        {
//            return self.searchBar;
//        }
//    }
    //    else{
    //        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 44)];
    //        titleLabel.backgroundColor = [UIColor whiteColor];
    //        titleLabel.text = @"最新公告";
    //        titleLabel.font = FONT_SIZE_PINGFANG_REGULAR(24);
    //        titleLabel.textAlignment = NSTextAlignmentCenter;
    //        titleLabel.contentMode = UIViewContentModeCenter;
    //        titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    //        return titleLabel;
    //    }
    
//    return nil;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
//    refresh.frame = CGRectMake((tableView.width - 67)/2.0 , (tableView.height - 35)/2.0, 67, 35);
//    [refresh addTarget:self action:@selector(updataInfo) forControlEvents:UIControlEventTouchUpInside];
//
//    UIImage *image = [UIImage imageNamed:@"more_refresh"];
//    [refresh setImage:image forState:UIControlStateNormal];
//    //[refresh setBackgroundImage:[UIImage scaleImage:image toSize:CGSizeMake(67, 35)] forState:UIControlStateNormal];
//   //[refresh setImage:[UIImage scaleImage:image toSize:CGSizeMake(67, 35)] forState:UIControlStateNormal];
//    return refresh;
//
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//
//    return 70.0;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    //    donghong MSTD-7694 没有公告信息 隐藏搜索
//    if (INTERFACE_IS_PHONE && self.sourceArray.count > 0) {
//        return [self getTableViewHeaderViewHeight];
//    }
//    return 0.0f;
//
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
