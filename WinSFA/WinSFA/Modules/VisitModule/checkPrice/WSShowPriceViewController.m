//
//  ShowPriceViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//



#import "WSShowPriceViewController.h"
#import "DataGridComponent.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_Param.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSStoreBean_prod.h"
#import "WSDictBean.h"
#import "WSReasonViewController.h"
#import "WSCurrentTime.h"
#import "WSProdBean.h"
#import "WSProdBeanArray.h"
#import "WSFptTable.h"
#import "WSRequestHelper.h"
#import "WSFuncsBean_opt.h"
//#import "ConfigFileController.h"
@implementation WSShowPriceViewController
@synthesize brand = _brand;

UITextField *currentTextField = nil;


-(NSArray*)getProdArray
{
    NSMutableArray* prodArray = [[NSMutableArray alloc]init];
    WSProdBeanArray* pba = [WSAppData getObjectbyKey:PRODS];
    NSString* brandid = [NSString stringWithValue:self.brand.Id];
    for(WSProdBean* pb in pba.prodArray)
    {
        //NSLog(@"pb.barnd is =%@",pb.brand);
        NSString* prod_Brand = [NSString stringWithValue:pb.brand];
        if([brandid isEqualToString:prod_Brand])
        {
            [prodArray addObject:pb];
        }
    }
    return prodArray;
}
-(void)insertData
{
    NSMutableArray *proValues=[[NSMutableArray alloc]init];
    //产品数量
    NSArray* prods = [self getProdArray];
    for(int i = 0 ; i < [self.datas count];i++)
    {
        NSMutableArray* prodRow = [[NSMutableArray alloc]init];
        NSArray* row = (NSArray*)[self.datas objectAtIndex:i];
        //idx
        [prodRow addObject:self.md5];
        //prod_id
        WSProdBean* pb = [prods objectAtIndex:i];
        [prodRow addObject:[NSString stringNotNilWithValue:pb.cod/*pb.Id*/]];
        
        //ui的行
        for(int m = 0 ; m < 12 ; m++)
        {
            [prodRow addObject:@"null"];
        }
        
        for(int j = 0 ; j < [row count] ;j++)
        {
            if([[row objectAtIndex:j] isKindOfClass:[UITextField class]])
            {//sid,pid,dist,pri,inv,aging,disp,sdisp,cmpt,oos,mtd,ord,gofa,otherdicts
                UITextField* view = (UITextField*)[row objectAtIndex:j];
                //dist
                if(view.tag < [prodRow count]&&view.text!=nil)
                {
                    [prodRow removeObjectAtIndex:view.tag];
                    [prodRow insertObject:view.text atIndex:view.tag];
                }
            }
        }
        [proValues addObject:prodRow];
    }
    
    //fpt
    NSNumber* isPlan = [NSNumber numberWithBool:self.currentStore.plan];
    NSArray* fptValues = [NSArray arrayWithObjects:self.currentFuncs.fc,self.currentFuncs.fv,[isPlan stringValue],@"null",self.currentStore.Id,[WSAppData getObjectbyKey:APPDATA_EMPID],[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateString],@"0",self.md5,@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null", nil];
    
    [[WSFptTable sharedTable] insertWithFptArray:fptValues product:proValues];
}


- (void)closeKeyboard{
    if (currentTextField) {
        [currentTextField resignFirstResponder];
    }
}


- (void)showAlert:(NSString *)message{
//    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    NSString *UploadFailString = NSLocalizedString(@"js_alert_title",nil);
    NSString *OkString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:UploadFailString message:message];
    [alert setCancelButtonWithTitle:OkString block:nil];
    [alert addButtonWithTitle:TryString block:^{
        
    }];
    [alert show];
}

- (void)upload
{
    
    
    
    NSString *FUNCSDETAIL = [NSString stringWithFormat:@"%@%@",@"funcsDetail", self.currentFuncs.fc];
    if (self.photo) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadPhoto:)
                                                     name:FUNCSDETAIL 
                                                   object:nil];
        
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadFinished:)
                                                     name:FUNCSDETAIL 
                                                   object:nil];
    }

    NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];
}

-(NSDictionary*)md5Param
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[super md5Param]];
    NSString* memo=self.currentFuncs.iParentFuncsBean.fc;
    
    
    NSString *superMemo = [dic objectForKey:@"memo"];
    
    if (memo
        && [memo length] > 0
        && superMemo
        && [superMemo length] > 0) {
        memo = [NSString stringWithFormat:@"%@_%@",superMemo,memo];
        [dic setValue:memo forKey:@"memo"];
    }else if(memo
             && [memo length] > 0){
        [dic setValue:memo forKey:@"memo"];
    }
    return dic;
}


- (void)uploadPhoto:(id)sender{
    NSString *FUNCSDETAIL = [NSString stringWithFormat:@"%@%@",@"funcsDetail", self.currentFuncs.fc]; 
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self name:FUNCSDETAIL  object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error!=0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    }else{
        
        NSDictionary *uploadState = [info objectFromJSONString];
        int isSuccess = [[uploadState objectForKey:@"result"] intValue];
        
        if (isSuccess) {
//            WSRequestHelper *uploadMgr = [[[WSRequestHelper alloc] init] autorelease];
//            
//            [uploadMgr postRequestOnPhoto:self.photo
//                                     fc:self.currentFuncs.fc
//                                storeId:self.currentStore.Id
//                                    md5:self.md5
//                                extName:@"JPEG"];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(uploadFinished:)
                                                         name:NOTYFY_PHOTO 
                                                       object:nil];
        }else{
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            [self showAlert:[uploadState objectForKey:MESSAGE]];
            
        }
        
    }
    
}

- (void)uploadFinished:(id)sender{
    [self insertData];
    NSString *FUNCSDETAIL = [NSString stringWithFormat:@"%@%@",@"funcsDetail", self.currentFuncs.fc]; 
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self name:NOTYFY_PHOTO object:nil];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self name:FUNCSDETAIL  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO   ];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error) {
        //NSLog(@"error ?");
    }else{
        //NSLog(@"result info: %@", info);
        NSDictionary *uploadState = [info objectFromJSONString];
        int isSuccess = [[uploadState objectForKey:@"result"] intValue];
        
        if (isSuccess) {
             NSString *tmpString = NSLocalizedString(@"upload_success",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            
        }else{
            [self showAlert:[uploadState objectForKey:MESSAGE]];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView.tag != ALERT_CAMERA_TAG)
    {
        switch (buttonIndex)
        {
            case 0:
                break;
            case 1:
                [self upload];
                break;
            default:
                break;
        }
    }
}


- (void)checkBoxPressed: (id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        if (((UIButton *)sender).selected) {
            [(UIButton *)sender setSelected:NO];
        }else{
            [(UIButton *)sender setSelected:YES];
        }
    }
}

- (void)textWatcher:(id)sender
{
    currentTextField = sender;



}
-(void)productReason:(id)sender
{
//    DictBeanArray* dba = [AppData getObjectbyKey:DICTS];
//    NSArray* array = [dba getDictsWithFilter:self.currentFuncs.filter];
//    ReasonViewController* rvc = [[ReasonViewController alloc] initWithAcvt:array Funcs:self.currentFuncs Store:self.currentStore];
//    self.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:rvc animated:YES];
//    [rvc release];
}

-(NSInteger)getSpecIndexbyParam:(WSFuncsBean_Param*)param
{
     NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    int index = 0;
    for(NSString* col in spec)
    {
        if([col isEqualToString:param.col])
            return index;
        index++;
    }
    return 100;
}
-(NSString*)getDisbyParam:(WSFuncsBean_Param*)param Prod:(WSProdBean*)prod
{
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    for(WSStoreBean_prod *prodcell in self.currentStore.prodArray)
    {
        NSString* sbp = [NSString stringWithValue:prodcell.pid];
        NSString* pb = [NSString stringWithValue:prod.Id];
        
        if([sbp isEqualToString:pb])
        {   
            int index = 0;
            for(NSString* col in spec)
            {
                
                if([col isEqualToString:param.col])
                {
                    return [prodcell.item objectAtIndex:index];
                }
                index++;
            }
        }
    
    }

    return nil;
}

-(WSProductObject*)displayOldData:(WSProdBean*)prod
{
    NSArray* array = [[WSFptTable sharedTable] queryProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:nil andSrid:self.currentStore.srid];

    if(array != nil)
    {
        for(WSProductObject* object in array)
        {
            NSString* pID = object.prod_id;
            if([pID isEqualToString:prod.cod])
                return object;
        }
        return nil;
    }
    return nil;
    
}

-(void)dealWithParam
{
    if([self.currentFuncs.paramArray count] < 1)
        return;
    
    //titles
    if(self.titles == nil)
    {
        NSMutableArray* titleArray =[[NSMutableArray alloc]init];
        self.titles = titleArray;
    }
    NSInteger paramCount = [self.currentFuncs.paramArray count];
    NSString* item =  NSLocalizedString(@"table_dict_title_project",nil); //项目
    if ([self.currentFuncs.opt.name isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.name;
    } else if ([self.currentFuncs.opt.title isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.title;
    }
    [self.titles addObject:item];
    
    for(int i = 0 ; i < paramCount; i++)
    {
        WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
        [self.titles addObject:fb_Param.name];
    }
    
    if(self.colWidth==nil)
    {
        NSMutableArray* colArray = [[NSMutableArray alloc]init];
        self.colWidth = colArray;
    }
    //colwith  
    [self.colWidth addObject:@"100"];
    
    for(int i = 0 ; i < paramCount; i++)
    {
        [self.colWidth addObject:@"100"];
        //以下是配置
        //        FuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
        //        NSNumber* width = [NSNumber numberWithInteger:fb_Param.wcol];
        //        [self.colWidth addObject:[width stringValue]];
    }
    
    if(self.datas == nil)
    {
        NSMutableArray* dataArray = [[NSMutableArray alloc]init];
        self.datas = dataArray;
    }
    //datas
    
    NSMutableArray* prodArray = [[NSMutableArray alloc]init];
    WSProdBeanArray* pba = [WSAppData getObjectbyKey:PRODS];
    NSString* brandid = [NSString stringWithValue:self.brand.Id];
    for(WSProdBean* pb in pba.prodArray)
    {
        //NSLog(@"pb.barnd is =%@",pb.brand);
        NSString* prod_Brand = [NSString stringWithValue:pb.brand];
        if([brandid isEqualToString:prod_Brand])
        {
            [prodArray addObject:pb];
        }
    }
    
    for (int i = 0; i < [prodArray count]; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] 
                                initWithCapacity:[self.titles count]];
    
        //first column
        UILabel *firstcol = [[UILabel alloc] 
                             initWithFrame:CGRectMake(0,0,79,29)];
        WSProdBean* pb = [prodArray objectAtIndex:i];
        firstcol.text = pb.name;
        firstcol.font = [UIFont systemFontOfSize:12.0f];
        firstcol.textAlignment = NSTextAlignmentCenter;
        [row insertObject:firstcol atIndex:0];
        //查询结果
        WSProductObject* object = [self displayOldData:pb];
        
        for (int j = 0; j < [self.titles count]-1; j++) {
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
            
            if ([param.tpy
                 isEqualToString:COL_TYPNUM]){
                UITextField *textfield = [[UITextField alloc] 
                                          initWithFrame:CGRectMake(0, 0, 79, 29)];
                if(100 != [self getSpecIndexbyParam:param])
                    textfield.tag = [self getSpecIndexbyParam:param];
                //NSLog(@"textfield.tag is = %d",textfield.tag);
                textfield.placeholder = [self getDisbyParam:param Prod:[prodArray objectAtIndex:i]];
                textfield.font = [UIFont systemFontOfSize:12.0f];
                textfield.textAlignment = NSTextAlignmentLeft;
                textfield.delegate = self;
                textfield.keyboardType = UIKeyboardTypeNumberPad;
                
                [textfield addTarget:self
                              action:@selector(textWatcher:)
                    forControlEvents:UIControlEventEditingChanged];
                //查询结果
                NSString* result = [object valueForKey:param.col];
                if([result isEqualToString:@"null"])
                    result = nil;
                if(result != nil)
                {
                    textfield.text = result;
                }
                [row addObject:textfield];                
            }else if ([param.tpy 
                       isEqualToString:COL_TYPCHECKBOX]){
                UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
                check.tag = [self getSpecIndexbyParam:param];
                check.frame = CGRectMake(0, 0, 29, 29);
                [check addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [check setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
                
//                [check setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
                
                [check setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
                [row addObject:check];
            }else if([param.tpy 
                      isEqualToString:COL_TYPBUTTON]){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button.tag = [self getSpecIndexbyParam:param];
                 NSString *tmpString = NSLocalizedString(@"abnormal_reason",nil);
                [button setTitle:tmpString forState:UIControlStateNormal];
                [button addTarget:self action:@selector(productReason:) forControlEvents:UIControlEventTouchUpInside];
                [row addObject:button];
            }
            
        }
        
        [self.datas addObject:row];
    }
}


-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    if(funcs == nil||store == nil)
        return nil;
    
    self = [super initWithFuncs:funcs Store:store];
    if(self != nil)
    {
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(closeKeyboard) name:TOUCH_EVENT object:nil];
    
    [self dealWithParam];
    DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc] 
                                            init];
    
    comData.titles = self.titles;
    comData.data = self.datas;
    comData.columnWidth = self.colWidth;
    
//    [self.titles release];
//    [datas release];
//    [colWidth release];
    //NSLog(@"row is %d",self.currentFuncs.maxRow);
    int heiht = (self.currentFuncs.maxRow+1)* 20 + 5;
    DataGridComponent *compView = [[DataGridComponent alloc] 
                                   initWithFrame:
                                   CGRectMake(10, self.y_point, 300, heiht) data:comData];
    
    [self.view addSubview:compView];
    self.y_point+= heiht;
    
    [self addFuncsOtherBeanView];
    [self addOptView];

    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
