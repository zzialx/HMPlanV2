//
//  WCPrizerBusinessAddEntityViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/9/13.
//
//

#import "WCPrizerBusinessAddEntityViewController.h"
#import "WSDictBean.h"
#import "WSFuncsBean_other.h"
#import "WSRequestHelper.h"
#import "WCPfizerSelectedDoctorsViewController.h"
#import "MBProgressHUD.h"
#import "WSJSONBuilder.h"
#import "WSPlistHelper.h"
#import "WSImagePathTable.h"
#import "WSOfflineDataManager.h"
#import "WSFacTable.h"
#import "WSFuncsBean_opt.h"

#import "GetMD5byStr.h"
#import "WSOfflineDataDBService.h"
#import "WSAcvtDBService.h"
#import "WSBaseDictsDBService.h"

#define kFetchDealersNotifyName @"fetchdealersnotifyname"
#define kUploadPfizerBusinessNotifyName @"uploadpfizerbusinessnotifyname"

const int kTableViewShowDealersTag = 1100;

@interface WCPrizerBusinessAddEntityViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSString *visitTypeIndex;
}

@property (nonatomic, strong)NSMutableArray *iTableViewDataSource;
@property (nonatomic, strong)NSMutableDictionary *iDicSelectedDatas;
@property (nonatomic, strong)NSMutableArray *iDealersResultArray;

//@property (nonatomic, strong) WSFacObject *facObjects;
@property (nonatomic, strong) NSArray *qstDataSource;

- (BOOL)uploadImages;

@end

@implementation WCPrizerBusinessAddEntityViewController
@synthesize iTableViewDataSource = _iTableViewDataSource;
@synthesize iDicSelectedDatas = _iDicSelectedDatas;
@synthesize iDealersResultArray = _iDealersResultArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithFuncs:(WSFuncsBean*)funcs dataSource:(NSDictionary *)dataSource {
    self = [super initWithFuncs:funcs];
    if (self) {
        // Do something
//        _facObjects = [dataSource objectForKey:@"fac"];
        _qstDataSource = [dataSource objectForKey:@"fac_qst"];
    }
    return self;
}

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    self = [super initWithFuncs:funcs];
    if (self) {
        // Do something
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self initSelectingDealerElements];
    [self addFuncsOtherBeanView];
    [self addOptView];

//    self.photoBrowseView.isPhotoNecessary = YES;
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *upload = [[UIBarButtonItem alloc]initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
    
    NSMutableArray *toolBarArr = [NSMutableArray arrayWithObjects:upload,nil];
    
    if(self.m_ParentViewController != nil)
    {
        self.m_ParentViewController.navigationController.toolbarHidden = NO;
        if (self.m_ParentViewController.toolbarItems != nil) {
            [toolBarArr addObjectsFromArray:self.m_ParentViewController.toolbarItems];
        }
        self.m_ParentViewController.toolbarItems = toolBarArr;
    }else
    {
        self.navigationController.toolbarHidden = NO;
        if (self.toolbarItems != nil) {
            [toolBarArr addObjectsFromArray:self.toolbarItems];
        }
        self.toolbarItems = toolBarArr;
    }
    
    [self redis];
}


/*! 处理回显据
 */
- (void)redis {
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    
    /*
    NSInteger otherCount = [self.currentFuncs.otherArray count];
    for (int i = 0; i < otherCount; i++) {
        WSFuncsBean_other *otherBean = [self.currentFuncs.otherArray objectAtIndex:i];
        NSString *type = otherBean.tpy;
        if ([type isEqualToString:OTHER_TPY_T] ||
            [type isEqualToString:OTHER_TPY_N]) {
            UIView *view = [self.contentScrollView viewWithTag:OTHER_TEXTFIELD_TAG + i];
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)view;
                for (WSFacQstObject* object in _qstDataSource) {
                    NSString *qst_id = object.qst_id;
                    NSString *opt_val = object.opt_val;
                    if (opt_val && [qst_id isEqualToString:otherBean.col]) {
                        textField.text = opt_val;
                        break;
                    }
                }
            }
        } else if ([type isEqualToString:OTHER_TPY_TC]) {
            for (WSFacQstObject* object in _qstDataSource) {
                NSString *qst_id = object.qst_id;
                NSString *opt_val = object.opt_val;
                if (opt_val && [qst_id isEqualToString:otherBean.col]) {
                    _iDealersResultArray = [opt_val objectFromJSONString];
                    break;
                }
            }
        } else if ([type isEqualToString:OTHER_TPY_R]) {
            WSFacQstObject *dataSourceobject = nil;
            NSMutableDictionary *tableSourceDic = nil;
            NSArray *dictBeanArray = nil;
            NSString *opt_id = nil;
            NSString *opt_val = nil;
            NSString *qst_id = nil;
            for (WSFacQstObject* object in _qstDataSource) {
                opt_id = object.opt_id;
                opt_val = object.opt_val;
                qst_id = object.qst_id;
                if (qst_id && [qst_id isEqualToString:otherBean.col]) {
                    dataSourceobject = object;
                    break;
                }
            }
            if (dataSourceobject) {
                for (NSMutableDictionary *tableDic in self.iTableViewDataSource) {
                    NSString *col = [tableDic objectForKey:@"col"];
                    if ([col isEqualToString:otherBean.col]) {
                        dictBeanArray = [tableDic objectForKey:@"ds"];
                        tableSourceDic = tableDic;
                        break;
                    }
                }
            }
            if (dictBeanArray) {
                NSInteger count = [dictBeanArray count];
                for (int i = 0; i < count; i++) {
                    WSDictBean *bean = [dictBeanArray objectAtIndex:i];
                    if ([bean.Id isEqualToString:opt_id]) {
                        NSString *selectedIndex = [NSString stringWithFormat:@"%d", i];
                        [tableSourceDic setObject:selectedIndex forKey:@"selectedindex"];
                        [self.iDicSelectedDatas setObject:bean forKey:otherBean.col];
                        break;
                    }
                }
            }
        }
    }
     */

}

- (NSMutableArray *)iTableViewDataSource
{
    if (_iTableViewDataSource == nil) {
        _iTableViewDataSource = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _iTableViewDataSource;
}

- (NSMutableDictionary *)iDicSelectedDatas
{
    if (_iDicSelectedDatas == nil) {
        _iDicSelectedDatas = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _iDicSelectedDatas;
}

- (NSMutableArray *)iDealersResultArray
{
    if (_iDealersResultArray == nil) {
        _iDealersResultArray = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _iDealersResultArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UITableView *view = (UITableView *)[self.view viewWithTag:kTableViewShowDealersTag];
    if (view == nil) {
        if (self.iDealersResultArray != nil && [self.iDealersResultArray count] > 0) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.height, 400) style:UITableViewStyleGrouped];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tag = kTableViewShowDealersTag;
            [self.contentScrollView addSubview:tableView];
            self.y_point += (400 + 5);
        }
    }else{
        if (self.iDealersResultArray && [self.iDealersResultArray count] > 0){
            [view reloadData];
        }else{
            [view removeFromSuperview];
            self.y_point -= (400 + 5);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private function

- (void)upload
{
 
    if ([self.photoBrowseView.imageIDArray count] < 1) {
        NSString *TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    // add time location scheme
    NSMutableDictionary *jsoninfo = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if ([other.tpy isEqualToString:OTHER_TPY_N] ||[other.tpy isEqualToString:OTHER_TPY_T] ) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG+i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ? @"" : field.text;
                [jsoninfo setValue:value forKey:other.col];
            }else if ([infoView isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)infoView;
                NSString *value = (textView.text == nil) ?  @"" : textView.text;;
                if (jsoninfo == nil) {
                    jsoninfo = [[NSMutableDictionary alloc] init];
                }
                [jsoninfo setValue:value forKey:other.col];
            }
        }
    }
    
    // add visite type
    [self.iDicSelectedDatas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        WSDictBean *bean = (WSDictBean *)obj;
        NSString *strKey = (NSString *)key;
        [jsoninfo setObject:visitTypeIndex ? visitTypeIndex : @"" forKey:strKey];
    }];
    
    // add dealer person
    __block NSMutableString *dealsers = [[NSMutableString alloc] initWithCapacity:8];
    [dealsers setString:@""];
    [self.iDealersResultArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSNumber *numberid = [dic objectForKey:@"id"];
        NSString *strid = [numberid stringValue];
        if (dealsers != nil && [dealsers length] > 0) {
            [dealsers appendFormat:@",%@", strid];
        }else{
            [dealsers appendString:strid];
        }
    }];
    [jsoninfo setObject:dealsers forKey:@"dealer"];
    
    NSString *checkResult = [self checkContentBeforeUpload:jsoninfo];
    if (checkResult) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@ 为必填项", checkResult] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }

    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
    [jsoninfo setObject:[NSNumber numberWithBool:hasPhoto] forKey:@"photo"];
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadBusinessDataFinshed:) name:notifyID object:nil];
    
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
//    if (_facObjects) {
//        self.md5 = _facObjects.img_idx;
//    }

    // 先插入离线数据库
    NSString *postData = [WSJSONBuilder buildPfizerBusinessStringWithDic:jsoninfo functionBean:self.currentFuncs withMd5:self.md5];
    BOOL insertUploadDataIsSucceed = [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    
    if (!insertUploadDataIsSucceed) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    /*! 插入回显数据
     *  由于这几个字段都是订制化
     *  回显数据暂时插入 fac、facQst 中
     */
    if (![self insertFacData:jsoninfo] ) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    // 开始上传数据
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadPfizerBusinessDatas:jsoninfo functionBean:self.currentFuncs withMd5:self.md5 notifyName:notifyID];
    
    
    [self uploadImages];
    [self backToParent];
    
}

- (NSString *)checkContentBeforeUpload:(NSDictionary *)jsoninfo {

    NSString *visitType = [jsoninfo objectForKey:@"visitType"];
    if (!visitType || [visitType isEqualToString:@""]) {
        return @"拜访类型";
    }
    
    NSString *theme = [jsoninfo objectForKey:@"theme"];
    if (!theme || [theme isEqualToString:@""]) {
        return @"主题";
    }
    
//    NSString *personCount = [jsoninfo objectForKey:@"personCount"];
//    if (!personCount || [personCount isEqualToString:@""]) {
//        return @"人数";
//    }
    
    NSString *place = [jsoninfo objectForKey:@"place"];
    if (!place || [place isEqualToString:@""]) {
        return @"address";
    }
    
    NSString *dealer = [jsoninfo objectForKey:@"dealer"];
    if (!dealer || [dealer isEqualToString:@""]) {
        return @"经销商";
    }
    
    WSDictBean *bean = [self.iDicSelectedDatas objectForKey:@"visitType"];
    if (bean && bean.name && [bean.name isEqualToString:@"四类"]) {
        BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
        if (!hasPhoto) {
            return @"camera_capture";
        }
    }
    
    return nil;
}

- (BOOL)insertFacData:(NSDictionary *)jsoninfo {
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    
//    NSMutableArray* facValues = [[NSMutableArray alloc]init];
//    NSString *srid = @"null";
//    if (self.currentStore
//        && self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp
//        && self.currentStore.srid
//        && [self.currentStore.srid length] > 0) {
//        srid = [self.currentStore.srid copy];
//    }
//    // sr_id
//    [facValues addObject:srid];
//    // acvt_id
//    [facValues addObject:@"null"];
//    // emp_id
//    [facValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    // rspn_id
//    [facValues addObject:@"null"];
//    // store_id
//    [facValues addObject:[NSString stringNotNilWithValue:self.currentStore.Id]];
//    // biz_date
//    [facValues addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
//    // upload_flag
//    [facValues addObject:@"0"];
//    // upload_date
//    [facValues addObject:[WSCurrentTime getDateString]];
//    // img_idx
//    [facValues addObject:self.md5];
//    // func_code
//    [facValues addObject:self.currentFuncs.fc];
//    // func_view
//    [facValues addObject:self.currentFuncs.fv];
//    // is_planed
//    [facValues addObject:@"0"];
//    // memo
//    [facValues addObject:@"null"];
//    
//    
//    NSMutableArray *qstValues = [[NSMutableArray alloc] init];
//    for (WSFuncsBean_other *otherBean in self.currentFuncs.otherArray) {
//        NSString *value = [NSString stringWithValue:[jsoninfo objectForKey:otherBean.col]];
//        /*! 如果 value 为空
//         *  不插入数据库
//         */
//        if (!value || [value length] == 0) {
//            continue;
//        }
//        
//        NSString *type = otherBean.tpy;
//        
//        NSMutableArray *row = [[NSMutableArray alloc] init];
//        
//        // ans_id
//        [row addObject:self.md5];
//        // qst_id
//        NSString *col = otherBean.col;
//        if (col) {
//            [row addObject:col];
//        } else {
//            [row addObject:@"null"];
//        }
//        // opt_id
//        if ([type isEqualToString:OTHER_TPY_R]) {
//            [row addObject:value];
//        } else {
//            [row addObject:@"null"];
//        }
//
//        // opt_val
//        if (!type) {
//            [row addObject:@"null"];
//        } else if ([type isEqualToString:OTHER_TPY_T] ||
//                   [type isEqualToString:OTHER_TPY_N]) {
//            [row addObject:value];
//        } else if ([type isEqualToString:OTHER_TPY_R]) {
//            WSDictBean *bean = [self.iDicSelectedDatas objectForKey:col];
//            [row addObject:bean.name];
//        } else if ([type isEqualToString:OTHER_TPY_P]) {
//            if ([value isEqualToString:@"1"]) {
//                NSString *photoJson = [self.photoBrowseView.imageIDArray JSONString];
//                [row addObject:photoJson];
//            } else  {
//                continue;
//            }
//        } else if ([type isEqualToString:OTHER_TPY_TC]) {
//            NSString *jsonResult = [self.iDealersResultArray JSONString];
//            [row addObject:jsonResult];
//        } else {
//            [row addObject:@"null"];
//        }
//        
//        // qst_type
//        if (type) {
//            [row addObject:type];
//        } else {
//            [row addObject:@"null"];
//        }
//        [qstValues addObject:row];
//    }
//    
//    return [[WSFacTable sharedTable] insertWithFacArray:facValues Qst:qstValues];
    return YES;
}

+ (NSString * )gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

- (void)uploadBusinessDataFinshed:(id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadPfizerBusinessNotifyName object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error == nil) {
        NSString *userInfo = [[sender userInfo] objectForKey:DATAS];
        NSDictionary *dicRes = [userInfo objectFromJSONString];
        NSNumber *flag = [dicRes objectForKey:@"flag"];
        NSString *tip = nil;
        if ([flag intValue] == 1) {
            tip = NSLocalizedString(@"upload_success", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }else{
            tip = NSLocalizedString(@"fail_upload", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }
}

- (void)addRadioElement:(id)sender atIndex:(NSString *)index
{
    if (sender != nil && [sender isKindOfClass:[WSFuncsBean_other class]]) {
        WSFuncsBean_other *other = (WSFuncsBean_other *)sender;

        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:other.filter];
        
        if (filterArray == nil || [filterArray count] == 0) return;
        //group name
        NSString *sectionName = other.name;
        NSString *col = other.col;
        
        float hight = [filterArray count] * 35.0f + 80;
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.height, hight) style:UITableViewStyleGrouped];
        tv.delegate = self;
        tv.dataSource = self;
        tv.rowHeight = 35.0f;
        tv.scrollEnabled = NO;
        tv.backgroundColor = [UIColor clearColor];
        tv.backgroundView = nil;
        tv.tag = OTHER_TABLEVIEW_TAG + [index integerValue];
        [self.contentScrollView addSubview:tv];
        self.y_point += (hight+5);
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
        [dic setObject:sectionName forKey:@"sectionname"];
        [dic setObject:tv forKey:@"tableview"];
        [dic setObject:col forKey:@"col"];
        [dic setObject:filterArray forKey:@"ds"];
        [dic setObject:@"" forKey:@"selectedindex"];
        [self.iTableViewDataSource addObject:dic];
    }
}

- (void)initSelectingDealerElements
{
    UIFont *labelFont = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17.0f] : [UIFont systemFontOfSize:20];
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.y_point, 200, 29)];
    titlelabel.font = labelFont;
    titlelabel.text = NSLocalizedString(@"other_call_dealer", nil);
    [self.contentScrollView addSubview:titlelabel];
    self.y_point += (20 + 5);
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, self.y_point, self.view.bounds.size.height/2, 29)];
    textField.tag = 1200;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.inputAccessoryView = self.upKeyBoardView;
    textField.placeholder = @"查询条件";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
//    [textField addTarget:self action:@selector(textWatcher:)];
    [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
    [self.contentScrollView addSubview:textField];
    
    UIButton *btnQuery = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnQuery setTitle:NSLocalizedString(@"query", nil) forState:UIControlStateNormal];
    btnQuery.frame = CGRectMake(10+self.view.bounds.size.height/2+5, self.y_point, 70, 30);
    [btnQuery addTarget:self action:@selector(queryDealers:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentScrollView addSubview:btnQuery];
    self.y_point += (30 + 5);
    
    if (self.iDealersResultArray && [self.iDealersResultArray count] > 0) {
//        UITableView *tableView = [[[UITableView alloc] initWithFrame:CGRectMake(10, self.y_point, self.view.bounds.size.height, 200)] autorelease];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.height, 400) style:UITableViewStyleGrouped];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = kTableViewShowDealersTag;
        [self.contentScrollView addSubview:tableView];
        self.y_point += (400 + 5);
    }
}

- (void)queryDealers:(id)sender
{
//    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFinshed:) name:kFetchDealersNotifyName object:nil];
    
    UITextField *field = (UITextField *)[self.contentScrollView viewWithTag:1200];
    NSString *filter = (field.text != nil && [field.text length] > 0) ? field.text : @"";
    WSRequestHelper *uploadHandler = [WSRequestHelper shareInstance];
    [uploadHandler fetchDealersWithFilter:filter notifyName:kFetchDealersNotifyName];
    
    [self querying_messageTips];

}

- (void)fetchFinshed:(id)sender
{    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFetchDealersNotifyName object:nil];
    NSString *userInfo = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dicSender = [userInfo objectFromJSONString];
    
    NSNumber *flag = [dicSender objectForKey:@"flag"];
    if ([flag boolValue]) {
        NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:100];
        NSArray *spestores = [dicSender objectForKey:@"spestore"];
        for (NSDictionary *dic in spestores) {
            NSString *name = [dic objectForKey:@"name"];
            if (name != nil && [name isKindOfClass:[NSString class]] && [name length] > 0) {
                [sourceArray addObject:dic];
            }
        }
        WCPfizerSelectedDoctorsViewController *vc = [[WCPfizerSelectedDoctorsViewController alloc] initWithSourceArray:sourceArray andResultArray:self.iDealersResultArray];
        [self.navigationController pushViewController:vc animated:YES];        
    }
}


- (NSMutableDictionary *)findDataFromDataSourceByTableView:(UITableView *)aTableView
{
    __block NSMutableDictionary *dicinfo = nil;
    
    [self.iTableViewDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dic = (NSMutableDictionary *)obj;
        UITableView *view = [dic objectForKey:@"tableview"];
        if (view == aTableView) {
            dicinfo = dic;
            *stop = YES;
        }
    }];
    return dicinfo;
}

- (BOOL)uploadImages
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    NSMutableArray *dicValueArray = [[NSMutableArray alloc] init];
    
    for (NSString *imageID in self.photoBrowseView.imageIDArray) {

        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        if (filePath) {
            
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
            
            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
            
            BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
            if (!insertPhotoDataIsSucceed) {
                return insertPhotoDataIsSucceed;
            }
            [uploadMgr uploadImageWithFilePath:filePath
                                        params:params
                                           url:URL_IMAGEUPLOAD
                                    notifyName:notifyID
                                           md5:self.md5];

            
            NSArray* array=[NSArray arrayWithObjects:self.md5,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
            [dicValueArray addObject:array];
        }
    }
    
    if (dicValueArray && [dicValueArray count] > 0) {
        [[WSImagePathTable sharedTable] updateWithImageIDX:self.md5 withValuesArray:dicValueArray];
    }
    else
    {
        [[WSImagePathTable sharedTable] deleteWithImageIDX:self.md5];
    }
    
    for (NSDictionary *dic in self.photoTypeArray)
    {
        NSArray *photosArray = [dic objectForKey:@"photos"];
        NSString *photoType = [dic objectForKey:@"typeId"];
        
        for (NSString *imageID in photosArray)
        {
            
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
            
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID andImageType:photoType];
            
            BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:nil];
            
            if (!insertPhotoDataIsSucceed) {
                return insertPhotoDataIsSucceed;
            }
            // 另一种上传方式
            [uploadMgr uploadImageWithFilePath:filePath
                                        params:params
                                           url:URL_IMAGEUPLOAD
                                    notifyName:notifyID
                                           md5:self.md5];


        }
    }
    return YES;
}

#pragma mark - table datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *name = nil;
    
    if (tableView.tag == kTableViewShowDealersTag) {
        return name;
    }
    
    NSDictionary *info = [self findDataFromDataSourceByTableView:tableView];
    if (info != nil) {
        name = [info objectForKey:@"sectionname"];
    }
    return name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    
    if (tableView.tag == kTableViewShowDealersTag) {
        return [self.iDealersResultArray count];
    }
    
    NSDictionary *info = [self findDataFromDataSourceByTableView:tableView];
    if (info != nil) {
        NSArray *datas = [info objectForKey:@"ds"];
        number = [datas count];
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSDictionary *info = [self findDataFromDataSourceByTableView:tableView];
    if (info != nil) {
        NSString *identify = [info objectForKey:@"col"];
        cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        
        NSArray *datas = [info objectForKey:@"ds"];
        WSDictBean *bean = [datas objectAtIndex:indexPath.row];
        cell.textLabel.text = bean.name;
        
        NSString *selectedIndex = [info objectForKey:@"selectedindex"];
        if (selectedIndex != nil && [selectedIndex length] > 0) {
            int index = [selectedIndex intValue];
            cell.accessoryType = ( index == indexPath.row ) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        if (tableView.tag == kTableViewShowDealersTag)
        {
            NSString *stridentify = @"dealersidentify";
            cell = [tableView dequeueReusableCellWithIdentifier:stridentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stridentify];
            }
            NSDictionary *dic = [self.iDealersResultArray objectAtIndex:indexPath.row];
            NSString *name = [dic objectForKey:@"name"];
            cell.textLabel.text = name;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == kTableViewShowDealersTag) {
        NSDictionary *dic = [self.iDealersResultArray objectAtIndex:indexPath.row];
        [self.iDealersResultArray removeObject:dic];
        NSArray *delIndexPath = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:delIndexPath withRowAnimation:UITableViewRowAnimationRight];
        if ([self.iDealersResultArray count] == 0) {
            [tableView removeFromSuperview];
            self.y_point -= (400+5);
        }
    }else{
        NSMutableDictionary *info = [self findDataFromDataSourceByTableView:tableView];
        NSString *selectedIndex = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        visitTypeIndex = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        [info setObject:selectedIndex forKey:@"selectedindex"];
        NSArray *beans = [info objectForKey:@"ds"];
        WSDictBean *bean = [beans objectAtIndex:indexPath.row];
        [self.iDicSelectedDatas setObject:bean forKey:[info objectForKey:@"col"]];
        [tableView reloadData];
    }
}

- (NSArray *)getImagePathFromDataBase {
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    
    NSArray *photoIdArray = nil;
    /*
    for (WSFacQstObject* object in _qstDataSource) {
        NSString *qst_type = object.qst_type;
        if (qst_type && [qst_type isEqualToString:OTHER_TPY_P]) {
            NSString *opt_val = object.opt_val;
            photoIdArray = [opt_val objectFromJSONString];
        }
    }
     */
    return photoIdArray;
}

@end
