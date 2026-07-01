//
//  MsgViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define UPDATA_MSG @"updataMassage"


#import "WSMsgViewController.h"
#import "WSAppData.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "SubMsgsViewController.h"
#import "WSFuncsBean.h"
#import "WSMsgContentController.h"
#import "WSMsgsBean_msg.h"
#import "WSRequestHelper.h"
//#import "ConfigFileController.h"
#import "WSSubMsgsViewController.h"
#import "WSMsgContentViewController.h"
#import "WSManuallyUploadViewController.h"
#import "WSNavigationBar.h"

#import "WSMsgAlertView.h"

@interface WSMsgViewController()

@property (nonatomic, strong) UIViewController *iMsgContent;
@property (nonatomic, strong) WSFuncsBean *subFuncBean;
@property (nonatomic, strong) UIButton  *btnTmp;

@end

@implementation WSMsgViewController
@synthesize titlesTableView = _titlesTableView;
@synthesize segment = _segment;
@synthesize dataArray = _dataArray;
@synthesize alert;
//@synthesize content;
@synthesize iMsgContent = _iMsgContent;
@synthesize manuallyupload = manuallyupload_;
@synthesize subFuncBean = _subFuncBean;

#pragma mark -private mathod

-(void)updateMsgInfo
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([self.dataArray count] > 0) {
        [user removeObjectForKey:kWSMessageDomainName];
        NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] initWithCapacity:16];
        if (bizDate) {
            [dicInfo setObject:bizDate forKey:kWSMessageBizDate];
        }
        
        if (dicInfo) {
            [user setObject:dicInfo forKey:kWSMessageDomainName];
        }
        
        [user synchronize];
    }
    for(WSMsgsBean* aMsg in self.dataArray)
    {
        for (WSMsgsBean_msg *msg in aMsg.msg) {
            if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
                NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:key];
                if (dicInfo) {
                    [user setObject:dicInfo forKey:kWSMessageDomainName];
                }
                
                [user synchronize];
            }
        }
    }
}

-(int)getHasReadCountByMsg:(WSMsgsBean*)aMsg
{
    int i = 0;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    for (WSMsgsBean_msg *msg in aMsg.msg) {
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        id obj = [dic objectForKey:key];
        if (obj != nil) {
            i++;
        }
    }
    return i;
}


-(void)setAccessFlag:(UITableViewCell*)cell Msg:(WSMsgsBean*)aMsg
{
    //如果阅读完所有的消息，就不画point.png
    NSInteger hasReadCount= [self getHasReadCountByMsg:aMsg];
    NSInteger totallCount = [aMsg.msg count];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld/%ld)",aMsg.name,(long)hasReadCount,(long)totallCount];
}

-(void)uploadFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATA_MSG object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) 
    {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
//        [self updateMsgInfo];
        NSDictionary *uploadState = [info objectFromJSONString];
        WSMsgBeanArray* msgArray = [[WSMsgBeanArray alloc] initWithObject:uploadState];
        [WSAppData putObject:msgArray forKey:MSGS];
        
        [self.dataArray removeAllObjects];
        WSMsgBeanArray* messageArray = [WSAppData getObjectbyKey:MSGS];
        
        NSArray *arrays = nil;
        if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0) {
            arrays = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
        }
        
        if (arrays == nil) {
            self.dataArray = [NSMutableArray arrayWithArray:messageArray.msgArray];
        }else{
            self.dataArray = [NSMutableArray arrayWithArray:arrays];
        }
//        [self updateMsgInfo];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        //更新完成后对userdefault重新处理
    }
    
    [self.titlesTableView reloadData];
}
-(void)updataInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:UPDATA_MSG 
                                               object:nil];
    
    
    [[WSRequestHelper shareInstance] postRequestMSGWithType:nil];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
     NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];}

- (void)setCompanyInfo
{    
//    UIView* view = [[UIView alloc]init];
//    self.titlesTableView.tableFooterView = view;
    [self.iMsgContent.view removeFromSuperview];
    [self.view addSubview:self.titlesTableView];
    
    [self.dataArray removeAllObjects];
    WSMsgBeanArray* messageArray = [WSAppData getObjectbyKey:MSGS];
    for (int j=0; j<[messageArray.msgArray count]; j++) {
        WSMsgsBean *msgsB=[messageArray.msgArray objectAtIndex:j];
        if ([msgsB.name isEqualToString:@"总裁致词"]) {
            [messageArray.msgArray  removeObjectAtIndex:j];
        }
    }
    
    NSArray *msgsArray = nil;
    if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0) {
        msgsArray = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
    }
    if (msgsArray != nil) {
        [self.dataArray addObjectsFromArray:msgsArray];
    }else{
        [self.dataArray addObjectsFromArray:messageArray.msgArray];
    }
        
    NSString *tmpString = NSLocalizedString(@"refresh",nil);
    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                               initWithTitle:tmpString 
                               style: UIBarButtonItemStylePlain
                               target:self 
                               action:@selector(updataInfo)];
    self.navigationItem.rightBarButtonItem = updata;
    

    
}

- (void)setWorkInfoWithHomePage:(BOOL)isHomePageSign
{

    
    [self.dataArray removeAllObjects];
    
    WSMsgBeanArray* messageArray = [WSAppData getObjectbyKey:MSGS];
    NSInteger count = [messageArray.msgArray count];
    if(count==0) return;
    
    NSArray *msgsArray = nil;
    __block WSMsgsBean* workMsgBean = nil;
    __block WSMsgsBean_msg *msgsB_msg = nil;
    if (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0) {
        msgsArray = [messageArray getMsgsBeansWithFilter:self.currentFuncs.filter];
        if (msgsArray != nil) {
            WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:0];
            [msgsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                workMsgBean = (WSMsgsBean*)obj;
                for (WSMsgsBean_msg *msg in workMsgBean.msg) {
                    if (msg.typcode != nil && [msg.typcode isEqualToString:subfuncs.filter]) {
                        msgsB_msg = msg;
                        self.title = subfuncs.name;
                    }
                }
            }];
        }
    }
    
    if (msgsB_msg == nil)
    {
        /*  原来的逻辑是：取消息数组的最后数据
         workMsgBean = [messageArray.msgArray objectAtIndex:count-1];
         msgsB_msg = [workMsgBean.msg objectAtIndex:0];
         */
        // 新逻辑：根据cod过滤“工作重点”
        for (WSMsgsBean*  workMsgB in messageArray.msgArray)
        {
            NSString *filter = self.subFuncBean.filter;
            if (filter && [filter isEqualToString:workMsgB.cod]) {
                workMsgBean = workMsgB;
                break;
            }
        }
        /*
         firstObjet  如workMsgBean.msg不存在 则msgB_msg = nil
         若用objectAtIndex = 0 如workMsgBean.msg不存在 会崩溃
         */
        msgsB_msg = [workMsgBean.msg firstObject];
    }
    
    UIViewController *controller;
    if ([workMsgBean.msg count] > 1) {
        controller = [[WSSubMsgsViewController alloc] initWithMsgsBean:workMsgBean];
    }
    else
    {
        // 辉瑞系列新需求
        if ([workMsgBean.cod isEqualToString:@"msgAlter"] && INTERFACE_IS_PAD) {
            // to  do something
            [self createAlterViewWith:msgsB_msg];
            return;
        } else {
            WSMsgContentViewController *msgContentVC = [[WSMsgContentViewController alloc] initWithMessage:msgsB_msg];
            msgContentVC.isHomePageSign = isHomePageSign;
            controller = msgContentVC;
        }
    }
    
    [self.iMsgContent removeFromParentViewController];
    self.iMsgContent = controller;
    [self addChildViewController:self.iMsgContent];
    //此处未兼容所有情况，有变化需要修正一下。
    self.iMsgContent.view.frame = self.titlesTableView.frame;
    self.iMsgContent.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.iMsgContent.view];
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)setWorkInfo
{
    [self setWorkInfoWithHomePage:NO];
}

//Add by WangXiaotang
- (void) setManuallyUploadInfo
{
    self.navigationItem.rightBarButtonItem = nil;
    [self.dataArray removeAllObjects];
    WSManuallyUploadViewController* upload = [[WSManuallyUploadViewController alloc]initWithNibName:@"WSManuallyUploadViewController"
                                            bundle:nil];
    [upload.view setFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height - 20 - 44)];
    [upload uploadCountRefresh];
    self.titlesTableView.tableFooterView = upload.view;
    self.manuallyupload = upload;
}

- (void)valueChange:(id)sender{
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    NSInteger seleted = sc.selectedSegmentIndex;
    self.subFuncBean = [self.currentFuncs.funcsArray objectAtIndex:seleted];
    if (self.subFuncBean && [self.subFuncBean.fv rangeOfString:@"TAB_V1001"].length > 0) {
        [self setWorkInfo];
    }else if (self.subFuncBean && ([self.subFuncBean.fv rangeOfString:@"TAB_V1002"].length > 0 || [self.subFuncBean.fv rangeOfString:@"TAB_V1005"].length > 0)){
        [self setCompanyInfo];
    }
    [self.titlesTableView reloadData];
}


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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.titlesTableView reloadData];
}

-(int) initializationSelectSegment
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *fcValue = [mobileHomeDic objectForKey:MobileHomePageFcKey];
            for(int i = 0 ; i < [self.currentFuncs.funcsArray count];i++) {
                WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
                if ([subfuncs.fc isEqualToString:fcValue]) {
                    return i;
                }
            }
        }
    }
    
    return -1;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    BOOL isHomePage = YES;
    int normalSelect = [self initializationSelectSegment];
    if (normalSelect == -1) {
        isHomePage = NO;
        normalSelect = 0;
    }
    
    UIView *view =nil;
    UISegmentedControl *segmentedcontrol = nil;
    if(self.currentFuncs.funcsArray.count>1){
        self.subFuncBean = [self.currentFuncs.funcsArray objectAtIndex:0];
        //分段控件内容
        NSMutableArray* segmentTitlesArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < [self.currentFuncs.funcsArray count];i++)
        {
            WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
            
            [segmentTitlesArray addObject:subfuncs.name];
        }
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kSegmentedControlTopGap + kSegmentedControlHeight + kSegmentedControlBottomGap)];
        view.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        segmentedcontrol = [[UISegmentedControl alloc] initWithItems:segmentTitlesArray];
//        segmentedcontrol.segmentedControlStyle = UISegmentedControlStylePlain;
        CGFloat width = INTERFACE_IS_PHONE ? self.view.bounds.size.height : ([segmentTitlesArray count] * 150);
        if (width > self.view.bounds.size.width) {
            width = self.view.bounds.size.width;
        }
        segmentedcontrol.frame = CGRectMake((view.bounds.size.width - width)/2, kSegmentedControlTopGap, width, kSegmentedControlHeight);
        [segmentedcontrol addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        
        if (INTERFACE_IS_PAD) {
            UIColor* selectedColor= MAIN_TINT_COLOT;
            if (!selectedColor) {
                selectedColor = [UIColor colorWithRed:0.0 green:147.0/255.0 blue:208.0/255.0 alpha:1.0];
            }
            
            segmentedcontrol.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            segmentedcontrol.layer.cornerRadius = kSegmentedControlHeight / 2.0f;
            segmentedcontrol.clipsToBounds = YES;
            segmentedcontrol.layer.borderWidth = 1.0;
            segmentedcontrol.layer.borderColor = [selectedColor CGColor];
            
        }
        [view addSubview:segmentedcontrol];
        [self.view addSubview: view];
    }
    
    //tableview
    CGRect tableViewRect = self.view.bounds;
    tableViewRect.origin.y = view.height;
    tableViewRect.size.height =  CGRectGetHeight(self.view.bounds) - view.height;

    
    UITableView* tv = [[UITableView alloc]initWithFrame:tableViewRect style:UITableViewStylePlain];
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tv setDelegate:self];
    [tv setDataSource:self];
    tv.tableFooterView = [[UIView alloc]init];
    self.titlesTableView = tv;
    self.titlesTableView.scrollEnabled = YES;
    [self.view addSubview:self.titlesTableView];
    //数据
    NSMutableArray* array = [[NSMutableArray alloc]init];
    self.dataArray = array;
    
    if (segmentedcontrol) {
        [segmentedcontrol setSelectedSegmentIndex:MAX(normalSelect, 0)];
    }
    
    if ([self.currentFuncs.funcsArray count] > normalSelect + 1) {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex: normalSelect];
        if ([subfuncs.fv isKindOfClass:[NSString class]] && ([subfuncs.fv isEqualToString:@"TAB_V1005"] || [subfuncs.fv isEqualToString:@"TAB_V1002"]))
        {
            [self setCompanyInfo];
        }else{
            [self setWorkInfoWithHomePage:isHomePage];
        }
    }
    
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:nil target:nil];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initializationBackItemAction];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.titlesTableView = nil;
    self.segment = nil;
    self.dataArray = nil;
    self.currentFuncs = nil;
    self.manuallyupload = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    WSMsgsBean* message = [self.dataArray objectAtIndex:indexPath.row];
    [self setAccessFlag:cell Msg:message];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    WSSubMsgsViewController *subMsgsVC = [[WSSubMsgsViewController alloc] initWithMsgsBean:message];
    LogInfo(@"Going to class WSSubMsgsViewController");
    
    subMsgsVC.title = message.name;
    subMsgsVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:subMsgsVC animated:YES];
}

#pragma mark

- (void)createAlterViewWith:(WSMsgsBean_msg *)msgBean {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    WSMsgAlertView *alterView = [[WSMsgAlertView alloc] initWithFrame: window.rootViewController.view.bounds msgBean:msgBean];
    [window.rootViewController.view addSubview:alterView];

}

@end
