//
//  WCMarketActivityForAcvt.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/20/13.
//
//

#import "WSMarketActivityForAcvt.h"
#import "WSAcvtBean.h"
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSDictBean.h"
#import "WSBusiAcvtBean.h"
#import "WSBusiAcvtBeanArray.h"
#import "WSSpbaInfoBean.h"
#import "WSSpbaInfoBeanArray.h"
//#import "ConfigFileController.h"
#import "WSAcvtShowBeanArray.h"
#import "WSAcvtShowBean.h"
#import "WCEvaluatePersonViewController.h"
#import "WSRequestHelper.h"
#import "WCPfizerSelectedDoctorsViewController.h"
#import "WCPrizerEvaluateView.h"
#import "MBProgressHUD.h"
#import "WSAppData.h"
#import "WSBaseStoreDataTable.h"
#import "WSVisitStoreActionTable.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSPlistHelper.h"
#import "WSBaseDictsDBService.h"

#define WCBusiAcvtMeetingTime @"busiAcvtMeetingTime"
#define WCFetch_Notify @"fetchParticipantsNotify"
#define WCMeetingPersonCount @"WCMeetingPersonCount"
#define WCMeetingAddress @"WCMeetingAddress"
#define WCUploadMeetingInfo @"WCUploadMeetingInfo"

#define kMarketActivityEdge (INTERFACE_IS_PAD ? 44 : 22)
#define kMarketActivityFontSizeForIpadMini 22

@interface WSMarketActivityForAcvt ()/*<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,WCPrizerEvaluateViewDelegate>*/

@property (nonatomic, strong)NSMutableArray *iMeetingPerson;
@property (nonatomic, strong)UITableView *iTableView;
@property (nonatomic, strong)UIScrollView *iScrollView;
@property (nonatomic, assign)int iUIHeight;
@property (nonatomic, strong)NSMutableDictionary *iEvaluateResultDictory;
@property (nonatomic, copy) NSString *iMeetingPersonCount;
@property (nonatomic, copy) NSString *iMeetingAddress;
@property (nonatomic, copy) NSString *iFindName;
@property (nonatomic, strong)UITextField *iFirstResponder;
@property (nonatomic, assign)float iMoveHeight;


@end

@implementation WSMarketActivityForAcvt
@synthesize iMeetingPerson = _iMeetingPerson;
@synthesize iTableView = _iTableView;
@synthesize iScrollView = _iScrollView;
@synthesize iUIHeight = _iUIHeight;
@synthesize iEvaluateResultDictory = _iEvaluateResultDictory;
@synthesize iMeetingAddress = _iMeetingAddress;
@synthesize iMeetingPersonCount = _iMeetingPersonCount;
@synthesize iFindName = _iFindName;
//@synthesize iBackup = _iBackup;

//@synthesize busiAcvtBean = _busiAcvtBean;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _iMeetingPerson = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}

#pragma mark - init & dealloc
- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    self = [super initWithAcvt:anAcvt Funcs:funcs Store:store];
    if (self) {
        // Do something
    }
    return self;
}


#pragma mark - view cycle

- (void)loadView
{
    [super loadView];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.iScrollView = scrollview;
    self.iScrollView.scrollEnabled = YES;
    self.iScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentScrollView addSubview:scrollview];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    int height = self.iUIHeight;
    [self addAcvtshowBeansToView:self.iScrollView viewHight:&height];
    self.iUIHeight = height;
    self.iUIHeight += 5;
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }

	// Do any additional setup after loading the view.
    [self addMeetingTimeCheckBox];
    
    // init data
    WSBusiAcvtBeanArray *busiAcvtArray = [[WSBusiAcvtBeanArray alloc] initWithObject:[WSAppData getObjectbyKey:@"busiAcvt"]];
    int acvtId = [self.m_currentAcvt.acvtId intValue];
    NSArray *beans = [busiAcvtArray getBusiAcvtArrayByAcvtId:acvtId];
    if (beans != nil && [beans count] > 0) {
        WSBusiAcvtBean *bean = [beans objectAtIndex:0];
        if (bean != nil && [bean.isMyAcvt isEqualToString:@"Y"]) {
//            [self addmeetingNumberField];
//            [self addActivityLocationField];
//            [self addPersonUIByType:@"chairman"];
//            [self addPersonUIByType:@"lecturer"];
        }
    }
//    [self addMeetingPerson];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.iScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);

    [self addToolBar];

//    [self addMeetingPersonTableview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)iEvaluateResultDictory
{
    if (_iEvaluateResultDictory == nil) {
        _iEvaluateResultDictory = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _iEvaluateResultDictory;
}

#pragma mark - private functions

- (void)addAcvtshowBeansToView:(UIView *)aView viewHight:(int *)aHight
{
    WSAcvtShowBeanArray *acvtShowArray = [WSAppData getObjectbyKey:ACVTSHOW];
    if (acvtShowArray != nil) {
        int acvtid = [self.m_currentAcvt.acvtId intValue];
        NSArray *acvtshowBeans = [acvtShowArray getAcvtshowbeansWithAcvtid:acvtid];
        for (WSAcvtShowBean *bean in acvtshowBeans) {
            if ([bean.iName length] > 0) {
                UIFont *font = [UIFont systemFontOfSize:UI_Font];
                CGSize size = [bean.iName ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.width lineBreakMode:NSLineBreakByWordWrapping];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, 10 + (*aHight), self.view.bounds.size.width, size.height+5)];
                label.numberOfLines = 0;
                label.font = font;
                label.text = bean.iName;
                [aView addSubview:label];
                (*aHight) += label.size.height;
                label = nil;
            }
        }
    }
}


- (void)addMeetingTimeCheckBox
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* filterArray = [service queryDictsForAcvtGridWithFilter:WCBusiAcvtMeetingTime];
    
    //Add meeting time label
    if (filterArray != nil) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 40)];
        UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
        timeLabel.font = labelFont;
        timeLabel.text = NSLocalizedString(@"会议时间 *", nil);
        [self.iScrollView addSubview:timeLabel];
        self.iUIHeight += (5+40);
        if (self.iUIHeight > self.iScrollView.contentSize.height) {
            self.iScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.iUIHeight);
        }
        
//        for (WSDictBean *bean in filterArray) {
//            [self addCheckBoxToView:self.iScrollView withDictBean:bean];
//        }
        
        if (self.iUIHeight > self.iScrollView.contentSize.height) {
            self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
        }
    }

}


//！！！旧acvt代码都已删除，此页面与新acvt代码不兼容，目前不知道使用场景，遇见使用此页面时，应该根据新acvt代码重构。

/*
- (void)addCheckBoxToView:(UIView *)aView withDictBean:(WSDictBean *)aDictBean
{
    BOOL bfind = NO;
    NSString *times = [self.markDictionary objectForKey:WCBusiAcvtMeetingTime];
    if (times != nil && [times length] > 0) {
        NSArray *array = [times componentsSeparatedByString:@","];
        for (NSString *timeId in array) {
            if ([timeId isEqualToString:aDictBean.Id]) {
                bfind = YES;
                break;
            }
        }
    }
    
    int tag = [aDictBean.Id intValue];
    UIButton *checkboxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkboxBtn.tag = tag;
    [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-unchecked.png"] forState:UIControlStateNormal];
    [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
    [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    if (bfind) {
        checkboxBtn.selected = YES;
    }
    [checkboxBtn addTarget:self action:@selector(checkboxPressed:) forControlEvents:UIControlEventTouchUpInside];
    checkboxBtn.frame = CGRectMake(kMarketActivityEdge, self.iUIHeight, 40, 40);
    [aView addSubview:checkboxBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, self.iUIHeight, 200, 40)];
    UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
    titleLabel.font = labelFont;
    titleLabel.text = aDictBean.name;
    [aView addSubview:titleLabel];
    
    self.iUIHeight += (5 + 40);
}

- (void)checkboxPressed:(id)sender
{
    UIButton *btnCheckBox = (UIButton *)sender;
    btnCheckBox.selected = (btnCheckBox.isSelected) ? NO : YES;
    
    int tag = btnCheckBox.tag;
    NSString *val = [self.markDictionary objectForKey:WCBusiAcvtMeetingTime];
    if (val == nil || [val isEqualToString:@""]) {
        if (btnCheckBox.isSelected) {
            [self.markDictionary setObject:[NSString stringWithFormat:@"%d", tag] forKey:WCBusiAcvtMeetingTime];
        }
    }else{
        NSArray *array = [val componentsSeparatedByString:@","];
        
        __block int index = -1;
        NSIndexSet *set = [array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString *valId = (NSString *)obj;
            if ([valId intValue] == tag) {
                index = idx;
                return YES;
            }
            return NO;
        }];
        
        if ([set count] == 0) {
            if (btnCheckBox.isSelected) {
                NSString *vals = [NSString stringWithFormat:@"%@,%d", val, tag];
                [self.markDictionary setObject:vals forKey:WCBusiAcvtMeetingTime];
            }
        }else{
            __block NSMutableString *ids = [NSMutableString stringWithString:@""];
            if (!btnCheckBox.isSelected && index > -1) {
                NSMutableArray *selects = [NSMutableArray arrayWithArray:array];
                [selects removeObjectAtIndex:index];
                [selects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *valObj = (NSString *)obj;
                    if (idx == 0) {
                        [ids setString:valObj];
                    }else{
                        [ids appendFormat:@",%@", valObj];
                    }
                }];
            }else if(btnCheckBox.isSelected){
                if (index == -1) {
                    [ids setString:val];
                    [ids appendFormat:@",%d",tag];
                }
            }
            [self.markDictionary setObject:ids forKey:WCBusiAcvtMeetingTime];
        }
    }
    
//    NSLog(@"%@", [self.markDictionary objectForKey:WCBusiAcvtMeetingTime]);
}

- (void)addmeetingNumberField
{    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 29)];
    UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
    titleLable.font = labelFont;
    titleLable.text = @"参加人数 *";
    [self.iScrollView addSubview:titleLable];
    self.iUIHeight += (5+29);
    
    UITextField *textField = [[WSHTextField alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, INTERFACE_IS_PAD ? 346 : (320 - kMarketActivityEdge * 2), 38)];
    textField.font = [UIFont systemFontOfSize:UI_Font];
    textField.delegate = self;
    textField.tag = 1550;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"请输入参加人数";
    [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
    [self addCancellOKButton:textField];
    if (self.iMeetingPersonCount != nil && [self.iMeetingPersonCount length] > 0) {
        textField.text = self.iMeetingPersonCount;
    }
    [self.iScrollView addSubview:textField];
    self.iUIHeight += (5+38);
    
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }
}

- (void)addActivityLocationField
{
//    int height = self.tableView.tableHeaderView.frame.size.height;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 29)];
    UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
    titleLable.font = labelFont;
    titleLable.text = @"活动地点 *";
    [self.iScrollView addSubview:titleLable];
    self.iUIHeight += (5+29);
    
    
    UITextField *textField = [[WSHTextField alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, INTERFACE_IS_PAD ? 346 : (320 - kMarketActivityEdge * 2), 38)];
    textField.font = [UIFont systemFontOfSize:UI_Font];
    textField.tag = 1560;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = @"最多输入50个字";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
    [self addCancellOKButton:textField];
    
    if (self.iMeetingAddress != nil && [self.iMeetingAddress length] > 0) {
        textField.text = self.iMeetingAddress;
    }
    [self.iScrollView addSubview:textField];
    self.iUIHeight += (38+5);
    
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }
}

- (void)addPersonUIByType:(NSString *)aType
{
//    NSString *title = (aType != nil && [aType isEqualToString:@"chairman"]) ? @"主席：" : @"讲者：";
//    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, self.iUIHeight, 200, 29)];
//    UIFont *labelFont = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17.0f] : [UIFont systemFontOfSize:20];
//    titleLable.font = labelFont;
//    titleLable.text = title;
//    [self.iScrollView addSubview:titleLable];
//    self.iUIHeight += (5+29);
    
    //添加人员和评估按钮
    NSArray *spbaInfoArray = [WSAppData getObjectbyKey:@"spbaInfo"];
    if (spbaInfoArray) {
        
        WSSpbaInfoBeanArray *array = [[WSSpbaInfoBeanArray alloc] initWithObject:spbaInfoArray];
        NSArray *beansArray = [array getspbaInfoBeansByType:aType andWithAcvtId:[self.m_currentAcvt.acvtId intValue]];
        
        if (beansArray != nil && [beansArray count] > 0) {
            NSString *title = (aType != nil && [aType isEqualToString:@"chairman"]) ? @"主席：" : @"讲者：";
            UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 29)];
            UIFont *labelFont = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17.0f] : [UIFont systemFontOfSize:kMarketActivityFontSizeForIpadMini];
            titleLable.font = labelFont;
            titleLable.text = title;
            [self.iScrollView addSubview:titleLable];
            self.iUIHeight += (5+29);
        }
        
        for (WSSpbaInfoBean *bean in beansArray) {
            NSString *personid = [NSString stringWithValue: bean.spbaInfoId];
            NSDictionary *dicInfo = [self.iEvaluateResultDictory objectForKey:personid];
            WCPrizerEvaluateView *view = [[WCPrizerEvaluateView alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 80) withSpbaInfoBean:bean withEvaluatePerson:dicInfo];
            view.iDelegate = self;
            [self.iScrollView addSubview:view];
            self.iUIHeight += (5+80);
        }
    }
    
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }
}

- (void)addMeetingPerson
{
//    int height = self.tableView.tableHeaderView.frame.size.height;
    
    UIFont *labelFont = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17.0f] : [UIFont systemFontOfSize:UI_Font];

    UILabel *addPersonLable = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 29)];
    addPersonLable.font = labelFont;
    addPersonLable.text = @"添加与会者:";
    [self.iScrollView addSubview:addPersonLable];
    self.iUIHeight += (5+29);
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, INTERFACE_IS_PAD ? 346 : (320 - kMarketActivityEdge * 4 - 5), 38)];
    textField.font = [UIFont systemFontOfSize:UI_Font];
    textField.delegate = self;
    textField.tag = 1570;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = @"请输入关键字";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
    [self addCancellOKButton:textField];
    [self.iScrollView addSubview:textField];
    
    UIButton *btnEvaluate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnEvaluate.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [btnEvaluate setTitle:@"查找" forState:UIControlStateNormal];
    btnEvaluate.frame = CGRectMake(textField.frame.size.width + kMarketActivityEdge +5 , self.iUIHeight, 70, 38);
    [btnEvaluate addTarget:self action:@selector(FindParticipants:) forControlEvents:UIControlEventTouchUpInside];
    [self.iScrollView addSubview:btnEvaluate];
    self.iUIHeight += (5+38);
    
    if (self.iMeetingPerson && [self.iMeetingPerson count] > 0) {
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(kMarketActivityEdge, self.iUIHeight, 200, 29)];
        titleLable.font = labelFont;
        titleLable.text = @"与会者:";
        [self.iScrollView addSubview:titleLable];
        self.iUIHeight += (5+29);
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.iUIHeight, self.view.bounds.size.width, 200) style:UITableViewStyleGrouped];
        
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = 1100;
        tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self.iScrollView addSubview:tableView];
        self.iUIHeight += (5+200);
    }
    
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }
}

- (void)addMeetingPersonTableview
{
    UITableView *tv = (UITableView *)[self.iScrollView viewWithTag:1100];
    if (tv == nil) {
        if ((self.iMeetingPerson && [self.iMeetingPerson count] > 0)) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.iUIHeight, self.view.bounds.size.width, 200) style:UITableViewStyleGrouped];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tag = 1100;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.iUIHeight, self.view.bounds.size.width, 200)];
            view.backgroundColor = [UIColor whiteColor];
            tableView.backgroundView = view;
            view.autoresizingMask=UIViewAutoresizingFlexibleWidth;

            [self.iScrollView addSubview:tableView];
            self.iUIHeight += (5+200);
            [tableView reloadData];
        }
    }else{
        if (self.iMeetingPerson && [self.iMeetingPerson count] > 0) {
            [tv reloadData];
        }else{
            self.iUIHeight -= (5+200);
            [tv removeFromSuperview];
            CGSize size = CGSizeMake(self.iScrollView.contentSize.width, self.iScrollView.contentSize.height-(5+200));
            self.iScrollView.contentSize = size;
        }
    }
    
    if (self.iUIHeight > self.iScrollView.contentSize.height) {
        self.iScrollView.contentSize = CGSizeMake(self.iScrollView.contentSize.width, self.iUIHeight);
    }
}

- (void)FindParticipants:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFinshed:) name:WCFetch_Notify object:nil];
    
    //fetch doctor
    if (self.iFirstResponder != nil) {
        [self.iFirstResponder resignFirstResponder];
        self.iFirstResponder = nil;
    }
    NSLog(@"[findname = %@]", self.iFindName);
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr fetchDoctorsWithFilter:self.iFindName notifyName:WCFetch_Notify];
    
    NSString *tmpString = NSLocalizedString(@"querying_message",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];
    
}

- (void)fetchFinshed:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCFetch_Notify object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error && error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
        
    }else{
        NSString *userInfo = [[sender userInfo] objectForKey:DATAS];
        NSDictionary *dicSender = [userInfo objectFromJSONString];
        NSArray *arrayDoctors = [dicSender objectForKey:@"myOrgDoctor"];
        
        //sometimes name is nil
        __block NSMutableArray *array = [NSMutableArray array];
        [arrayDoctors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = (NSDictionary *)obj;
           NSString *name = [dic objectForKey:@"name"];
            if (name != nil && [name isKindOfClass:[NSString class]] && [name length] > 0) {
                [array addObject:dic];
            }
        }];
        
        WCPfizerSelectedDoctorsViewController *vc = [[WCPfizerSelectedDoctorsViewController alloc] initWithSourceArray:array andResultArray:self.iMeetingPerson];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
//    NSLog(@"%@", sender);
}

#pragma mark - table delegate & datasource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iMeetingPerson count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictory = [self.iMeetingPerson objectAtIndex:indexPath.row];
    NSString *name = [dictory objectForKey:@"name"];
    UIFont *font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17] : [UIFont systemFontOfSize:22];
    
    CGSize size = [name sizeWithFont:font constrainedToSize:CGSizeMake(self.view.bounds.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentify = @"meetingpersion";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    NSDictionary *dic = [self.iMeetingPerson objectAtIndex:indexPath.row];
    NSString *name = [dic objectForKey:@"name"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [self.iMeetingPerson objectAtIndex:indexPath.row];
    [self.iMeetingPerson removeObject:dic];
    
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
    if ([self.iMeetingPerson count] == 0) {
        [tableView removeFromSuperview];
        self.iUIHeight -= (5+200);
        CGSize size = CGSizeMake(self.iScrollView.contentSize.width, self.iScrollView.contentSize.height-(5+200));
        self.iScrollView.contentSize = size;
    }
}

#pragma mark - evaluate view delegate

- (void)evaluateView:(WCPrizerEvaluateView *)aView checkboxClicked:(id)sender withSpbaInfoBean:(WSSpbaInfoBean *)aBean
{
    UIButton *btnCheckBox = (UIButton *)sender;
    btnCheckBox.selected = (btnCheckBox.isSelected) ? NO : YES;
    NSString *personid = [aBean.spbaInfoId stringValue];
    NSMutableDictionary *dic = [self.iEvaluateResultDictory objectForKey:personid];
    if (dic == nil) {
        NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] initWithCapacity:4];        
        [valueDic setObject:@"" forKey:@"brandTrendId"];
        [valueDic setObject:@"" forKey:@"speechLevelId"];
         NSNumber *numNo = [NSNumber numberWithBool:btnCheckBox.isSelected];
        [valueDic setObject:numNo forKey:@"isMustRequried"];
        [valueDic setObject:personid forKey:@"id"];
        [valueDic setObject:aBean.name forKey:@"name"];
        [valueDic setObject:aBean.typ forKey:@"typ"];
        [valueDic setObject:self.m_currentAcvt.acvtId forKey:@"acvtId"];
        
        NSNumber *numId = aBean.spbaInfoId;
        [self.iEvaluateResultDictory setObject:valueDic forKey:[numId stringValue]];
    }else{
        [dic setObject:[NSNumber numberWithBool:btnCheckBox.isSelected] forKey:@"isMustRequried"];
    }
}

- (void)evaluateView:(WCPrizerEvaluateView *)aView evaluateButtonClicked:(id)sender withSpbaInfoBean:(WSSpbaInfoBean *)aBean
{
    NSString *personid = [aBean.spbaInfoId stringValue];
    NSDictionary *dic = [self.iEvaluateResultDictory objectForKey:personid];
    if (dic == nil) {
        NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] initWithCapacity:4];
        [valueDic setObject:@"" forKey:@"brandTrendId"];
        [valueDic setObject:@"" forKey:@"speechLevelId"];
        NSNumber *numNo = [NSNumber numberWithBool:NO];
        [valueDic setObject:numNo forKey:@"isMustRequried"];
        [valueDic setObject:personid forKey:@"id"];
        [valueDic setObject:aBean.name forKey:@"name"];
        [valueDic setObject:aBean.typ forKey:@"typ"];
        [valueDic setObject:self.m_currentAcvt.acvtId forKey:@"acvtId"];
        NSNumber *numId = aBean.spbaInfoId;
        [self.iEvaluateResultDictory setObject:valueDic forKey:[numId stringValue]];
    }
    WCEvaluatePersonViewController *tv = [[WCEvaluatePersonViewController alloc] initWithPersonId:[NSString stringNotNilWithValue:aBean.spbaInfoId] withResultDictory:self.iEvaluateResultDictory];
    
    [self.navigationController pushViewController:tv animated:YES];
    
}


#pragma mark - upload something
- (void)upload
{
    // Check upload
    NSMutableDictionary *dicInfo = [self checkUploadDataComplete];
    if ([[dicInfo allKeys] count] > 0) {
        NSMutableString *info = [[NSMutableString alloc] initWithCapacity:2];
        NSString *info1 = [dicInfo objectForKey:@"info1"];
        if (info1 != nil && [info1 length] > 0) {
            [info appendFormat:@"%@ 必须填写\n", info1];
        }
        
        NSString *info2 = [dicInfo objectForKey:@"info2"];
        if (info2 != nil && [info2 length] > 0) {
            [info appendFormat:@"%@ 必须完全评估", info2];
        }
        
        NSString *okTitle = NSLocalizedString(@"confirm", nil);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:info message:nil];
        [alert setCancelButtonWithTitle:okTitle block:nil];
        [alert show];
        return;
    }
    
    // insert table
    [self insertDataToTable];
    
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] initWithCapacity:8];
    //meeting time
    NSString *time = [self.markDictionary objectForKey:WCBusiAcvtMeetingTime];
    if (time != nil && [time isKindOfClass:[NSString class]]) {
        [jsonData setObject:time forKey:@"meetingtime"];
    }
    
    // address
    if (self.iMeetingAddress != nil && [self.iMeetingAddress length] > 0) {
        [jsonData setObject:self.iMeetingAddress forKey:@"addr"];
    }
    
    // counts
    if (self.iMeetingPersonCount != nil && [self.iMeetingPersonCount length] > 0) {
        [jsonData setObject:self.iMeetingPersonCount forKey:@"counts"];
    }
    
    // acvtId
    [jsonData setObject:self.m_currentAcvt.acvtId forKey:@"acvtId"];
    
    //spbaInfo array
    NSMutableArray *spbaInfo = [NSMutableArray array];
    NSArray *persons = [self makeMeetingPersonArray];
    if (persons != nil && [persons count] > 0) {
        [spbaInfo addObjectsFromArray:persons];
    }
    // evaluate person
    NSArray *evaluates = [self makeEvaluateValuesArray];
    if (evaluates != nil && [evaluates count] > 0) {
        [spbaInfo addObjectsFromArray:evaluates];
    }
    [jsonData setObject:spbaInfo forKey:@"spbaInfo"];

    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    NSString* postData = [WSJSONBuilder buildMarketActivityWithDic:jsonData acvtBean:self.m_currentAcvt functionBean:self.currentFuncs withMd5:self.md5];
    
    [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:NO NotifyName:notifyID];
    
    if (self.currentVisitAction) {
        [[WSVisitStoreActionTable sharedTable] updateAction:self.currentVisitAction toStatus:ActionDone];
    }

    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadMarketActityDatas:postData notifyName:notifyID];
    
    [self backToParent];
}


#pragma mark - perform table

- (BOOL)initMarkActivityDataFromTable
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *acvtid = self.m_currentAcvt.acvtId;
    NSString *bizdate = [WSCurrentTime getDateString];
    
    WSBaseStoreDataTable *handler = [WSBaseStoreDataTable sharedTable];
    
    [self.iEvaluateResultDictory removeAllObjects];
    [self.iMeetingPerson removeAllObjects];
    NSArray *resultArray = [handler queryWithEmpId:empid withAcvtId:acvtid withBizDate:bizdate];
    
    for (WSBaseStoreDataObject *object in resultArray) {
        NSString *type = object.type;
        if ([type isEqualToString:@"meetingtime"]) {
            NSString *time = object.item1;
            [self.markDictionary setObject:time forKey:WCBusiAcvtMeetingTime];
        }else if ([type isEqualToString:@"meetingpersoncount"]){
            NSString *meetingCount =object.item1;
            self.iMeetingPersonCount = meetingCount;
        }else if ([type isEqualToString:@"meetingaddress"]){
            NSString *address = object.item1;
            self.iMeetingAddress = address;
        }else if ([type isEqualToString:@"evaluateperson"]){
            NSString *personid = object.item1;
            NSString *name = object.item2;
            NSString *typ = object.item3;
            NSString *isMustRequired = object.item4;
            BOOL breq = ([isMustRequired isEqualToString:@"1"]) ? YES : NO;
            NSNumber *isMust = [NSNumber numberWithBool:breq];
            NSString *brandTrendId =object.item5;
            NSString *speechLevelId = object.item6;
            NSString *acvtId = object.item7;
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if (personid) {
                [dic setObject:personid forKey:@"id"];
            }
            
            if (name) {
                [dic setObject:name forKey:@"name"];
            }
            
            if (typ) {
                [dic setObject:typ forKey:@"typ"];
            }
            
            if (isMust) {
                [dic setObject:isMust forKey:@"isMustRequried"];
            }
            
            if (brandTrendId) {
                [dic setObject:brandTrendId forKey:@"brandTrendId"];
            }
            
            if (speechLevelId) {
                [dic setObject:speechLevelId forKey:@"speechLevelId"];
            }
            
            if (acvtId) {
                [dic setObject:acvtId forKey:@"acvtId"];
            }
            
            if (dic) {
                [self.iEvaluateResultDictory setObject:dic forKey:personid];
            }
            
            
            dic = nil;
        }else if ([type isEqualToString:@"meetingpersons"]){
            NSString *personid = object.item1;
            NSString *name = object.item2;
            NSString *typ = object.item3;
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:8];
            if ([NSNumber numberWithInteger:[personid intValue]]) {
                [dic setObject:[NSNumber numberWithInteger:[personid intValue]] forKey:@"id"];
            }
            
            if (name) {
                [dic setObject:name forKey:@"name"];
            }
            
            if (typ) {
                [dic setObject:typ forKey:@"typ"];
            }
            
            [self.iMeetingPerson addObject:dic];
            dic = nil;
        }
    }
    
    handler = nil;
    
    return YES;
}

- (void)insertDataToTable
{
    NSString *acvtId = self.m_currentAcvt.acvtId;
    
    WSBaseStoreDataTable *handler = [WSBaseStoreDataTable sharedTable];
    
    [handler deleteWithAcvtId:acvtId];
    
    NSString *type = @"meetingtime";
    NSString *time = [self.markDictionary objectForKey:WCBusiAcvtMeetingTime];
    [handler insertWithAcvtId:acvtId withType:type andITEM:time];
    
    type = @"meetingpersoncount";
    [handler insertWithAcvtId:acvtId withType:type andITEM:self.iMeetingPersonCount];
    
    type = @"meetingaddress";
    [handler insertWithAcvtId:acvtId withType:type andITEM:self.iMeetingAddress];
    
    type = @"evaluateperson";
    [handler InsertTableEvaluatePersonWithAcvtId:acvtId withType:type andEvaluateResult:self.iEvaluateResultDictory];

    type = @"meetingpersons";
    [handler insertTableMeetingPersonSqlWithAcvtId:acvtId withType:type andMeetingPersons:self.iMeetingPerson];

}

- (NSMutableDictionary *)checkUploadDataComplete
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:4];
    
    //必填________________//
    
    //会议时间
    NSString *val = [self.markDictionary objectForKey:WCBusiAcvtMeetingTime];
    if (val == nil || [val length] == 0) {
        [str appendString:@"会议时间"];
    }
    
    //参加人数
    if ([self.view viewWithTag:1550] != nil && (self.iMeetingPersonCount == nil || [self.iMeetingPersonCount length] == 0)) {
        NSString *temp = ([str length] > 0) ? [NSString stringWithFormat:@",%@", @"参加人数"] : @"参加人数";
        [str appendString:temp];
    }
    
    //会议地点
    if ([self.view viewWithTag:1560] != nil && (self.iMeetingAddress == nil || [self.iMeetingAddress length] == 0)) {
        NSString *temp = ([str length] > 0) ? [NSString stringWithFormat:@",%@", @"会议地点"] : @"会议地点";
        [str appendString:temp];
    }

    
    if ([str length] > 0) {
        [dic setObject:str forKey:@"info1"];
    }
    
    __block NSMutableString *str1 = [[NSMutableString alloc] initWithCapacity:4];
    
    [self.iEvaluateResultDictory enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *dicInfo = (NSDictionary *)obj;
        NSNumber *isRequired = [dicInfo objectForKey:@"isMustRequried"];
        if ([isRequired boolValue]) {
            NSString *brandTrendId = [dicInfo objectForKey:@"brandTrendId"];
            NSString *speechLevel = [dicInfo objectForKey:@"speechLevelId"];
            if ([brandTrendId length] == 0 || [speechLevel length] == 0) {
                NSString *strInfo = ([str1 length] > 0) ? [NSString stringWithFormat:@",%@", [dicInfo objectForKey:@"name"]] : [dicInfo objectForKey:@"name"];
                [str1 appendString:strInfo];
            }
        }
    }];
    
    if ([str1 length] > 0) {
        [dic setObject:str1 forKey:@"info2"];
    }
    
    return dic;
}

- (void)uploadMeetingInfoFinshed:(id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCUploadMeetingInfo object:nil];
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
        
    }else{

    }
}

- (NSArray *)makeMeetingPersonArray
{
    if (self.iMeetingPerson && [self.iMeetingPerson count] > 0) {
        __block NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:8];
        [self.iMeetingPerson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            if (self.m_currentAcvt.acvtId) {
                [newDic setObject:self.m_currentAcvt.acvtId forKey:@"acvtId"];
            }
            
            [array addObject:newDic];
        }];
        return array;
    }
    return nil;
}

- (NSArray *)makeEvaluateValuesArray
{
    __block NSMutableArray *array = [NSMutableArray array];
    [self.iEvaluateResultDictory enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *dicObj = (NSDictionary *)obj;
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithCapacity:8];
        [newDic addEntriesFromDictionary:dicObj];
        BOOL isMustRequired = [[newDic objectForKey:@"isMustRequried"] boolValue];
        if (isMustRequired) {
            [newDic removeObjectForKey:@"isMustRequried"];
            [array addObject:newDic];
        }
        newDic = nil;
    }];
    return array;
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"%s,[%@]", __FUNCTION__, textField.text);
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    self.iFirstResponder = textField;
    NSLog(@"%s,[%@]", __FUNCTION__, textField.text);
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
    NSLog(@"%s,[%@]", __FUNCTION__, textField.text);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
    NSLog(@"%s,[%@]", __FUNCTION__, textField.text);
    if (textField.tag == 1550) {
        self.iMeetingPersonCount = textField.text;
    }else if (textField.tag == 1560){
        self.iMeetingAddress = textField.text;
    }else if (textField.tag == 1570){
        self.iFindName = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    NSLog(@"%s,[%@]-[%@]", __FUNCTION__, textField.text, string);
     return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField             // called when 'return' key pressed. return NO to ignore.
{
//    NSLog(@"%s,[%@]", __FUNCTION__, textField.text);
    self.iFirstResponder = nil;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - keyboard show and hiden
-(void) keyboardWasShown:(NSNotification *) aNotification
{
    NSString *infoName = [aNotification name];
    if ([infoName isEqualToString:UIKeyboardDidShowNotification]) {
        NSDictionary *info = [aNotification userInfo];
        NSLog(@"%@", info);
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyBoardRect = [value CGRectValue];
        if (self.iFirstResponder != nil) {
            CGRect textFieldRectInView = [self.iScrollView convertRect:self.iFirstResponder.frame toView:self.view];
            CGRect textFieldRectInWindow = [self.view convertRect:textFieldRectInView toView:self.view.window];
            bool bIntersect = CGRectIntersectsRect(keyBoardRect, textFieldRectInWindow);
            if (bIntersect) {
                self.iMoveHeight = textFieldRectInWindow.origin.y + textFieldRectInWindow.size.height - keyBoardRect.origin.y;
                NSLog(@"%f",self.iMoveHeight);
                [UIView animateWithDuration:0.3f animations:^{
                    self.iScrollView.contentOffset = CGPointMake(self.iScrollView.contentOffset.x, self.iScrollView.contentOffset.y + self.iMoveHeight);
                }];
            }
        }
        
        if (self.iFirstResponder
            && self.iFirstResponder.tag == 1550
            && INTERFACE_IS_PHONE) {
            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
            doneButton.frame = CGRectMake(0, 163, 106, 53);
            doneButton.adjustsImageWhenHighlighted = NO;
            [doneButton setTitle:@"关闭"  forState:UIControlStateNormal];
            [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
            
            // locate keyboard view
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            UIView* keyboard;
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard view found; add the custom button to it
                if(([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES) ||(([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)))
                    [keyboard addSubview:doneButton];
            }
        }
    }
}

- (void)doneButton:(id)sender
{
    if (self.iFirstResponder
        && self.iFirstResponder.tag == 1550)
    {
        [self.iFirstResponder resignFirstResponder];
        self.iFirstResponder = nil;
    }
    
}

-(void)keyboardWasHidden:(NSNotification *) notif
{
    NSString *name = [notif name];
    if ([name isEqualToString:UIKeyboardDidHideNotification]) {
        NSLog(@"%f", self.iMoveHeight);
        if (self.iMoveHeight > 0.0f) {
            [UIView animateWithDuration:0.3f animations:^{
                self.iScrollView.contentOffset = CGPointMake(self.iScrollView.contentOffset.x, self.iScrollView.contentOffset.y - self.iMoveHeight);
            }completion:^(BOOL finished) {
                self.iMoveHeight = 0.0f;
                self.iFirstResponder = nil;
            }];
        }
    }
}
 */

@end
