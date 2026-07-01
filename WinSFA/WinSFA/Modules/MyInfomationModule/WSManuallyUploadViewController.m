//
//  ManuallyUploadViewController.m
//  WinChannelFrameWork
//
//  Created by yang's on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSManuallyUploadViewController.h"
#import "WSOffLineUploadTable.h"
#import "WSRequestHelper.h"
#import "WSNavigationBar.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+TapAction.h"


#define kWSiPadButtonWidth 92
#define kWSiPadButtonHeight 36


@interface WSManuallyUploadViewController ()


@property (nonatomic,strong) UITableView *uploadTableView;
@property (nonatomic,strong) NSMutableArray *uploadArray;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSInteger totalUploadCount;
@property (nonatomic, assign) NSInteger totalUploadCountAtOneTurn;
@property (nonatomic, assign) NSInteger succeedUploadCount;
@property (nonatomic, assign) NSInteger failedUploadCount;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic,strong)UIButton *uploadErrorDataBtn;

@end

@implementation WSManuallyUploadViewController
@synthesize uploadArray = _uploadArray;


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
        [self loadUploadDatas];
        
        self.title = funcs.name;
        return self;
    }
    
    return self;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        [self loadUploadDatas];

        self.title = NSLocalizedString(@"manually_upload", nil);
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = self.currentFuncs.name;
    
    if (self.autoUploadDatas) {
        [self upload];
    }
    
    NSInteger pending = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    if (pending > 0) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    LogTrace();
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)uploadCountRefresh {
    [self loadUploadDatas];
    [_uploadTableView reloadData];
}


- (void)upload
{
    LogTrace();
    if (![self checkNetWorkState]) {
        NSString *title = NSLocalizedString(@"network_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [self loadUploadDatas];
    [_uploadTableView reloadData];
    
    WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
    NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
//    NSString *titleprompt = NSLocalizedString(@"js_alert_title", nil);
//    NSString *OK = NSLocalizedString(@"confirm", nil);
    if (pending > 0){
        self.totalUploadCount = pending;
        self.succeedUploadCount = 0;
        self.failedUploadCount = 0;
        
        NSString *Uploading = NSLocalizedString(@"uploading_please_wait_prompt", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:Uploading  tips:nil tapTarget:self action:nil];
        [self performSelector:@selector(doUpload) withObject:nil afterDelay:0.01];
    }
    else
    {
        NSString *notDatasToUpload = NSLocalizedString(@"no_data_to_upload", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:notDatasToUpload tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
- (BOOL)checkNetWorkState{
    Reachability *r =[Reachability reachabilityWithHostname:@"www.baidu.com"];
    if ([r currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}
- (void)doUpload
{
    [self uploadFailedDataWithCount:kAutoUploadCount];
}

- (void)update {
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [self loadUploadDatas];
    [_uploadTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
//    NSString *hasUpdated = NSLocalizedString(@"update_done_label", nil);
//
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:hasUpdated tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];

}

/*
 * 上传错误日志
 */
- (void)uploadErrorData
{
    LogTrace();
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_please_wait_prompt", nil) tips:nil tapTarget:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadErrorLogFinished:) name:kUploadImageNilFinishNotifyName object:nil];
    
    [[WCLogManager sharedInstance] startUploadLog:UploadLogTypedImageNilError];
}

/*
 * 上传错误日志完成
 */
- (void)uploadErrorLogFinished:(NSNotification *)sender
{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *string = NSLocalizedString(@"fail_upload", nil);
    if ([sender userInfo] != nil && [[[sender userInfo] objectForKey:kUploadAllLogDataResultKey] boolValue]) {
        string = NSLocalizedString(@"upload_success", nil);
        // 是否修改离线数据库中的错误数据的flag标记
        [[WSOffLineUploadTable sharedTable] updateErrorToUploadedError];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    [self uploadCountRefresh];
}


// 加载上传的初始化数据
-(void)loadUploadDatas
{
    WSOffLineUploadTable* outLineUploadTable = [WSOffLineUploadTable sharedTable];
    if (_uploadArray) {
        [_uploadArray removeAllObjects];
        
    } else {
        _uploadArray=[[NSMutableArray alloc]init ];
    }

    //NSInteger total = [outLineUploadTable queryCountWithUploadFlagType:All];
    NSInteger succcess = [outLineUploadTable queryCountWithUploadFlagType:Success];
    NSInteger pending = [outLineUploadTable queryCountWithUploadFlagType:Failed];
    //[_uploadArray addObject: [NSString stringWithFormat:@"%d",total ]];
    [_uploadArray addObject: [NSString stringWithFormat:@"%ld",(long)succcess ]];
    [_uploadArray addObject: [NSString stringWithFormat:@"%ld",(long)pending ]];

     // titleArray
    if (_titleArray) {
        [_titleArray removeAllObjects];
    } else {
        _titleArray = [[NSMutableArray alloc] init];
    }
    
    
   //NSString *totalUpload = NSLocalizedString(@"all_upload_data_num", nil);
    NSString *beenUpload = NSLocalizedString(@"upload_data_num", nil);
    NSString *notUpload = NSLocalizedString(@"to_upload_data_num", nil);
    //[_titleArray addObject:totalUpload];
    [_titleArray addObject:beenUpload];
    [_titleArray addObject:notUpload];
    
    if (_imageArray) {
        [_imageArray removeAllObjects];
    }else{
        _imageArray =[[NSMutableArray alloc]init];
    }
    [_imageArray addObject:@"yscsjts_icone"];
    [_imageArray addObject:@"dscts_icon"];
   
    //// 显示错误信息数据
    NSInteger error = [outLineUploadTable queryCountWithUploadFlagType:Error];
    if (error > 0) {
         NSString *errorUpload = NSLocalizedString(@"error_data", nil);
        [_uploadArray addObject: [NSString stringWithFormat:@"%ld",(long)error ]];
        [_titleArray addObject:errorUpload];
        [_imageArray addObject:@""];
        [self.uploadErrorDataBtn setHidden:NO];
         self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:self.uploadErrorDataBtn];
        
    }
    else
    {
//        if (pending > 0) {
            /*上传按钮*/
            
            UIBarButtonItem *uploadBarItem = [self barButtonItemImage:@"icon_upload" target:self action:@selector(upload)];
            if (self.m_ParentViewController) {
                self.m_ParentViewController.navigationItem.rightBarButtonItem = uploadBarItem;
            }else{
                self.navigationItem.rightBarButtonItem = uploadBarItem;
                
            }
            
            
//            
//        }else {
//            /*跟新按钮*/
//             UIBarButtonItem *updateBarItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"refresh", nil)
//                                                                                style:UIBarButtonItemStyleDone
//                                                                               target:self
//                                                                               action:@selector(update)];
//            
//            if (self.m_ParentViewController) {
//                self.m_ParentViewController.navigationItem.rightBarButtonItem = updateBarItem;
//            }else{
//                self.navigationItem.rightBarButtonItem = updateBarItem;
//                
//            }
//        }
        
    }
}

- (void)timerAction{

    [self uploadCountRefresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUploadDatas];
    
    NSArray *vcs = self.navigationController.viewControllers;
    if (vcs.count >2) {
        [self backItemAction:@selector(backAction) target:self];
    }else{
        if (!self.m_ParentViewController) {
            UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
            
            [backBtn setBackgroundColor:[UIColor clearColor]];
            
            [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
            
//            [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
            
            [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
            self.navigationItem.leftBarButtonItem=homeButtonItem;
        }
       
    }
    
    [self.view removeAllSubviews];
    _uploadTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _uploadTableView.delegate=self;
    _uploadTableView.dataSource=self;
    [self.view addSubview:_uploadTableView];
    _uploadTableView.scrollEnabled=NO;
    _uploadTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _uploadTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    _uploadTableView.rowHeight = 44;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem *errorDataBtnrItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"upload_error_data", nil)
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(uploadErrorData)];
    
    if (self.m_ParentViewController) {
        self.m_ParentViewController.navigationItem.rightBarButtonItem = errorDataBtnrItem;
    }else{
        self.navigationItem.rightBarButtonItem  = errorDataBtnrItem;
        
    }
    
    [self uploadCountRefresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldPauseBackAction
{
    if (self.isInCheckUploadedDataFlow) {
        NSString *checkUploadFlag = [WSAppData getObjectbyKey:CHECK_UPLOADED_DATA];
        if ([checkUploadFlag isEqualToString:@"2"]) {
            WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
            NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
            if (pending > 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)backAction
{
    if (self.isInCheckUploadedDataFlow) {
        NSString *checkUploadFlag = [WSAppData getObjectbyKey:CHECK_UPLOADED_DATA];
        if ([checkUploadFlag isEqualToString:@"2"]) {
            WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
            NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
            if (pending > 0) {
                NSString *title = NSLocalizedString(@"please_upload_data", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.autoUploadDatas) {
        if ([self.delegate respondsToSelector:@selector(manualUploadBackAction)]) {
            [self.delegate manualUploadBackAction];
        }
    }
    
}

- (void)uploadFailedDataWithCount:(NSInteger)count
{
    
    NSArray* l_failedDatas = [[WSOffLineUploadTable sharedTable] queryWithUploadFlagType:Failed];
    self.totalUploadCountAtOneTurn = [l_failedDatas count];
    WSRequestHelper* l_WSRequestHelper = [WSRequestHelper shareInstance];
    for (WSOffLineUploadObject* object in l_failedDatas)
    {
        NSString* l_notify = object.notify;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishRequest:)
                                                     name:l_notify
                                                   object:nil];
        LogInfo(@"uploadFailedData%@",object);
       [l_WSRequestHelper uploadFailedData:object];
    }
}

-(void)finishRequest:(id)sender
{
    LogTrace();
    NSNotification *notification = (NSNotification *)sender;
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:[notification name]
//                                                  object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *requstIsForPhoto = [userInfo objectForKey:REQUEST_IS_FOR_PHOTO];
    NSError *error = [userInfo objectForKey:ERROR];
    
    if (error && error.code != 0) {
        LogError(@"LogError %@",error);
        self.failedUploadCount++;
    }
    else
    {
        LogInfo(@"offline-response notify name is %@",[notification name]);
        BOOL isSuccess = YES;
        NSString *datas = [[notification userInfo] objectForKey:DATAS];
        NSDictionary *responesDictionary = [datas objectFromJSONString];
        NSString *result = [responesDictionary objectForKey:@"result"];
        NSArray *resultAllKeys = [responesDictionary allKeys];
        
        if (datas) {
            // 新的判断离线数据上传是否成功的逻辑和安卓保持一致
            if (requstIsForPhoto && [requstIsForPhoto isKindOfClass:[NSString class]] && [requstIsForPhoto isEqualToString:@"1"]) {
                LogInfo(@"上传照片的返回数据");
                if ([result isKindOfClass:[NSString class]] && [result isEqualToString:@"1"]) {
                    isSuccess = YES;
                }else {
                    isSuccess = NO;
                }
            }else {
                LogInfo(@"上传非照片的返回数据");
                if ([resultAllKeys containsObject:@"result"] && [result isEqualToString:@"1"] ) {
                    isSuccess = YES;
                }else{
                    isSuccess = NO;
                }
            }
            
            /*
            if (result) {
                if ([result length] > 1) {
                    NSDictionary *resultDic = [result objectFromJSONString];
                    NSString *flag = [resultDic objectForKey:@"flag"];
                    if (flag && [flag isKindOfClass:[NSNumber class]]) {
                        flag = [(NSNumber*)flag stringValue];
                    }
                    if (flag && [flag isEqualToString:@"1"]) {
                        isSuccess = YES;
                    } else {
                        isSuccess = NO;
                    }
                } else {
                    if ([result isEqualToString:@"1"]) {
                        isSuccess = YES;
                    }else {
                        isSuccess = NO;
                    }
                }
            }
             */
        } else {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        if (isSuccess) {
            self.succeedUploadCount++;
            [self uploadCountRefresh];
        }else {
             self.failedUploadCount++;
             LogError(@"请求返回数据datas--%@",datas);
        }
    }

    LogInfo(@"\failed:%ld,succeed:%ld",(long)self.failedUploadCount,(long)self.succeedUploadCount);

    if ((self.failedUploadCount + self.succeedUploadCount) >= self.totalUploadCountAtOneTurn)
    {
        
        self.totalUploadCount -= self.succeedUploadCount;
        
        if (self.failedUploadCount >= 3 || (self.failedUploadCount == self.totalUploadCount && self.failedUploadCount > 0))
        {
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            
            NSString *resultString = [NSString stringWithFormat:NSLocalizedString(@"data_upload_fail", nil),self.failedUploadCount];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:resultString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            self.failedUploadCount = 0;
            self.succeedUploadCount = 0;
        }
        else
        {
            self.failedUploadCount = 0;
            self.succeedUploadCount = 0;
            
            if (self.totalUploadCount > 0) {
                NSLog(@"\n\n\n\n\n\noffline-  again  --\n\n\n\n\n\n");
                [self uploadFailedDataWithCount:kAutoUploadCount];
            }
            else
            {
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"upload_success", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
                
                if (self.autoUploadDatas) {
                    [self backAction];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
        
    }
}

#pragma Mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: SimpleTableIdentifier];
    }
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [cell.contentView removeAllSubviews];
    NSString *imageStr =[self.imageArray objectAtIndex:indexPath.row];
    UIImage * image = [UIImage scaledImageForName:imageStr ofType:@"png"];
    if(INTERFACE_IS_PAD){
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 5, cell.contentView.frame.size.height - 10, cell.contentView.frame.size.height - 10)];
        imageView.image = image;
        [cell.contentView addSubview:imageView];
        UILabel* textLabel=[[UILabel alloc] initWithFrame:CGRectMake(100, 0, _uploadTableView.frame.size.width, cell.contentView.frame.size.height)];
        textLabel.backgroundColor=[UIColor clearColor];
        textLabel.text=[self.titleArray objectAtIndex:indexPath.row];
        textLabel.font = [UIFont systemFontOfSize:UI_Font];
        textLabel.textColor = MAIN_TEXT_COLOR;
        [cell.contentView addSubview:textLabel];

        UILabel* detailTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(_uploadTableView.frame.size.width-150, 0, 70, cell.contentView.frame.size.height)];
        detailTextLabel.backgroundColor=[UIColor clearColor];
        detailTextLabel.text=[self.uploadArray  objectAtIndex:indexPath.row];
        [cell.contentView addSubview:detailTextLabel];
    }else{
        cell.textLabel.text=[self.titleArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
        cell.textLabel.textColor = MAIN_TEXT_COLOR;
        cell.detailTextLabel.text=[self.uploadArray  objectAtIndex:indexPath.row];
        
        cell.imageView.contentMode = UIViewContentModeLeft;
        cell.imageView.image = image;
        
    }
    
    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height, cell.contentView.width, 1)];
    labelLine.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
    labelLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [cell.contentView addSubview:labelLine];
    
    return cell;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UIButton*)uploadErrorDataBtn{
    if (_uploadErrorDataBtn==nil) {
        _uploadErrorDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadErrorDataBtn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
        [_uploadErrorDataBtn setBackgroundImage:[[UIImage imageNamed:@"icon_upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    return _uploadErrorDataBtn;
}

@end
