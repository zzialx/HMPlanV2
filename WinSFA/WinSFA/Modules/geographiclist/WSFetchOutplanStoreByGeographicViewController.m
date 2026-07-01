//
//  WCFetchOutplanStoreByGeographicViewController.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/22/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#define kFetchFinshedNotify @"fetchingoutplanestorefinished"

#import "WSFetchOutplanStoreByGeographicViewController.h"
#import "WSRequestHelper.h"
#import "WSOutPlanStoreBean.h"
#import "WSAppData.h"
#import "WSRequestDataCacheTable.h"
#import "NSString+MD5Addition.h"

@interface WSFetchOutplanStoreByGeographicViewController ()

@end

@implementation WSFetchOutplanStoreByGeographicViewController
@synthesize iBaseGeographicInfo = _iBaseGeographicInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs andBaseGeographicInfo:(WSBaseGeographicInfo *)aInfo
{
    self = [super initWithFuncs:funcs];
    if (self != nil) {
        _iBaseGeographicInfo = aInfo;
    }
    return  self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self startFetchOutplanStroe];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private function

-(void)initDataArray
{
    
}

- (NSString *)getDataFromTableWith:(NSString *)aDataMD5 {
    WSRequestDataCacheObject *object = [[WSRequestDataCacheObject alloc] init];
    object.data_md5 = aDataMD5;
    NSArray *array = [[WSRequestDataCacheTable sharedTable] queryWithObject:object];
    if ([array count] > 0) {
        WSRequestDataCacheObject *result = [array objectAtIndex:0];
        return result.data;
    }
    return nil;
}

- (NSString *)getDataMd5 {
    NSString *dataIdentify = [NSString stringWithFormat:@"%@_%@_%@", [WSAppData getObjectbyKey:APPDATA_EMPID], [WSAppData getObjectbyKey:APPDATA_BIZDATE], self.iBaseGeographicInfo.iId];
    NSString *data_md5 = [dataIdentify stringFromMD5];
    return data_md5;
}

- (void)startFetchOutplanStroe
{
    NSString *data_md5 = [self getDataMd5];
    NSString *info = [self getDataFromTableWith:data_md5];
    if (info) {
        NSDictionary *uploadState = [info objectFromJSONString];
        [self resetData:uploadState];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFinished:) name:kFetchFinshedNotify object:nil];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    NSString *objid = (self.currentFuncs.filter != nil) ? self.currentFuncs.filter : @"spestoreinfo";
    NSLog(@"%@", objid);
    
    [uploadMgr fetchOutplanStoreWithGeographicId:self.iBaseGeographicInfo.iId withObjId:objid withNotifyName:kFetchFinshedNotify];

    [self querying_messageTips];

}

- (void)fetchFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFetchFinshedNotify object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    [self.storeArray removeAllObjects];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        WSRequestDataCacheObject *object = [[WSRequestDataCacheObject alloc] init];
        object.emp_Id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        object.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        object.data_md5 = [self getDataMd5];
        object.data = info;
        [[WSRequestDataCacheTable sharedTable] insertWithObject:object];
        
        NSDictionary *uploadState = [info objectFromJSONString];
        [self resetData:uploadState];
    }
}

- (void)resetData:(NSDictionary *)aDic
{
    if(aDic)
    {
        NSString *objid = (self.currentFuncs.filter != nil) ? self.currentFuncs.filter : @"spestoreinfo";
        NSArray* l_stores = [aDic objectForKey:objid];
        for(NSDictionary* aStore in l_stores)
        {
            WSStoreBean* l_sb = [[WSStoreBean alloc] initStoreWithObject:aStore IsPlan:NO];
            [self.storeArray addObject:l_sb];
        }
    }
    self.filterArray=self.storeArray;
    [self.tableView reloadData];
}

@end
