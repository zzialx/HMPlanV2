//
//  WSNewMsgViewController.m
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSNewMsgViewController.h"
#import "WSAppData.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "WSFuncsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSRequestHelper.h"
#import "WSMsgContentViewController.h"
#import "WSNavigationBar.h"

#import "HMSegmentedControl.h"
#import "WSNewSubMsgsViewController.h"
#import "WSNewAllSubMsgsViewController.h"

#define UPDATA_MSG @"updataMassage"

static const float TAB_BAR_HEIGHT = 56.0f;

@interface WSNewMsgViewController ()
{
    
    UIView *contentContainerView;
    CGFloat yPonit;
}
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) WSFuncsBean *subFuncBean;
@end

@implementation WSNewMsgViewController
@synthesize dataArray = _dataArray;
@synthesize funcsBean = _funcsBean;
@synthesize subFuncBean = _subFuncBean;


#pragma mark -private mathod

-(void)updateMsgInfo
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([self.dataArray count] > 0) {
        [user removeObjectForKey:kWSMessageDomainName];
        NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] initWithCapacity:16];
        if (bizDate) {
            [dicInfo setObject:bizDate forKey:kWSMessageBizDate];
        }
        
        if (dicInfo) {
            [user setObject:dicInfo forKey:kWSMessageDomainName];
        }
        
        [user synchronize];
    }
    for(WSMsgsBean* aMsg in self.dataArray)
    {
        for (WSMsgsBean_msg *msg in aMsg.msg) {
            if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
                NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:key];
                if (dicInfo) {
                    [user setObject:dicInfo forKey:kWSMessageDomainName];
                }
                
                [user synchronize];
            }
        }
    }
}

-(int)getHasReadCountByMsg:(WSMsgsBean*)aMsg
{
    int i = 0;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    for (WSMsgsBean_msg *msg in aMsg.msg) {
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        id obj = [dic objectForKey:key];
        if (obj != nil) {
            i++;
        }
    }
    return i;
}


-(void)setAccessFlag:(UITableViewCell*)cell Msg:(WSMsgsBean*)aMsg
{
    //如果阅读完所有的消息，就不画point.png
    NSInteger hasReadCount= [self getHasReadCountByMsg:aMsg];
    NSInteger totallCount = [aMsg.msg count];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld/%ld)",aMsg.name, (long)hasReadCount, (long)totallCount];
}

-(void)uploadFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATA_MSG object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        //        [self updateMsgInfo];
        NSDictionary *uploadState = [info objectFromJSONString];
        WSMsgBeanArray* msgArray = [[WSMsgBeanArray alloc] initWithObject:uploadState];
        [WSAppData putObject:msgArray forKey:MSGS];
        
        [self.dataArray removeAllObjects];
        WSMsgBeanArray* messageArray = [WSAppData getObjectbyKey:MSGS];
        
        NSArray *arrays = nil;
        if (self.funcsBean.filter != nil && [self.funcsBean.filter length] > 0) {
            arrays = [messageArray getMsgsBeansWithFilter:self.funcsBean.filter];
        }
        
        if (arrays == nil) {
            self.dataArray = [NSMutableArray arrayWithArray:messageArray.msgArray];
        }else{
            self.dataArray = [NSMutableArray arrayWithArray:arrays];
        }
        [self initinitHMSegmented];
        //        [self updateMsgInfo];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        //更新完成后对userdefault重新处理
    }
}
-(void)updataInfo
{
    
    if (self.view
        && !self.view.userInteractionEnabled) {
        return;
    }
    
    if (self.selectedViewController) {
        BOOL allowUpdateInfo = YES;
        if ([self.selectedViewController isKindOfClass:[WSNewSubMsgsViewController class]]) {
            WSNewSubMsgsViewController *viewContoller = (WSNewSubMsgsViewController *)self.selectedViewController;
            allowUpdateInfo = ![viewContoller isScrolling];
        }else if ([self.selectedViewController isKindOfClass:[WSNewAllSubMsgsViewController class]]){
            WSNewAllSubMsgsViewController *viewContoller = (WSNewAllSubMsgsViewController *)self.selectedViewController;
            allowUpdateInfo = ![viewContoller isScrolling];
        }
        
        if (!allowUpdateInfo) {
            return;
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:UPDATA_MSG
                                               object:nil];
    
  
    
    [[WSRequestHelper shareInstance] postRequestMSGWithType:nil];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];}

- (void)setCompanyInfo
{
    [self.dataArray removeAllObjects];
    WSMsgBeanArray* messageArray = [WSAppData getObjectbyKey:MSGS];
    NSArray *msgsArray = nil;
    if (self.funcsBean.filter != nil && [self.funcsBean.filter length] > 0) {
        msgsArray = [messageArray getMsgsBeansWithFilter:self.funcsBean.filter];
    }
    if (msgsArray != nil) {
        [self.dataArray addObjectsFromArray:msgsArray];
    }else{
        [self.dataArray addObjectsFromArray:messageArray.msgArray];
    }
    
    NSString *tmpString = NSLocalizedString(@"refresh",nil);
    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                               initWithTitle:tmpString
                               style: UIBarButtonItemStylePlain
                               target:self
                               action:@selector(updataInfo)];
    self.navigationItem.rightBarButtonItem = updata;
    
}

#pragma mark - system mathod

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.funcsBean = funcs;
        self.title = funcs.name;
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

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //数据
    NSMutableArray* array = [[NSMutableArray alloc]init];
    self.dataArray = array;
    
    [self setCompanyInfo];
    
}

-(void)initializationBackItemAction
{
    if (self.funcsBean && self.funcsBean.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.funcsBean.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:nil target:nil];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.navigationController.viewControllers.count>1) {
        [self initializationBackItemAction];
    }
    
    [self initContentContainerView];
    [self initinitHMSegmented];
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.segmentedControl = nil;
    self.dataArray = nil;
    self.funcsBean = nil;
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageCellButtonClickedNotification object:nil];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: SimpleTableIdentifier];
    }
    
    WSMsgsBean* message = [self.dataArray objectAtIndex:indexPath.row];
    //    cell.textLabel.text = message.name;
    [self setAccessFlag:cell Msg:message];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    //    MsgBeanArray* messageArray = [AppData getObjectbyKey:MSGS];
    //    MsgsBean* message = [messageArray.msgArray objectAtIndex:indexPath.row];
    WSMsgsBean* message = [self.dataArray objectAtIndex:indexPath.row];
    NSInteger subcount = [message.msg count];
    if(subcount == 0)
    {
        NSString *tmpString = NSLocalizedString(@"无消息",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    WSNewSubMsgsViewController *subMsgsVC = [[WSNewSubMsgsViewController alloc] initWithMsgsBean:message];
    subMsgsVC.title = message.name;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:subMsgsVC animated:YES];
}

#pragma mark - HMSegmentedControl

- (void)initinitHMSegmented
{
    [self.view setUserInteractionEnabled:NO];
    //工作信息页面
    NSMutableArray *titlesArray = [NSMutableArray arrayWithCapacity:[self.dataArray count]];
    for (WSMsgsBean* message in self.dataArray) {
        [titlesArray addObject:[NSString stringWithFormat:@"%@",message.name]];
    }
    /*'全部' add 索引为0*/
    [titlesArray insertObject:[NSString stringWithFormat:@"%@",NSLocalizedString(@"all", nil)] atIndex:0];
    
    [self initHMSegmentedWithTitles:titlesArray];
    if ([titlesArray count] > 0) {
        [self initControllers];
    }
    [self.view setUserInteractionEnabled:YES];
    
}
- (void) initHMSegmentedWithTitles:(NSArray *)titlesArray
{
    
    if (self.segmentedControl) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
    }
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:titlesArray];
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.frame = CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, TAB_BAR_HEIGHT);
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 4, 0, 4);
    self.segmentedControl.selectionIndicatorHeight = 4.0f;
    self.segmentedControl.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.segmentedControl.selectedTextColor = [UIColor colorWithHexString:@"#0093D4"];
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#0093D4"];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.bottomLine.backgroundColor = [UIColor colorWithHexString:@"#CFCFCF"];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];


}
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self setSelectedIndex:segmentedControl.selectedSegmentIndex animated:YES];
}

- (void) clickedIndex:(NSNotification *)notification
{
    if (notification
        && notification.object
        && [notification.object isKindOfClass:[NSNumber class]]) {
        NSNumber *index = notification.object;
        NSInteger indexInteger = [index integerValue];
        if (self.selectedIndex !=indexInteger) {
    
            [self.segmentedControl setSelectedSegmentIndex:[index integerValue] animated:YES];
            [self setSelectedIndex:[index integerValue] animated:YES];
        }else{
        
            //测试动画
            [self.segmentedControl  testAnimation];
        }
    }
}

#pragma mark - ContentContainerView

- (void) initControllers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageCellButtonClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clickedIndex:)
                                                 name:MessageCellButtonClickedNotification
                                               object:nil];
    
    NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:[self.dataArray count]];
    NSMutableArray * allSubMsgsArray = [NSMutableArray arrayWithCapacity:2];
    NSInteger i = 1;
    for (WSMsgsBean* message in self.dataArray) {
        
        for (WSMsgsBean_msg *object in message.msg) {
            object.categoryIndex = i;
            object.categoryTitle = message.name;
        }
        [allSubMsgsArray addObjectsFromArray:message.msg];
        WSNewSubMsgsViewController *subMsgsVC = [[WSNewSubMsgsViewController alloc] initWithMsgsBean:message];
        subMsgsVC.categoryTitle = message.name;
        [controllers addObject:subMsgsVC];
        i = i + 1;
    }
    WSNewAllSubMsgsViewController *allSubMsgsVC = [[WSNewAllSubMsgsViewController alloc] initWithArrayMsgsBean:allSubMsgsArray];
    [controllers insertObject:allSubMsgsVC atIndex:0];
    [self setViewControllers:controllers];
}

- (void)initContentContainerView
{
    CGRect rect = CGRectMake(0, TAB_BAR_HEIGHT , self.view.bounds.size.width, self.view.bounds.size.height - TAB_BAR_HEIGHT);
    contentContainerView = [[UIView alloc] initWithFrame:rect];
	contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentContainerView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:contentContainerView];
}

- (void)reloadController
{
    NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
	NSAssert([newViewControllers count] >= 2, @"NOHViewController requires at least two view controllers");
    
	UIViewController *oldSelectedViewController = self.selectedViewController;
    
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
    
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if (newIndex != NSNotFound)
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;
    
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
    
    if ([self isViewLoaded])
		[self reloadController];
}

- (UIViewController *)selectedViewController
{
	if (self.selectedIndex != NSNotFound)
		return [self.viewControllers objectAtIndex:self.selectedIndex];
	else
		return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController
{
	[self setSelectedViewController:newSelectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated;
{
	NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
	if (index != NSNotFound)
		[self setSelectedIndex:index animated:animated];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
	[self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated
{
	NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");
    
	if (![self isViewLoaded])
	{
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex)
	{
		UIViewController *fromViewController;
		UIViewController *toViewController;
        
		if (_selectedIndex != NSNotFound)
		{
            
			fromViewController = self.selectedViewController;
		}
        
		NSUInteger oldSelectedIndex = _selectedIndex;
		_selectedIndex = newSelectedIndex;
        
		if (_selectedIndex != NSNotFound)
		{
			toViewController = self.selectedViewController;
		}
        
		if (toViewController == nil)  // don't animate
		{
			[fromViewController.view removeFromSuperview];
		}
		else if (fromViewController == nil)  // don't animate
		{
			toViewController.view.frame = contentContainerView.bounds;
			[contentContainerView addSubview:toViewController.view];
            
		}
		else if (animated)
		{
			CGRect rect = contentContainerView.bounds;
			if (oldSelectedIndex < newSelectedIndex)
				rect.origin.x = rect.size.width;
			else
				rect.origin.x = -rect.size.width;
            
			toViewController.view.frame = rect;
            self.segmentedControl.userInteractionEnabled = NO;
            
			[self transitionFromViewController:fromViewController
                              toViewController:toViewController
                                      duration:0.3
                                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                                    animations:^
             {
                 CGRect rect = fromViewController.view.frame;
                 if (oldSelectedIndex < newSelectedIndex)
                     rect.origin.x = -rect.size.width;
                 else
                     rect.origin.x = rect.size.width;
                 
                 fromViewController.view.frame = rect;
                 toViewController.view.frame = contentContainerView.bounds;
             }
                                    completion:^(BOOL finished)
             {
                 self.segmentedControl.userInteractionEnabled = YES;
             }];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];
            
			toViewController.view.frame = contentContainerView.bounds;
			[contentContainerView addSubview:toViewController.view];
            
		}
	}
}
@end
