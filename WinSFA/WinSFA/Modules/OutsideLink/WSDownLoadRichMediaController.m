 //
//  WSDownLoadRichMediaController.m
//  WinSFA
//
//  Created by huzepei on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDownLoadRichMediaController.h"
#import "PureLayout.h"
#import "CustomSlider.h"
#import "WinAFNetworking.h"

#import "DownLoadHeader.h"
#import "SLDownLoadModel.h"
#import "SLDownLoadQueue.h"

#import "WSRichMediaTable.h"
#import "WSRichItemModel.h"
#import "Reachability.h"
#import "UIColor+SkinStyle.h"


#define TITLEBTNCOLOR  [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1]

@interface WSDownLoadRichMediaController ()

@property (nonatomic, strong) CustomSlider *slider;
@property (nonatomic, strong) UIButton *downloadBtn;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic,assign)int value;
@property(nonatomic, assign)BOOL isDownload;

//句柄
@property (nonatomic,strong) NSURLSessionDownloadTask * downloadTask;

//BaseURl
@property (nonatomic,copy) NSString *baseStr;

//@property (nonatomic,strong) NSMutableArray *imgArr;
//@property (nonatomic,strong) NSMutableArray *h5Arr;

// 下载队列
@property (nonatomic,strong) NSMutableArray *downLoadQueueArr;

@end

@implementation WSDownLoadRichMediaController

- (void)viewDidLoad {
    
    [self initViews];
    [super viewDidLoad];
    
    [self updateAlertCount];
    
    
    SLDownLoadQueue *queue = [SLDownLoadQueue downLoadQueue];
    
    queue.downLoadCount = ^(NSMutableArray *unfinished,NSMutableArray *complete){
        
        [self updateAlertCount];
        
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadOver:) name:DownLoadResourceFinished object:nil];
}

-(void)initViews
{
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.backgroundColor = TITLEBTNCOLOR;
    [titleBtn setTitle:@"富媒体下载" forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:titleBtn];
    
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [titleBtn autoSetDimension:ALDimensionHeight toSize:58];
    [titleBtn autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];

    _slider = [[CustomSlider alloc]initWithFrame:CGRectMake(10, 100, 330, 50)];
    [self.view addSubview:_slider];
    _value = 0;
    _isDownload = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 8.0;
    [self.view addSubview:button];
    [button setTitle:@"下载" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(downLoad) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:MAIN_TINT_COLOT];
    button.frame = CGRectMake(120, 200, 100, 50);
    self.downloadBtn = button;
    
    _downLoadQueueArr = [SLDownLoadQueue downLoadQueue].downLoadQueueArr;
    //正在下载中
    if (_downLoadQueueArr.count > 0) {
        [button setTitle:@"暂停 " forState:UIControlStateNormal];
    }
}

// 下载完成的通知.
-(void)downLoadOver:(NSNotification *)sender
{
    sender =  (NSNotification *)sender;
//    SLDownLoadModel * dlm = [sender object];
}

- (void)downStop
{
    [[SLDownLoadQueue downLoadQueue] pauseAll];
    
    [self.downloadBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(downStop) forControlEvents:UIControlEventTouchUpInside];
}

-(void)downLoad
{
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NotReachable:
        {
            NSString *title = NSLocalizedString(@"network_failure", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            return;
        }
            break;
        case ReachableViaWiFi:
        {
            
        }
            break;
        case ReachableViaWWAN:
        {
            NSString *title = NSLocalizedString(@"该资源只能WIFI下载", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
            break;
        default:
            break;
    }
    
    NSMutableArray *h5Arr = [[[WSRichMediaTable sharedTable] queryTableItemsNotDownloadWithH5] mutableCopy];
    
    //点击下载的时候，比较下载队列与数据库未下载的是否匹配,不匹配的添加到下载队列(h5)
    NSMutableArray *downLoadQueueArr_h5 = [SLDownLoadQueue downLoadQueue].downLoadQueueArr;
    if (downLoadQueueArr_h5.count != 0) {
        NSMutableIndexSet *idxSet2 = [[NSMutableIndexSet alloc] init];
        for (int k = 0; k < h5Arr.count; k++) {

            WSRichItemModel *richItem = h5Arr[k];
            for (int i = 0; i < downLoadQueueArr_h5.count; i++) {

                SLDownLoadModel *downLoadModel = downLoadQueueArr_h5[i];

                if ([downLoadModel.ID isEqualToString:richItem.speid]) {

                    [idxSet2 addIndex:k];
                    break;
                }
            }
        }
        [h5Arr removeObjectsAtIndexes:idxSet2];
    }
    
    
    //下载h5 - 添加到下载队列
    if ([self.downloadBtn.titleLabel.text isEqualToString:@"下载"]) {
        
        [self.downloadBtn setTitle:@"暂停" forState:UIControlStateNormal];
        
        [[SLDownLoadQueue downLoadQueue] startDownloadAll];
        
        for (WSRichItemModel *richItem in h5Arr) {
            SLDownLoadModel *downLoadModel = [[SLDownLoadModel alloc]init];
            
            if (richItem.h5_url && ![richItem.h5_url isEqualToString:@""]){
                
                NSString *fileName = [[NSUUID UUID] UUIDString];
                
                //下载的URl
                downLoadModel.downLoadUrlStr = [WSHttpURLHelper getImageCompleteURL:richItem.h5_url];
                
                downLoadModel.ModelFileType = 1;
                
                downLoadModel.ID = richItem.speid;
                downLoadModel.fileUUID = fileName;
                
                [[SLDownLoadQueue downLoadQueue] addDownTaskWithDownLoadModel:downLoadModel];
            }
        }
    
    }else{

        [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        
        [[SLDownLoadQueue downLoadQueue] pauseAll];
        
        // 暂停的时候,清空所有未下载的和队列中的对象.
        [[SLDownLoadQueue downLoadQueue].downLoadQueueArr removeAllObjects];
        
    }
    
}

-(void)runTime{
    
    _value++;
    if (_value <= 100) {
        [_slider setLeftFrame:_value];
    }
    else
    {
        [_timer invalidate];
        _timer = nil;
        _value = 0;
        _slider.ValueLabel.text = @"下载完成";
        [self.downloadBtn setTitle:@"downloaded" forState:UIControlStateNormal];
        self.downloadBtn.enabled = NO;
    }
}

-(NSString *)baseStr
{
    if (!_baseStr) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configFile" ofType:@"plist"];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        _baseStr =  [configDict objectForKey:@"ServerIP"];
    }
    return _baseStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)updateAlertCount
{
    NSArray *array = [[WSRichMediaTable sharedTable] queryTableItemsNotDownloadWithH5URL];
    
    NSMutableArray *h5Arr = [[[WSRichMediaTable sharedTable] queryTableItemsNotDownloadWithH5] mutableCopy];
    
    float r = (float)(array.count - h5Arr.count) / array.count * 100;
    
    NSString *value = [NSString stringWithFormat:@"%zd / %zd",(array.count - h5Arr.count),array.count];
    _slider.ValueLabel.text = value;
    [_slider setLeftFrame:r];
}

@end
