//
//  WCEvaluatePersonViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/28/13.
//
//

#import "WCEvaluatePersonViewController.h"
#import "WSDictBean.h"
#import "WSAppData.h"
#import "WSBaseDictsDBService.h"

#define kPfizerBrandTrend @"brandTrend"
#define kPfizerspeechLevel @"speechLevel"

@interface WCEvaluatePersonViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *iTableView;
@property (nonatomic, strong)NSMutableArray *iResultArray;
@property (nonatomic, strong)NSMutableArray *iDataSourceArray;
@property (nonatomic, weak)WSDictBean *iSelectedBean;
@property (nonatomic, weak)WSDictBean *iFirstSectionBean;
@property (nonatomic, weak)WSDictBean *iSecondSectionBean;
@property (nonatomic, strong)NSMutableDictionary *iResultDictroy;
@property (nonatomic, strong)NSString *iPersonId;

@end

@implementation WCEvaluatePersonViewController
@synthesize iTableView = _iTableView;
@synthesize iResultArray = _iResultArray;
@synthesize iDataSourceArray = _iDataSourceArray;
@synthesize iSelectedBean = _iSelectedBean;
@synthesize iFirstSectionBean = _iFirstSectionBean;
@synthesize iSecondSectionBean = _iSecondSectionBean;
@synthesize iResultDictroy = _iResultDictroy;
@synthesize iPersonId = _iPersonId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithPersonId:(NSString *)aPersonId withResultDictory:(NSMutableDictionary *)aResultDictory
{
    self = [super init];
    if (self) {
        _iPersonId = aPersonId;
        _iResultDictroy = aResultDictory;
    }
    return self;
}

//- (id)initWithPersonId:(int)aPersonId andResultArray:(NSMutableArray *)aResultArray
//{
//    self = [super init];
//    if (self) {
//        _iResultArray = [aResultArray retain];
//    }
//    return self;
//}


- (NSMutableArray *)iDataSourceArray
{
    if (_iDataSourceArray == nil) {
        _iDataSourceArray = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _iDataSourceArray;
}

- (void)loadView
{
    [super loadView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    tv.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
    NSArray *brandTrendArray = [service queryDictsForAcvtGridWithFilter:kPfizerBrandTrend];
    [self.iDataSourceArray addObject:brandTrendArray];
    [self initDicBeanWith:brandTrendArray andFilter:@"brandTrendId"];
    
    NSArray *speechLevelArray = [service queryDictsForAcvtGridWithFilter:kPfizerspeechLevel];
    [self.iDataSourceArray addObject:speechLevelArray];
    [self initDicBeanWith:speechLevelArray andFilter:@"speechLevelId"];
}

- (void)initDicBeanWith:(NSArray *)aArray andFilter:(NSString *)aFilter
{
    NSDictionary *dicValues = [self.iResultDictroy objectForKey:self.iPersonId];
    if (dicValues != nil) {
        NSString *dicId = [dicValues objectForKey:aFilter];
        if (dicId != nil && ![dicId isEqualToString:@""]) {
            for (WSDictBean *bean in aArray) {
                if ([bean.Id isEqualToString:dicId]) {
                    if ([aFilter isEqualToString:@"brandTrendId"]) {
                        self.iFirstSectionBean = bean;
                    }else if ([aFilter isEqualToString:@"speechLevelId"]){
                        self.iSecondSectionBean = bean;
                    }
                }
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.iSelectedBean = nil;
}


#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.iDataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString *title = (section == 0) ? @"品牌倾向性" : @"演讲水平";
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.iDataSourceArray obj
    NSArray *rows = [self.iDataSourceArray objectAtIndex:section];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *brandAndSpeech = @"BrandAndSpeech";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:brandAndSpeech];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:brandAndSpeech];
    }
    
    // add text
    NSArray *array = [self.iDataSourceArray objectAtIndex:indexPath.section];
    WSDictBean *bean = [array objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = bean.name;
        
    if (indexPath.section == 0) {
        cell.accessoryType = (self.iFirstSectionBean != nil && self.iFirstSectionBean == bean) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = (self.iSecondSectionBean != nil && self.iSecondSectionBean == bean) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = [self.iDataSourceArray objectAtIndex:indexPath.section];
    WSDictBean *bean = [array objectAtIndex:indexPath.row];
    if (bean != self.iFirstSectionBean && bean != self.iSecondSectionBean) {
        NSMutableDictionary *dic = [self.iResultDictroy objectForKey:self.iPersonId];
        if (indexPath.section == 0) {
            self.iFirstSectionBean = bean;
            [dic setObject:self.iFirstSectionBean.Id forKey:@"brandTrendId"];
        }else{
            self.iSecondSectionBean = bean;
            [dic setObject:self.iSecondSectionBean.Id forKey:@"speechLevelId"];
        }
        [tableView reloadData];
    }
}

@end
