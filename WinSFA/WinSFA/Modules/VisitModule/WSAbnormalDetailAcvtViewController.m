//
//  WCAbnormalDetailAcvtViewController.m
//  WinChannelFrameWork
//
//  Created by Cai Lei on 6/19/12.
//
//

#import "WSAbnormalDetailAcvtViewController.h"
#import "WSCurrentTime.h"
#import "WSFacTable.h"
#import "WSImagePathTable.h"

@interface WSAbnormalDetailAcvtViewController ()
{
    BOOL isFirstShow ;
}
@end


@implementation WSAbnormalDetailAcvtViewController
@synthesize dictRow;
@synthesize parentGridVC;
@synthesize iIdentify = _iIdentify;


-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store Section:(NSInteger)section andIdentify:(NSString *)aIdentify
{
    self.mySection = section;
    self.iIdentify = aIdentify;
    isFirstShow = YES;
    return [super initWithAcvt:anAcvt Funcs:funcs Store:store];
    
}
-(void)loadView
{
    [super loadView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController) {
        self.navigationController.toolbarHidden = NO ;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //photoBrowseViewArray 实现见 WSAcvtViewController initview
//    self.photoBrowseView = [selphotoBrowseVieway firstObject];

    if (isFirstShow) {
        isFirstShow = NO;

        self.photoBrowseView.imageIDArray = [NSMutableArray arrayWithArray:[self getImagePathFromDataBase]];
        [self.photoBrowseView reloadData];
    }

}

- (void)addToolBar {
    LogTrace();
    NSString *UploadString = NSLocalizedString(@"confirm",nil);
    UIBarButtonItem *upload = [[UIBarButtonItem alloc] 
                               initWithTitle:UploadString
                               style:UIBarButtonItemStyleDone
                               target:self
                               action:@selector(confirm)];
    
    NSArray *toolBarArr=[NSArray arrayWithObjects:upload,nil];

    LogInfo("self.navigationController.toolbarHidden = NO;");
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = toolBarArr;
    
    //[super addToolBar];
}


- (NSArray *)getImagePathFromDataBase   
{
    NSMutableArray *imagePathArray = nil;
    
    NSArray *array = [self.parentGridVC.photoDataDic objectForKey:self.md5];
    
    if (array == nil) {
        
//        NSArray *imageObjectArray = [[WSFacTable sharedTable] queryAcvtImagePathInfo:self.currentStore Funcs:self.currentFuncs AcvtId:acvtId];
        NSArray *imageObjectArray = [[WSImagePathTable sharedTable] queryWithImageIDX:self.md5];
        
        if (imageObjectArray && [imageObjectArray count] > 0) {
            imagePathArray = [[NSMutableArray alloc] init];
            for (WSImagePathObject *object in imageObjectArray) {
                NSString *imageID = object.img_path;
                if (imageID && [imageID length] > 0) {
                    [imagePathArray addObject:imageID];
                }
            }
        }
    }
    else
    {
        imagePathArray = [NSMutableArray arrayWithArray:array];
    }
    
    return imagePathArray;
}

//！！！旧acvt代码都已删除，此页面与新acvt代码不兼容，目前不知道使用场景，遇见使用此页面时，应该根据新acvt代码重构。


/*
- (void)confirm
{
    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R]&&[self.photoBrowseView.imageIDArray count] < 1) {
        NSString *TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if ([[self.markDictionary allKeys] count] > 0) {
         [[self parentBtn] setHasBeenFilled:YES];
        
    }
    
    NSMutableDictionary *acvtObj = [[NSMutableDictionary alloc] init];

    for(NSString* key in [self.markDictionary allKeys])
    {
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in self.m_currentAcvt.qsts)
        {
            if([qst.acvtQstId isEqualToString:qstIdString])
            {
                if([qst.qstType isEqualToString:QST_TYPE_N]||[qst.qstType isEqualToString:QST_TYPE_W]||[qst.qstType isEqualToString:QST_TYPE_T]||[qst.qstType isEqualToString:QST_TYPE_SCAN])
                {
                    [acvtObj setObject:[self.markDictionary objectForKey:key] forKey:[NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId]];
                }else if ([qst.qstType isEqualToString:QST_TYPE_C]||[qst.qstType isEqualToString:QST_TYPE_R]){
                    NSString* l_acvtKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qstIdString];
                    if([acvtObj objectForKey:l_acvtKey] != nil)
                    {
                        NSString *preStr = [acvtObj objectForKey:l_acvtKey];
                        NSString* value = [NSString stringWithFormat:@"%@,%@",preStr,[array objectAtIndex:1]];
                        [acvtObj setObject:value forKey:l_acvtKey];
                    }else
                    {
                        [acvtObj setObject:[array objectAtIndex:1] forKey:l_acvtKey];
                    }
                    
                }
            }
        }
    }
    
    [acvtObj setObject:self.md5 forKey:@"photo"];
    [acvtObj setObject:self.m_currentAcvt.acvtId forKey:@"acvtId"];
    
    if (!self.parentGridVC.abnormalReasonDict) {
        self.parentGridVC.abnormalReasonDict = [[NSMutableDictionary alloc] init];
    }
    
    [self.parentGridVC.abnormalReasonDict  setObject:acvtObj forKey:[NSString stringWithFormat:@"%d", self.dictRow]];
    
    
    if (self.photoBrowseView
        && self.photoBrowseView.imageIDArray) {
        [self.parentGridVC.photoDataDic setObject:self.photoBrowseView.imageIDArray forKey:self.md5];
    }
    
    
    [self inserAcvtTable];
    
    [self.navigationController popViewControllerAnimated:YES];
}



//重新写[super insertTable]
-(void)inserAcvtTable
{
    NSMutableArray* facValues = [[NSMutableArray alloc]init];
    NSString *srid = @"null";
    if (self.currentStore
        && self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp
        && self.currentStore.srid
        && [self.currentStore.srid length] > 0) {
        srid = [self.currentStore.srid copy];
    }
    // sr_id
    [facValues addObject:srid];
    // acvt_id
    [facValues addObject:self.m_currentAcvt.acvtId];
    // emp_id
    [facValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    // rspn_id
    [facValues addObject:@"null"];
    // store_id
    [facValues addObject:[NSString stringNotNilWithValue:self.currentStore.Id]];
    
    // biz_date
    [facValues addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    // upload_flag
    [facValues addObject:@"0"];
    // upload_date
    [facValues addObject:[WSCurrentTime getDateString]];
    // img_idx
    [facValues addObject:self.md5];
    // func_code
    [facValues addObject:self.currentFuncs.fc];
    // func_view
    [facValues addObject:self.currentFuncs.fv];
    // is_planed
    [facValues addObject:@"0"];
    // memo
    [facValues addObject:@"null"];
    

    // FacQst
    NSMutableArray* qstArray = [[NSMutableArray alloc]init];
    for(NSString* key in [self.markDictionary allKeys])
    {
        NSMutableDictionary* qstDic = [[NSMutableDictionary alloc]init];
        [qstDic setObject:self.md5 forKey:@"ANS_ID"];
        BOOL bHasValue=NO;
        
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in self.m_currentAcvt.qsts)
        {
            
            if([qst.acvtQstId isEqualToString:qstIdString] && ![qst.qstType isEqualToString:QST_TYPE_PT])
            {
                bHasValue=YES;
                //qstid
                [qstDic setObject:qst.acvtQstId forKey:@"QST_ID"];
                if (qst.opt==nil||[qst.opt count]==0) {
                    // [row addObject:@"null"];
                }
                if([qst.qstType isEqualToString:QST_TYPE_C]||[qst.qstType isEqualToString:QST_TYPE_R])
                {
                    [qstDic setObject:key forKey:@"OPT_ID"];
                }
                if([self.markDictionary objectForKey:key])
                {
                    [qstDic setObject:[self.markDictionary objectForKey:key] forKey:@"OPT_VAL"];
                }
                [qstDic setObject:qst.qstType forKey:@"QST_TYPE"];
                
            }
        }
        if (bHasValue) {
            [qstArray addObject:qstDic];
        }
    }
    LogInfo(@"%@", qstArray);
    [[WSFacTable sharedTable] insertWithFacArray:facValues Qst:qstArray];
}

-(NSDictionary*)md5Param
{
    
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    NSString* memo=[NSString stringWithFormat:@"%d_%@",self.mySection,self.iIdentify];
    if(memo){
        [dic setObject:memo forKey:@"memo"];
    }

    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        if (memo && [memo length] > 0) {
            memo = [NSString stringWithFormat:@"%@_%@",self.currentVisitAction.module_fc,memo];
        }else{
            memo = self.currentVisitAction.module_fc;
        }
        
        [dic setValue:memo  forKey:@"memo"];
        
        NSString *enterDateStr = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:self.currentStore.Id withParentFc:self.currentVisitAction.module_fc];
        if (enterDateStr) {
            LogInfo(@"补录数据:%@", enterDateStr);
            [dic setObject:enterDateStr forKey:@"l_dateStr"];
        }
    }
    
    


    return dic;
}
 
  */


@end
