//
//  InfoPerformanceViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSInfoPerformanceViewController.h"
//#import "ConfigFileController.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSFuncsBean_Param.h"


#define k_col1TitleWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 170 : 370)
#define k_LabelWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 100 : 370)
#define k_resultWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 140 : 370)

@interface WSInfoPerformanceViewController()

@property(nonatomic, strong)UIAlertView *alert;
@property(nonatomic, strong)UIView *iTitleView;
@property(nonatomic, strong)UIView *iContentView;
@property(nonatomic, assign)CGFloat originY;

@end
        

@implementation WSInfoPerformanceViewController

@synthesize ownParentViewController;
@synthesize currentFuncs = _currentFuncs;
@synthesize filtedData = _filtedData;
@synthesize alert = _alert;
@synthesize titles = _titles;
@synthesize myTabView = _myTabView;
@synthesize iTitleView = _iTitleView;
@synthesize iContentView = _iContentView;

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        _titles = [[NSMutableArray alloc]init];
        [_titles addObjectsFromArray:funcs.paramArray];
        return self;
        
    }
    return nil;
}

#pragma mark - View lifecycle

-(void)loadView
{
    
    [super loadView];
    
    [self addOptView];
    
    self.originY = self.y_point;
    
    // Set column title
    [self setColumnsDatasOfTitles];
    
    // Set column content
    NSString *ds = (self.currentFuncs.ds != nil && [self.currentFuncs.ds length] > 0) ? self.currentFuncs.ds : @"";
    NSString *filter = (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0) ? self.currentFuncs.filter : @"";
    WSEmpinforefreshBeanArray *emprefreshBeans = [WSAppData getObjectbyKey:ds];
    _filtedData = [emprefreshBeans getEmpinforefreshsWithFilter:filter];
    [self setColumnsDatasOfContent];
    
    
    NSString *updateString = NSLocalizedString(@"refresh", nil);
    UIBarButtonItem *updateItem = [[UIBarButtonItem alloc]
                                   initWithTitle:updateString
                                   style: UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(updateData)];
    
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = updateItem;
    }else if (self.m_ParentViewController) {
        self.m_ParentViewController.navigationItem.rightBarButtonItem = updateItem;
    }else {
        self.navigationItem.rightBarButtonItem = updateItem;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

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


-(void)setColumnsDatasOfTitles
{
    _iTitleView = [[UIView alloc] initWithFrame:CGRectZero];
    
    CGFloat x = 10.0f;
    int i = 0;
    for (WSFuncsBean_Param *param in self.titles) {
       UILabel *colTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, k_col1TitleWidth, 30)];
        if (i == 1) {
            colTitle.frame = CGRectMake(x, 0, k_resultWidth, 30);
            x+= k_resultWidth ;
        }
        else {
            x+= k_col1TitleWidth ;
        }
        colTitle.backgroundColor = [UIColor clearColor];
        colTitle.text = param.name;
        colTitle.textAlignment = NSTextAlignmentCenter;
//        colTitle.layer.borderWidth = 1.0f;
        [_iTitleView addSubview:colTitle];
        //x += k_col1TitleWidth;
        i++ ;
    }
    
    _iTitleView.frame = CGRectMake(0, self.y_point, x, 30);
    [self.contentScrollView addSubview:_iTitleView];
    
    self.y_point += 30;
    
    if (x > self.contentScrollView.frame.size.width ) {
        
        self.contentScrollView.contentSize = CGSizeMake(x, self.contentScrollView.frame.size.height);
    }
}

- (void)setColumnsDatasOfContent
{
    _iContentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    float y = 0;
    for (WSEmpinforefreshBean *infobean in _filtedData) {
        float x = 10.0f;
        int i = 0;
        for (WSFuncsBean_Param *param in self.titles){
            NSString *col = param.col;
            NSString *colval = nil;
            id obj = [infobean.iEmpinfo objectForKey:col];
            if (obj != nil && [obj isKindOfClass:[NSNumber class]]) {
                NSNumber *number = (NSNumber *)obj;
                colval = [number stringValue];
            }else if (obj != nil && [obj isKindOfClass:[NSString class]]){
                colval = (NSString *)obj;
            }else{
                colval = @"";
            }
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, k_col1TitleWidth, 30)];
            if (i == 1) {
                contentLabel.frame = CGRectMake(x, y, k_resultWidth, 30);
                x+= k_resultWidth ;
            }
            else {
                x+= k_col1TitleWidth ;
            }
           
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.text = colval;
            contentLabel.textAlignment = NSTextAlignmentCenter;
//            contentLabel.layer.borderWidth = 1.0f;
            [_iContentView addSubview:contentLabel];
            i++;
            
        }
        
        y += 30;
    }
    
    CGFloat contentViewY = self.iTitleView.frame.origin.y + self.iTitleView.frame.size.height;
    _iContentView.frame = CGRectMake(0, contentViewY, self.iTitleView.frame.size.width, y);
    
    self.y_point += y;
    
    if (self.y_point > self.contentScrollView.size.height) {
        self.contentScrollView.contentSize = CGSizeMake(self.iTitleView.frame.size.width, self.y_point);
    }
    [self.contentScrollView addSubview:_iContentView];
}


- (void)updateData
{
    NSString *UploadingString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:UploadingString tips:nil tapTarget:self action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFinished:) name:@"empinforefresh" object:nil];
    [[WSRequestHelper shareInstance] performanceInfoRefreshWithNotifyName:@"empinforefresh"];
}

- (void)refreshFinished:(id)sender
{
    NSString *info = [[sender userInfo] objectForKey:@"datas"];
    
    NSDictionary *senderDic = [info objectFromJSONString];
    
    NSString *ds = (self.currentFuncs.ds != nil && [self.currentFuncs.ds length] > 0) ? self.currentFuncs.ds : @"";
    NSString *filter = (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0) ? self.currentFuncs.filter : @"";
    
    WSEmpinforefreshBeanArray *empArr = [[WSEmpinforefreshBeanArray alloc] initWithObject:senderDic];
    [WSAppData putObject:empArr forKey:ds];
    WSEmpinforefreshBeanArray *emprefreshBeans=[WSAppData getObjectbyKey:ds];
    self.filtedData = [emprefreshBeans getEmpinforefreshsWithFilter:filter];
    
    [self.iTitleView removeFromSuperview];
    [self.iContentView removeFromSuperview];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    
    self.y_point = self.originY;
    
    [self setColumnsDatasOfTitles];
    [self setColumnsDatasOfContent];
    
//    [self.myTabView reloadData];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
