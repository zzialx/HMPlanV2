//
//  WSDiagnosticTestViewController.m
//  WinSFA
//
//  Created by yang on 13-9-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSDiagnosticTestViewController.h"
#import "WCLogManager.h"
#import "WSVisualDiagnosticTestView.h"
#import "WCBaseResponse.h"
#include <sys/time.h>

#define k_ScrollViewLeftSpace (INTERFACE_IS_PHONE ? 10.0f : 20.0f)
#define k_LabelLeftSpace (INTERFACE_IS_PHONE ? 5.0f : 10.0f)
#define k_BorderColor [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0f]

// 网络连接测试地址
#define WEB_CONNECT_TEST_URL [NSString stringWithFormat:@"%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]]
#define SERVER_CONNECT_TEST_URL [NSString stringWithFormat:@"%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]]
#define SERVER_DOWNLOAD_TEST_URL [NSString stringWithFormat:@"%@images/ring.jpg", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]]

#define SERVER_HOST_CONNECT_TEST_URL @"http://118.144.79.231:8088/"
#define SERVER_HOST_DOWNLOAD_TEST_URL @"http://118.144.79.231:8088/images/ring.jpg"
#define BAIDU_WEB_CONNECT_TEST_URL @"https://www.baidu.com/"

// 测试连接类型（可扩充）
#define TEST_GET_SERVER_LONG_TIME    1
#define TEST_HTTP_DOWNLOAD           2

@interface WSDiagnosticTestViewController ()
{
    UIView *_routeUrlTestView;
    NSArray *_visualTestContentDataArray;
    NSArray *_visualTestUrlDataArray;
    NSArray *_visualTestTitleDataArray;
    WinAFHTTPRequestOperationManager *_manager;
}
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation WSDiagnosticTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _visualTestContentDataArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"web_connect", nil) ,NSLocalizedString(@"server_connect", nil),NSLocalizedString(@"server_download",nil),NSLocalizedString( @"win_connect", nil),NSLocalizedString(@"win_download", nil), @"baidu", nil];
    
    _visualTestUrlDataArray = [[NSArray alloc] initWithObjects:WEB_CONNECT_TEST_URL, SERVER_CONNECT_TEST_URL, SERVER_DOWNLOAD_TEST_URL, SERVER_HOST_CONNECT_TEST_URL, SERVER_HOST_DOWNLOAD_TEST_URL, BAIDU_WEB_CONNECT_TEST_URL, nil];
    _visualTestTitleDataArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"test_content", nil) ,NSLocalizedString(@"test_Progress",nil),NSLocalizedString(@"time",nil) ,NSLocalizedString(@"result", nil) ,nil];

    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    
    [backBtn setBackgroundColor:[UIColor clearColor]];
    
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    
    if (INTERFACE_IS_PAD) {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg_lanscape.png"]];
    }
    else if (IS_IPHONE5)
    {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg-568h@2x.png"]];
    }
    else
    {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg.png"]];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"upload_diagnosis_log", nil)
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(uploadDiagnoseLog)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:ROOT_CONFIG_USERDEFAULT_KEY];
    NSMutableString *configString = [NSMutableString string];
    if (dic && [dic count] > 0) {
        NSArray *allKeys = [dic allKeys];
        for (NSString *key in allKeys) {
            NSString *content = [dic stringForKey:key withDefault:@""];
            [configString appendString:[NSString stringWithFormat:@" %@ : %@\n\n",key,content]];
        }
    }
    else
    {
        [configString appendString:NSLocalizedString(@"no_config_data", nil)];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(k_ScrollViewLeftSpace, k_ScrollViewLeftSpace, self.view.bounds.size.width - 2 * k_ScrollViewLeftSpace, self.view.bounds.size.height - 2 * k_ScrollViewLeftSpace)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    scrollView.layer.borderWidth = 1.0f;
    scrollView.layer.borderColor = [k_BorderColor CGColor];
    scrollView.layer.cornerRadius = 4;
    
    [self setupRouteUrlTestViewWithFrame:scrollView.frame];
    
    [scrollView addSubview:_routeUrlTestView];
    
    UIFont *font = [UIFont fontForKey:@"NormalContentTextFont"];
    CGSize size = [configString ws_sizeWithFont:font constrainedToWidth:scrollView.bounds.size.width - 2 * k_LabelLeftSpace lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelLeftSpace, _routeUrlTestView.frame.size.height + 10, size.width, size.height)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelLeftSpace, 10, size.width, size.height)];
    [label setText:configString];
    [label setFont:font];
    [label setTextColor:[UIColor blackColor]];
    label.numberOfLines = 0;
    
    [scrollView addSubview:label];
    scrollView.contentSize = CGSizeMake(size.width, size.height + _routeUrlTestView.frame.size.height);
    [self.view addSubview:scrollView];
    
}

// 增加对服务器网络、机房网络、访问百度等地址是否正常的检测
- (void)setupRouteUrlTestViewWithFrame:(CGRect)frame
{
    _routeUrlTestView = [[UIView alloc] initWithFrame:CGRectMake(k_LabelLeftSpace, 5, frame.size.width - 2 * k_LabelLeftSpace, 40*[_visualTestContentDataArray count] + 40)];
    
    for (int i = 0; i < [_visualTestTitleDataArray count]; i ++) {
        UILabel *topTitleLabel = [[UILabel alloc] init];
        topTitleLabel.font = [UIFont systemFontOfSize:14.0];
        topTitleLabel.textAlignment = NSTextAlignmentCenter;
        topTitleLabel.text = [_visualTestTitleDataArray objectAtIndex:i];
        
        if (i < 2) {
            [topTitleLabel setFrame:CGRectMake(_routeUrlTestView.frame.size.width/3*i, 0, _routeUrlTestView.frame.size.width/3, 30)];
        }else{
            [topTitleLabel setFrame:CGRectMake(_routeUrlTestView.frame.size.width/3*2 + _routeUrlTestView.frame.size.width/3/2*(i - 2), 0, _routeUrlTestView.frame.size.width/3/2, 30)];
        }
        
        [_routeUrlTestView addSubview:topTitleLabel];
    }
    
    
    for (int i = 0; i < [_visualTestContentDataArray count]; i ++) {
        WSVisualDiagnosticTestView *testView = [[WSVisualDiagnosticTestView alloc] initWithFrame:CGRectMake(0, 40*i + 25, _routeUrlTestView.frame.size.width, 40) andTestContentString:[NSString stringWithFormat:@"%d.%@", i + 1, [_visualTestContentDataArray objectAtIndex:i]]];
        int requestType = 0;
        
        if (i < 2) {
            requestType = TEST_GET_SERVER_LONG_TIME;
        }else{
            requestType = TEST_HTTP_DOWNLOAD;

        }
        
        [self visualNetDiagnosisStartedWithTestView:testView andUrlString:[_visualTestUrlDataArray objectAtIndex:i] andRequestType:requestType];
        
        [_routeUrlTestView addSubview:testView];
    }

}

// 每条测试添加异步网络请求到队列
- (void)visualNetDiagnosisStartedWithTestView:(WSVisualDiagnosticTestView *)testView andUrlString:(NSString *)urlString andRequestType:(int)requestType
{
    _manager = [WinAFHTTPRequestOperationManager manager];

    [_manager setRequestSerializer:[WinAFJSONRequestSerializer serializer]];
    [_manager.requestSerializer setHTTPShouldHandleCookies:NO];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"image/jpeg", nil];
    
    long long timeBefore = [self getUSeconds];
    
//    NSLog(@"timeBeforeSending = %lld", timeBefore);
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:kHttpMethodGET URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:nil error:nil];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    WinAFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        
//        NSLog(@"responseObject = %@",responseObject);
//        NSLog(@"timeAfterSending = %lld distance = %lld ms", [self getUSeconds], ([self getUSeconds]-timeBefore)/1000);
//        NSLog(@"---allHeader:%@", operation.response.allHeaderFields);
        if ([operation.response.allHeaderFields objectForKey:@""] == nil || [[operation.response.allHeaderFields objectForKey:@""] isEqualToString:@""]) {
            [testView setProgressAndTextWhenTestFinishedWithUseTime:([self getUSeconds]-timeBefore)/1000];
        }

    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        if (error.code == -1003) {
            NSString *title = NSLocalizedString(@"network_failure", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead,long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //bytesRead,上次读取的数据  //totalBytesRead,目前为止总共读取的数据 //totalBytesExpectedToRead,预测的文件大小
//        NSLog(@"invokeAsyncronousSTREAMING - Received %lld of %lld bytes  bytesRead = %ld bytes", totalBytesRead, totalBytesExpectedToRead, bytesRead);
        if (totalBytesExpectedToRead < 0) {
            
        }else{
            CGFloat progress = (CGFloat)totalBytesRead/totalBytesExpectedToRead;
//            NSLog(@"progress = %.6f", progress);
            [testView setProgress:progress andTextWhenTestFinishedWithUseTime:([self getUSeconds]-timeBefore)/1000];
        }


    }];
    
    
    if ([_manager.operationQueue operationCount] > 0) {
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }
    
    [_manager.operationQueue addOperation:operation];
}


// 获取本地时间
- (long long)getUSeconds
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_usec + time.tv_sec*1000000;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([_manager.operationQueue operationCount] > 0) {
        [_manager.operationQueue cancelAllOperations];
    }
}

- (void)uploadDiagnoseLog
{
    // 先判断是否弹出日期，超出4，则弹出
    NSString * logMaxCount = [[NSUserDefaults standardUserDefaults] stringForKey:LOG_FILE_COUNT];
    logMaxCount = (logMaxCount ? logMaxCount : @"4" );
    if ([logMaxCount integerValue] > 4) {
        //弹出日期选择框
        
        WSPickerViewType pickerType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:UIDatePickerModeDate];
        
        NSDate *nowDate =[NSDate date];
        NSDate *maxDate = [NSDate date];
        NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-60*24*60*60];
        
        WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerType isAddDeleteButton:NO];
        [pickerView setDate:nowDate animated:YES];
        [pickerView setMaximumDate:maxDate];
        [pickerView setMinimumDate:minDate];
        
        __weak typeof(self) weakSelf = self;
        [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
            if (!isOK) {
                return;
            }
            NSDate *date = (NSDate *)data;
            NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
            [formatter setDateFormat: @"yyyy-MM-dd"];
            NSString *dateString = [formatter stringFromDate:date];
            
            [WCLogManager sharedInstance].selErrorDate = dateString;
            [WCLogManager sharedInstance].selCrashDate = [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""];

            
            if ([[WCLogManager sharedInstance] checkIsHasData]) {
                [weakSelf uploadDiagnoseLogIsOk];
            }else {
                //YIHAIKERRY-3873 改为当天没有，上传前一天的日志
               // SFA 益海嘉里-传统渠道 -【IOS】上传诊断日志失败
                NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
                NSString *lastDateString = [formatter stringFromDate:lastDay];
                [WCLogManager sharedInstance].selErrorDate = lastDateString;
                [WCLogManager sharedInstance].selCrashDate = [lastDateString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                if ([[WCLogManager sharedInstance] checkIsHasData]) {
                    [weakSelf uploadDiagnoseLogIsOk];
                } else {
                NSString *tmpString = NSLocalizedString(@"no_log_tip",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
            }
            
            
        }];

    }else {
        [self uploadDiagnoseLogIsOk];
    }
    
}

- (void)uploadDiagnoseLogIsOk {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view withText:NSLocalizedString(@"uploading_please_wait_prompt", nil) tips:nil tapTarget:self action:nil];
    //self.hud.mode = MBProgressHUDModeIndeterminate;
//    self.hud.labelText = NSLocalizedString(@"uploading_please_wait_prompt", nil);
    self.hud.removeFromSuperViewOnHide = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDiagnoseLogFinished:) name:kUploadAllLogDataFinishNotifyName object:nil];
    
    [[WCLogManager sharedInstance] startUploadLog:UploadLogTypedAll];
    
}

- (void)uploadDiagnoseLogFinished:(NSNotification *)sender
{
    [self.hud hide:YES];
    
    NSString *string = NSLocalizedString(@"fail_upload", nil);
    if ([sender userInfo] != nil && [[[sender userInfo] objectForKey:kUploadAllLogDataResultKey] boolValue]) {
        string = NSLocalizedString(@"upload_success", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadAllLogDataFinishNotifyName object:nil];
}
- (void)backAction{
    
      [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
