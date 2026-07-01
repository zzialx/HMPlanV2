//
//  AddNewProductViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAddNewProductViewController.h"
#import "WSAcvtBean.h"
#import "WSNewProductBean.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
//#import "ConfigFileController.h"
#import "WSAddProductTable.h"
#import "WinSFA.h"
#import "WSPlistHelper.h"
#import "WSAddProductQstTable.h"
#import "WSBaseAcvtDBService.h"

@interface WSAddNewProductViewController()


@property(nonatomic,copy)NSString* iProductId;
@property(nonatomic,copy)NSString* istoreid;
@property(nonatomic,copy)NSString* itimeupdate;
@property(nonatomic,copy)NSString* iUploadFlag;
@property(nonatomic,assign)int iID; // ANS_ID
@property(nonatomic, strong)NSString *iFirstShowingQstId; // Product Name

@end

@implementation WSAddNewProductViewController

@synthesize textField;
@synthesize istoreid = _istoreid;
@synthesize itimeupdate = _itimeupdate;
@synthesize iUploadFlag = _iUploadFlag;
@synthesize iID = _iID;
@synthesize iProductId = _iProductId;

#pragma mark - class init & dealloc


- (id)initWithFuncs:(WSFuncsBean *)aFuncs
{
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *avcts = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];

    WSAcvtBean* avct = nil;
    
    if (avcts != nil && [avcts count] > 0) {
        avct = [avcts objectAtIndex:0];
    }
    else {
        return nil;
    }
    
    self = [super initWithAcvt:avct Funcs:aFuncs Store:nil];
    
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)aFuncs ProductInfoArray:(NSArray *)aArray
{
    if(aFuncs == nil|| [aArray count] < 1)
        return nil;
    
    if(self = [self initWithFuncs:aFuncs])
    {
        int i = 0;
        for ( NSDictionary* dic in aArray ) 
        {
            if (i == 0)
            {
                NSString* ans_id = [dic objectForKey:@"ans_id"];
                self.iID = [ans_id intValue];
                self.istoreid = [dic objectForKey:@"store_id"];
                self.iProductId = [dic objectForKey:@"product_id"];
                WSStoreBean* store = [[WSStoreBean alloc] init];
                store.Id = self.istoreid;
                store.plan = NO;
                self.currentStore = store;
                
                NSString* updatemd5id = [dic objectForKey:@"update_md5id"];
                WSNewProductBean* product = [[WSNewProductBean alloc] init];
                product.iProductId = self.iProductId;
                product.isPlan = NO;
                product.iStoreId = self.istoreid;
                product.iUpdateIdMd5 = updatemd5id;
//                self.iUpdateMd5Id = updatemd5id;
//                self.iCurrentNewProductBean = product;
            }
            i++;
            
//            NSString* optid = [dic objectForKey:@"opt_id"];
//            NSString* qstid = [dic objectForKey:@"qst_id"];
//            NSString* optval = [dic objectForKey:@"opt_val"];
//            if (optid != nil && ![optid isEqualToString:@"<null>"])
//            { 
//                NSString* key = [NSString stringWithFormat:@"%@,%@", qstid,optid];
//                [self.markDictionary setObject:@"3" forKey:key]; //check box
//                
//            }else if( qstid != nil && ![qstid isEqualToString:@"<null>"])
//            {
//                [self.markDictionary setObject:optval forKey:qstid];
//            }
        }
        return self;
    } 
    return nil;    
}



#pragma mark - view life cycle

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    //add by wangdongyan 05-08 for 考勤上报内拍摄的图片的位置的调整
    self.view.frame=CGRectMake(0, 0, 320, 400);
    self.mImagePicker.delegate=self;
//    [self initView];
}

//！！！旧acvt代码都已删除，此页面与新acvt代码不兼容，目前不知道使用场景，遇见使用此页面时，应该根据新acvt代码重构。

/*
-(void)initView
{
    UITableView* tv = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point, 320, 480-20-88) style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    self.tableView = tv;
    
    [self.view addSubview:self.tableView];
    
    int height = 10 ;
    int count = [self.QstForTextArray count];
    int l_qstIndex = 0;
    if(count >0)
    {
        UIView* l_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0)];
        for(WSAcvtBean_qst* ab_qst in self.QstForTextArray)
        {
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_L])
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 300, 20)];
                float fontHeight = lable.font.capHeight;
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
//                lable.backgroundColor = [[ConfigFileController sharedInstanceMethod] colorWithHexString:[[ConfigFileController sharedInstanceMethod] getValueForKey:@"CLEAR_COLOR"]];
                lable.backgroundColor = kCLEAR_COLOR_value;
                
                [l_view addSubview:lable];
                height += (fontHeight+10);
                
                if(height > l_view.frame.size.height)
                {
                    l_view.frame = CGRectMake(0, 0, 320, height);
                }
            }
            if([ab_qst.qstType isEqualToString:QST_TYPE_N]||
               [ab_qst.qstType isEqualToString:QST_TYPE_T])
            {  
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 150, 30)];
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
//                lable.backgroundColor = [[ConfigFileController sharedInstanceMethod] colorWithHexString:[[ConfigFileController sharedInstanceMethod] getValueForKey:@"CLEAR_COLOR"]];
                lable.backgroundColor = kCLEAR_COLOR_value;
                [lable sizeToFit];
                [l_view addSubview:lable];
                int i_xPosition = 150;
                if(lable.frame.size.width > 150)
                {
                    i_xPosition = 150;
                    height += lable.frame.size.height;
                }
                textField = [[WSHTextField alloc]initWithFrame:CGRectMake(i_xPosition, height, 150, 30) Qst:ab_qst];
                textField.currentFuncs=self.currentFuncs;

                textField.textAlignment = NSTextAlignmentLeft;
                textField.backgroundColor = [UIColor whiteColor];
                [textField setBorderStyle:UITextBorderStyleBezel];
                textField.delegate = self;
                textField.tag = [ab_qst.acvtQstId intValue];
                if (self.iFirstShowingQstId == nil) {
                    self.iFirstShowingQstId = ab_qst.acvtQstId;
                }
                l_qstIndex ++;
                if([ab_qst.qstType isEqualToString:QST_TYPE_N])
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                else
                    textField.keyboardType = UIKeyboardTypeDefault;
                
                
                [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
//                [self performSelector:@selector(addCancellOKButton:) withObject:textField];
                
                //查询
                if([self.markDictionary objectForKey:ab_qst.acvtQstId])
                {
                    textField.text = [self.markDictionary objectForKey:ab_qst.acvtQstId];
                }
                
                [l_view addSubview:textField];
                //[textField release];
                height += 40;
                
                if(height > l_view.frame.size.height)
                {
                    l_view.frame = CGRectMake(0, 0, 320, height);
                }
                if(textField.text != nil)
                    [self.markDictionary setObject:textField.text forKey:ab_qst.acvtQstId];
            }
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_W])
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 150, 30)];
                lable.text = [WSCurrentTime getDateTime];
                [lable sizeToFit];
//                lable.backgroundColor = [[ConfigFileController sharedInstanceMethod] colorWithHexString:[[ConfigFileController sharedInstanceMethod] getValueForKey:@"CLEAR_COLOR"]];
                lable.backgroundColor = kCLEAR_COLOR_value;
                [l_view addSubview:lable];
                height += 40;
                
                if(height > l_view.frame.size.height)
                {
                    l_view.frame = CGRectMake(0, 0, 320, height);
                }
            }
//            if([ab_qst.qstType isEqualToString:QST_TYPE_P])
//            {
//                NSString *photoString = NSLocalizedString(@"camera_capture",nil);
//                UIBarButtonItem *makePhoto = [[UIBarButtonItem alloc]
//                                              initWithTitle:photoString
//                                              style: UIBarButtonItemStylePlain
//                                              target:self 
//                                              action:@selector(makePhoto)];
//                if(self.m_ParentViewController != nil)
//                    self.m_ParentViewController.navigationItem.rightBarButtonItem = makePhoto;
//                else
//                    self.navigationItem.rightBarButtonItem = makePhoto;
//            }
            
        }
        
        self.tableView.tableHeaderView = l_view;
        l_view = nil;
    }
    
}
*/

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addToolBar];
}



#pragma mark - Private API
/*
- (void)dealWithQST
{
    [self.markDictionary removeAllObjects];
    
    NSMutableArray* tvarray = [[NSMutableArray alloc] init];
    self.QstForTableViewArray = tvarray;
    
    NSMutableArray* textarray = [[NSMutableArray alloc] init];
    self.QstForTextArray = textarray;
    
    for(WSAcvtBean_qst* ab_qst in self.m_currentAcvt.qsts)
    {
        if([ab_qst.qstType isEqualToString:QST_TYPE_C]||
           [ab_qst.qstType isEqualToString:QST_TYPE_R])
        {
            [self.QstForTableViewArray addObject:ab_qst];
        }
        
        //如果是拍照
        if([ab_qst.qstType isEqualToString:QST_TYPE_P])
        {
            [self.QstForTextArray addObject:ab_qst];
        }
        //如果是日期
        if([ab_qst.qstType isEqualToString:QST_TYPE_W])
        {
            [self.QstForTextArray addObject:ab_qst];
            [self.markDictionary setObject:[WSCurrentTime getDateString] forKey:ab_qst.acvtQstId];
            
        }
        
        if([ab_qst.qstType isEqualToString:QST_TYPE_GG]||
           [ab_qst.qstType isEqualToString:QST_TYPE_GF])
        {
            [self.QstForTextArray addObject:ab_qst];
            [self.markDictionary setObject:ab_qst.acvtQstId forKey:@"GPS"];
        }
        //条形码
        if([ab_qst.qstType isEqualToString:QST_TYPE_SCAN]||
           [ab_qst.qstType isEqualToString:QST_TYPE_I])
        {
            [self.QstForTextArray addObject:ab_qst];
        }
        
        //视频
        if([ab_qst.qstType isEqualToString:QST_TYPE_V])
        {
            [self.QstForTextArray addObject:ab_qst];
        }
        
        if([ab_qst.qstType isEqualToString:QST_TYPE_L]||
           [ab_qst.qstType isEqualToString:QST_TYPE_N]||
           [ab_qst.qstType isEqualToString:QST_TYPE_T])
        {
            [self.QstForTextArray addObject:ab_qst];
        }
    }
}


- (void)upload
{
    if (![self checkInputProductInfo])
        return;
    
    if (self.iID == 0) {
        // First generate md5 id because don't back product id,so update use it
        [super GenerateMD5String];
        self.iUpdateMd5Id = self.md5;
        
        // Insert wch_addProduct table
        [self insertAddedProductTable];
        
        // Query max id which is fieled ans_id of wch_addProductQst
        [self selectAnsIdFromAddProductTable];
        
        // Insert wch_addProductQst table
        [self insertAddedProductQstTable];        
    }
    else {
        self.iUploadFlag = @"0";
        self.itimeupdate = [WSCurrentTime getDateTime];
        [self updateAddedProductTable];
        [self updateAddedProductQstTable];
    }

 
    NSInteger uploadAllCount = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:All];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addProductFinished:) 
                                                 name:[NSString stringWithFormat:@"%d", uploadAllCount]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addProductFinished:) 
                                                 name:[NSString stringWithFormat:@"%d", uploadAllCount + 1] 
                                               object:nil];  
    
    // Upload 
    [super doUploadingNewProduct];
    
}


#pragma mark - handle database

/*
- (void)insertAddedProductTable
{
    self.iUploadFlag = @"0";
    self.itimeupdate = [WSCurrentTime getDateTime];
    
    NSMutableArray* row = [[NSMutableArray alloc] init ];
    [row addObject: [NSNull null]]; //SR_ID--What is it?
    [row addObject: self.m_currentAcvt.acvtId]; // ACVT_ID
    [row addObject: [WSAppData getObjectbyKey: APPDATA_EMPID ]]; // EMP_ID
    [row addObject: [NSNull null]]; // RSPN_ID
    [row addObject: [NSNull null]]; // STORE_ID
    [row addObject: [NSNull null]]; // PRODUCT_ID
    [row addObject: [WSAppData getObjectbyKey:APPDATA_BIZDATE]]; // BIZ_DATE
    [row addObject: self.iUploadFlag]; // UPLOAD_FLAG
    [row addObject: self.itimeupdate]; // UPLOAD_DATE
    [row addObject: [NSNull null]]; // IMG_IDX
    [row addObject: self.currentFuncs.fc]; // FUNC_CODE
    [row addObject: self.currentFuncs.fv]; // FUNC_VIEW
    [row addObject: [NSNull null]]; // MEMO
    [row addObject: [NSNull null]]; // serviece require
    [row addObject:self.iUpdateMd5Id];
    
    NSLog(@"row vale = %@", [row description]);
    [[WSAddProductTable sharedTable] insertWithArgumentsValue:row];
}

- (void)selectAnsIdFromAddProductTable
{
    NSArray* array= [[WSAddProductTable sharedTable] queryAllProduct];
    self.iID = 0;
    if(array.count>0){
        self.iID=[[array lastObject] ID];
    }
}


- (void)insertAddedProductQstTable;
{
    NSMutableArray* vales = [[NSMutableArray alloc] init];
    NSMutableDictionary* table = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[self.markDictionary allKeys]];
    NSInteger index = [keys indexOfObject:self.iFirstShowingQstId];
    if (index != NSNotFound && index != 0) {
        [keys exchangeObjectAtIndex:index withObjectAtIndex:0];
    }
    
    for(NSString* key in keys)
    {
        BOOL bFind = NO;
        [table setObject:[NSNull null] forKey:@"QST_ID"];
        [table setObject:[NSNull null] forKey:@"OPT_ID"];
        [table setObject:[NSNull null] forKey:@"OPT_VAL"];
        [table setObject:[NSNull null] forKey:@"QST_TYPE"];
        
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in self.m_currentAcvt.qsts)
        {
            if([qst.acvtQstId isEqualToString:qstIdString])
            {
                if([qst.qstType isEqualToString:QST_TYPE_N]||
                   [qst.qstType isEqualToString:QST_TYPE_W]||
                   [qst.qstType isEqualToString:QST_TYPE_T]||
                   [qst.qstType isEqualToString:QST_TYPE_SCAN] ||
                   [qst.qstType isEqualToString:QST_TYPE_GG]||
                   [qst.qstType isEqualToString:QST_TYPE_GF] ||
                   [qst.qstType isEqualToString:QST_TYPE_V]||
                   [qst.qstType isEqualToString:QST_TYPE_I] )
                {
                    NSString* optval = [self.markDictionary objectForKey:qstIdString]; //should qstval
                    [table setObject:qstIdString forKey:@"QST_ID"];
                    [table setObject:qst.qstType forKey:@"QST_TYPE"];
                    [table setObject:optval forKey:@"OPT_VAL"];
                    [table setObject:[NSNull null] forKey:@"OPT_ID"];
                    bFind =YES;
                    break;
                }
                
                if([qst.qstType isEqualToString:QST_TYPE_C]||[qst.qstType isEqualToString:QST_TYPE_R])
                {
                    [table setObject:qstIdString forKey:@"QST_ID"]; 
                    [table setObject:qst.qstType forKey:@"QST_TYPE"];
                    if ([array count] > 1) 
                    {
                        [table setObject:[array objectAtIndex:1] forKey:@"OPT_ID"];
                        //此处应该和调查问卷一样 [table setObject:[array objectAtIndex:1] forKey:@"OPT_VAL"];
                         //先保持旧的如发现问题再修改
                        [table setObject:[NSNull null] forKey:@"OPT_VAL"];
                        
                    }
                    else 
                    {
                        NSString* optval = [self.markDictionary objectForKey:qstIdString]; //should qstval
                        [table setObject:optval forKey:@"OPT_VAL"];
                        [table setObject:[NSNull null] forKey:@"OPT_ID"];
                        
                    }
                    bFind = YES;
                    break;
                }
            }
        }
        
        if (bFind) {
            NSString* ans_id = [[NSString alloc] initWithFormat:@"%d", self.iID];
            NSString* qst_id = [table objectForKey:@"QST_ID"];
            NSString* opt_id = [table objectForKey:@"OPT_ID"];
            NSString* opt_val = [table objectForKey:@"OPT_VAL"];
            NSString* qst_type = [table objectForKey:@"QST_TYPE"];
            
            NSArray* val = [[NSArray alloc] initWithObjects:ans_id,qst_id,opt_id,opt_val,qst_type,nil];
            [vales addObject:val];
            [table removeAllObjects];
        }
    }
    
    for (NSArray* val in vales) {
        [[WSAddProductTable sharedTable] insertWithArgumentsValue:val];
    }
}

- (void)updateAddedProductTable
{
    NSArray* setnames = [[NSArray alloc] initWithObjects:@"UPLOAD_FLAG",@"UPLOAD_DATE", nil];
    NSArray* setvalues = [[NSArray alloc] initWithObjects:self.iUploadFlag,self.itimeupdate, nil];
    NSArray* wherenames = [[NSArray alloc] initWithObjects:@"ID", nil];
    NSString* nid = [NSString stringWithFormat:@"%d", self.iID];
    NSArray* wherevalues = [[NSArray alloc] initWithObjects:nid, nil];
    [[WSAddProductTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
}

- (void)updateAddedProductQstTable
{
    NSMutableDictionary* table = [[NSMutableDictionary alloc] init];
    NSArray* setnames = [[NSArray alloc] initWithObjects:@"OPT_ID",@"OPT_VAL",nil];
    NSArray* wherenames = [[NSArray alloc] initWithObjects:@"ANS_ID",@"QST_ID", nil];
    
    for(NSString* key in [self.markDictionary allKeys])
    {
        BOOL bFind = NO;        
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in self.m_currentAcvt.qsts)
        {
            if([qst.acvtQstId isEqualToString:qstIdString])
            {
                if([qst.qstType isEqualToString:QST_TYPE_N]||
                   [qst.qstType isEqualToString:QST_TYPE_W]||
                   [qst.qstType isEqualToString:QST_TYPE_T]||
                   [qst.qstType isEqualToString:QST_TYPE_SCAN] ||
                   [qst.qstType isEqualToString:QST_TYPE_GG]||
                   [qst.qstType isEqualToString:QST_TYPE_GF] ||
                   [qst.qstType isEqualToString:QST_TYPE_V]||
                   [qst.qstType isEqualToString:QST_TYPE_I] )
                {
                    NSString* optval = [self.markDictionary objectForKey:qstIdString]; //should qstval
                    [table setObject:qstIdString forKey:@"QST_ID"];
                    [table setObject:qst.qstType forKey:@"QST_TYPE"];
                    [table setObject:optval forKey:@"OPT_VAL"];
                    [table setObject:[NSNull null] forKey:@"OPT_ID"];
                    bFind =YES;
                    break;
                }
                
                if([qst.qstType isEqualToString:QST_TYPE_C]||[qst.qstType isEqualToString:QST_TYPE_R])
                {
                    [table setObject:qstIdString forKey:@"QST_ID"]; 
                    [table setObject:qst.qstType forKey:@"QST_TYPE"];
                    if ([array count] > 1) 
                    {
                        [table setObject:[array objectAtIndex:1] forKey:@"OPT_ID"];
                        //此处应该和调查问卷一样 [table setObject:[array objectAtIndex:1] forKey:@"OPT_VAL"];
                         //先保持旧的如发现问题再修改
                        [table setObject:[NSNull null] forKey:@"OPT_VAL"];
                        
                    }
                    else 
                    {
                        NSString* optval = [self.markDictionary objectForKey:qstIdString]; //should qstval
                        [table setObject:optval forKey:@"OPT_VAL"];
                        [table setObject:[NSNull null] forKey:@"OPT_ID"];
                        
                    }
                    bFind = YES;
                    break;
                }
            }
        }
        
        if (bFind) {
            NSString* ans_id = [[NSString alloc] initWithFormat:@"%d", self.iID];
            NSString* qst_id = [table objectForKey:@"QST_ID"];
            NSString* opt_id = [table objectForKey:@"OPT_ID"];
            NSString* opt_val = [table objectForKey:@"OPT_VAL"];
            NSString* qst_type = [table objectForKey:@"QST_TYPE"];
            NSArray* setvalues = [[NSArray alloc] initWithObjects:opt_id, opt_val, nil];
            NSArray* wherevalues = [[NSArray alloc] initWithObjects:ans_id,qst_id, nil];
            
            if (![self checkQstIsInsertWith:ans_id andQstId:qst_id]) {
                NSArray* val = [[NSArray alloc] initWithObjects:ans_id,qst_id,opt_id,opt_val,qst_type,nil];
                [[WSAddProductTable sharedTable] insertWithArgumentsValue:val];
            }else {
                [[WSAddProductTable sharedTable] updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
            }
            
            [table removeAllObjects];
        }
    }
}

- (BOOL)checkQstIsInsertWith:(NSString*)aAnsId andQstId:(NSString*)aQstId
{
    NSArray* array = [[WSAddProductQstTable sharedTable] queryQstByAnsId:aAnsId andQstId:aQstId];
    if (array.count > 0) {
        return YES;
    }
    else { // Don't take care about ret == -1
        return NO;
    }
}

- (BOOL)checkInputProductInfo
{
    BOOL bInput = YES;
    NSMutableString* msg = [[NSMutableString alloc] init];
    NSMutableArray* qstName = [[NSMutableArray alloc] initWithCapacity:4];
    //for (AcvtBean_qst* ab_qst in self.QstForTextArray) {
    for (int i = 0; i < [self.QstForTextArray count]; i++){
        WSAcvtBean_qst* ab_qst = [self.QstForTextArray objectAtIndex:i];
        if (ab_qst) {
            NSString* req = ab_qst.is_req;
            if (req && req != (NSString*)[NSNull null] && [req isEqualToString:@"1"]) {
                NSString* inputVal = [self.markDictionary objectForKey:ab_qst.acvtQstId];
                if (!inputVal || inputVal == (NSString*)[NSNull null]) {
                    //[self showAlertView];
                    bInput = NO;
                    [qstName addObject:ab_qst.qstName];
                    continue;
                }
                
                int nlen = [inputVal length];
                inputVal = [inputVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                int ncutlen = [inputVal length];
                if (ncutlen == 0) {
                    //[self showAlertView];
                    bInput = NO;
                    [qstName addObject:ab_qst.qstName];
                }
                if (ncutlen < nlen) {
                    [self.markDictionary setObject:inputVal forKey:ab_qst.acvtQstId];
                }
            }
        }
    }
    
    for (NSString* name in qstName) 
    {
        [msg appendString:name];
        [msg appendString:@"\n"];
    }
    if (msg && [msg length] >0) {
        [self showAlertView:msg];
    }
    return bInput;
}

- (void)showAlertView:(NSString*)aMsg
{
    NSString* title = NSLocalizedString(@"以下为必填项:", nil);
    NSString* btntitle = NSLocalizedString(@"confirm", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:aMsg];
    [alert setCancelButtonWithTitle:btntitle block:nil];
    [alert show];
}
 */

@end
