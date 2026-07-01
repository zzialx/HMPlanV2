//
//  ManagV_LISTViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSManagV_LISTViewController.h"
#import "WSVisitStoreActionTable.h"
#import "WSAcvtViewController.h"
#import "WSAcvtListViewController.h"
#import "WSCustomerQueryViewController.h"
#import "HYPageView.h"
#import "WSEnvrionment.h"
#import "WSVisitStoreStatusTable.h"
#import "WSSpecialAcvtViewController.h"

@interface WSManagV_LISTViewController ()<HYPageViewDelegate> {}

@property (nonatomic, strong) HYPageView *pageView;

@property (nonatomic,strong) UISegmentedControl *segmentedcontrol;

@property (nonatomic, strong) NSArray *pageViewSubViewControllersArray;

@property (nonatomic , strong) NSMutableArray * pageViewControllerCacheArray;


@end

@implementation WSManagV_LISTViewController
@synthesize MyTableView,dataArray,currentSubBean;
@synthesize segementSelectIndex = _segementSelectIndex;
@synthesize mainView = _mainView;
@synthesize selectViewController = _selectViewController;
 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

 

-(id)initWithSubBeans:(WSSubempstoreBean*)subBeans Funcs:(WSFuncsBean*)funcs
{
    
    if (subBeans==nil) {
        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        self.currentSubBean=subBeans;
        self.title=funcs.name;
        self.currentFuncs = funcs;
    }        
    return self;
}

-(NSMutableArray *)pageViewControllerCacheArray{
    if (!_pageViewControllerCacheArray) {
        _pageViewControllerCacheArray = [[NSMutableArray alloc]init];
    }
    return _pageViewControllerCacheArray;
}
 
-(void)loadView{
    [super loadView];
    [self addSelfMainView];
//    [self addFuncsSegmentView];
//    [self refreshSegementControllerTitle];
    
    
    NSArray *titleArray = [self getRefreshedTitleArray];
    
    if (titleArray.count == 1) {
        [self valueChange:nil];
    }else {
        _pageViewSubViewControllersArray = [NSArray arrayWithArray:[self getAllFuncsViewControllers]];
        [self addFuncsSegmentPageViewWithTitleArray:titleArray andViewControllersArray:_pageViewSubViewControllersArray];
    }
    
    
}

- (void)addFuncsSegmentPageViewWithTitleArray:(NSArray *)titleArray andViewControllersArray:(NSArray *)vcArray
{
    
    _pageView = [[HYPageView alloc] initWithFrame:self.mainView.bounds withTitles:titleArray withViewControllers:vcArray withParameters:nil];
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pageView.pageDelegate = self;
    
    _pageView.selectedColor = MAIN_TINT_COLOT;
    _pageView.unselectedColor = [UIColor blackColor];
    
    [self.mainView addSubview:_pageView];
}

- (NSArray *)getAllFuncsViewControllers
{
    
    NSMutableArray *vcMArray = [[NSMutableArray alloc] init];
    
    for (WSFuncsBean* fb in self.currentFuncs.funcsArray) {

        UIViewController *currentVC = [self getFuncViewControllerWithFunsBean:fb andIsAddToMainView:NO];
        
        // 如果是关于里面加的funcs，不在外层添加VC
        if ([fb.filter isEqualToString:@"tradocument"] || [fb.fv isEqualToString:@"FV_ROLE_SWITCH"] ) {
            
        }else
        {
            ((WCBaseViewController *)currentVC).isPageSegmentView = YES; //MN-1327 2018-03-19
            [vcMArray addObject:currentVC];
        }

        
    }
    
    return [NSArray arrayWithArray:vcMArray];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.MyTableView reloadData];
}

  
#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
       return [self.currentFuncs.funcsArray count];
   
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    WSFuncsBean *subFuncs=[self.currentFuncs.funcsArray objectAtIndex:indexPath.row];
    cell.textLabel.text=subFuncs.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_Font];
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentSubBean.Id ? self.currentSubBean.Id : self.currentSubBean.orgId;
    action.func_code = subFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [self getEmpId];
    action.is_required = subFuncs.required;
    action.title = subFuncs.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
    
    if ([status isEqualToString:ActionDone]) {
        cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
    } else if ([status isEqualToString:ActionWorking]) {
        cell.imageView.image = [UIImage imageNamed:@"visit_doing.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"visit_not_start.png"];
    }
    cell.imageView.frame = CGRectMake(0, 0, 24, 24);
       
    return cell;
    
}

//选中Cell响应事件

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
     
    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:indexPath.row];
    UIViewController *vc = nil;
    
    if ([fb.fv isEqualToString:@"TAB_V2001"])
    {
        vc = [[WSTodayVisitViewController alloc] initWithFuncs:fb Stores:self.currentSubBean.InArray];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([fb.fv isEqualToString:@"TAB_V13001"])
    {
        vc = [[WSManagV_OutPlanViewController alloc]initWithSubBeans:self.currentSubBean Funcs:fb];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if ([fb.fv isEqualToString:@"TAB_V21003"])
    {
        vc = [[WSSkillsAssessmentViewController alloc]initWithFuncs:fb];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([fb.fv isEqualToString:@"TAB_V8001"])
    {

        vc=[[WSAcvtListViewController alloc] initWithFuncs:fb];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentSubBean.Id ? self.currentSubBean.Id : self.currentSubBean.orgId;
    action.func_code = fb.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [self getEmpId];
    action.title = fb.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    vc.currentVisitAction = action;
         
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0f)];
    return headView;
}

#pragma mark UISegement Methods

- (void) addSelfMainView
{
    UIView* view = [[UIView alloc]initWithFrame:CGRectZero];
    self.mainView = view;
    
//    NSInteger l_funcsCount = [self.currentFuncs.funcsArray count];
//    if(l_funcsCount < 2)
//    {
//    if (INTERFACE_IS_PAD) {
        self.mainView.frame = self.view.bounds;
//    }else
//        self.mainView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    }else{
//        
//        self.mainView.frame = CGRectMake(0, kSegmentedControlTopGap + kSegmentedControlHeight + kSegmentedControlBottomGap, self.view.bounds.size.width, self.view.bounds.size.height - (kSegmentedControlTopGap + kSegmentedControlHeight + kSegmentedControlBottomGap));
//    }
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.mainView];
}

/*
- (void) addFuncsSegmentView
{
    NSInteger l_funcsCount = [self.currentFuncs.funcsArray count];
    if(l_funcsCount == 0)
        return;
    if(l_funcsCount < 2)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:0];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            return;
        }
        [self valueChange:nil];
        return;
    }
    
    NSMutableArray* segmentTitlesArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < l_funcsCount;i++)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            continue;
        }
        [segmentTitlesArray addObject:subfuncs.name];
    }
    
    self.segmentedcontrol = [[UISegmentedControl alloc] initWithItems:segmentTitlesArray];
    CGFloat width = INTERFACE_IS_PHONE ? self.view.bounds.size.height : (l_funcsCount * 150);
    if (width > self.view.bounds.size.width) {
        width = self.view.bounds.size.width;
    }
    self.segmentedcontrol.frame = CGRectMake((self.view.bounds.size.width - width)/2, kSegmentedControlTopGap, width, kSegmentedControlHeight);
    [self.segmentedcontrol addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    if (INTERFACE_IS_PAD) {        
        UIColor* selectedColor= MAIN_TINT_COLOT;
        if (!selectedColor) {
            selectedColor = [UIColor colorWithRed:0.0 green:147.0/255.0 blue:208.0/255.0 alpha:1.0];
        }
        
        self.segmentedcontrol.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.segmentedcontrol.layer.cornerRadius = kSegmentedControlHeight / 2.0f;
        self.segmentedcontrol.clipsToBounds = YES;
        self.segmentedcontrol.layer.borderWidth = 1.0;
        self.segmentedcontrol.layer.borderColor = [selectedColor CGColor];
        
    }
    
    [self.view addSubview:self.segmentedcontrol];
    
    int normalSelect = [self initializationSelectSegment];
    normalSelect = MAX(0, normalSelect);
    [self.segmentedcontrol setSelectedSegmentIndex:normalSelect];
    
    [self valueChange: [NSNumber numberWithInteger: normalSelect]];
}
*/

- (void)currentPageChangedFromOldIndex:(NSInteger)oldIndex toNewIndex:(NSInteger)newIndex
{
    NSLog(@"currentPageChangedFromOldIndex = %ld toNewIndex = %ld", (long)oldIndex, (long)newIndex);
//    UIViewController *newVC = [_pageViewSubViewControllersArray objectAtIndex:newIndex];
 
    // isAppearing
    // true if the child view controller's view is about to be added to the view hierarchy, false if it is being removed.
    // viewWillAppear调⽤用设置为YES，viewWillDisappear调⽤用设置为NO
    
    // 如果newVC 没有点击过，不需要手动掉  delayAppearDidMethodWithOldViewController
//    NSString * newVcClassName = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([newVC class]),(long)newIndex];
//    BOOL isFirstLoadNewVC = ![self.pageViewControllerCacheArray containsObject:newVcClassName];
//    if (isFirstLoadNewVC) {
//        [self.pageViewControllerCacheArray addObject:newVcClassName];
//    }
//    if ((oldIndex == newIndex && [self.pageView isFirstLoad] == NO) || (isFirstLoadNewVC  && oldIndex != newIndex)) {
//
//    }
//    else
//    {
//        //2017-11-03-MSTD-6773
//        if(oldIndex == 0 && oldIndex == newIndex && [self.pageView isFirstLoad])
//            return;
//
//        [oldVC beginAppearanceTransition:NO animated:YES];
//        [self performSelector:@selector(delayAppearDidMethodWithOldViewController:) withObject:@[oldVC,newVC] afterDelay:0.01];
//    }
    
}

- (void)delayAppearDidMethodWithOldViewController:(NSArray *)vcsArray
{
    [[vcsArray firstObject] endAppearanceTransition];
    [self delayRunMethodWithNewViewController:[vcsArray lastObject]];
}

- (void)delayRunMethodWithNewViewController:(UIViewController *)newVC
{
    [newVC beginAppearanceTransition:YES animated:YES];
    [self performSelector:@selector(delayAppearDidMethodWithNewViewController:) withObject:newVC afterDelay:0.01];
}

- (void)delayAppearDidMethodWithNewViewController:(UIViewController *)newVC
{
    [newVC endAppearanceTransition];
}

-(void)valueChange:(id)sender
{
    
    for(UIView* view in [self.mainView subviews])
    {
        [view removeFromSuperview];
    }
    
    if((self.selectViewController!= nil) && (sender))
    {
        [self.selectViewController.view removeFromSuperview];
        [self.selectViewController removeFromParentViewController];
        self.selectViewController = nil;
    }
    NSInteger seleted = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *sc = (UISegmentedControl *)sender;
        seleted = sc.selectedSegmentIndex;
    }else if ([sender isKindOfClass:[NSNumber class]]) {
        seleted = [sender intValue];
    }
    
    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:seleted];
    
    [self getFuncViewControllerWithFunsBean:fb andIsAddToMainView:YES];
}

- (UIViewController *)getFuncViewControllerWithFunsBean:(WSFuncsBean *)fb andIsAddToMainView:(BOOL)isAdd
{
    UIViewController *currentVC = nil;
    if ([fb.fv isEqualToString:@"TAB_V2001"])
    {
        WSTodayVisitViewController *inPlanVC = nil;
        if (self.currentSubBean) {
            inPlanVC = [[WSTodayVisitViewController alloc] initWithFuncs:fb SubempStoreBean:self.currentSubBean];
            inPlanVC.delegate = self;
        }
        else{
            inPlanVC =[[WSTodayVisitViewController alloc]initWithFuncs:fb];
        }
        inPlanVC.ownParentViewController = self;
        currentVC = inPlanVC;
    }
    else if ([fb.fv isEqualToString:@"TAB_V2002"]){
        
        WSAllStoresViewController *allStoresVC = nil;
        if (self.currentSubBean) {
            allStoresVC =[[WSAllStoresViewController alloc]initWithFuncs:fb subempStore:self.currentSubBean];
            allStoresVC.delegate = self;
        }
        else{
            allStoresVC = [[WSAllStoresViewController alloc]initWithFuncs:fb];
        }
        currentVC = allStoresVC;
        allStoresVC.ownParentViewController = self;
        
    }
    else if ([fb.fv isEqualToString:@"TAB_V13001"])
    {
        WSManagV_OutPlanViewController *outPlanVC = [[WSManagV_OutPlanViewController alloc]initWithSubBeans:self.currentSubBean Funcs:fb];
        outPlanVC.ownParentViewController =self;
        currentVC= outPlanVC;
        outPlanVC.delegate = self;
        
    }
    else if ([fb.fv isEqualToString:@"TAB_V21002"] || [fb.fv isEqualToString:@"TAB_V11001"]){
        
        WSCustomerQueryViewController *customerQueryViewVC = nil;
        if (self.currentSubBean) {
            customerQueryViewVC =[[WSCustomerQueryViewController alloc]initWithFuncs:fb subempStore:self.currentSubBean];
            customerQueryViewVC.delegate = self;
        }
        else{
            customerQueryViewVC = [[WSCustomerQueryViewController alloc]initWithFuncs:fb];
        }
        currentVC = customerQueryViewVC;
        
    }
    
    else if ([fb.fv isEqualToString:@"TAB_V21003"])
    {
        WSSkillsAssessmentViewController *skillAVC = nil;
        if (self.currentSubBean) {
            skillAVC = [[WSSkillsAssessmentViewController alloc]initWithFuncs:fb subEmpStore:self.currentSubBean];
        } else {
            skillAVC = [[WSSkillsAssessmentViewController alloc] initWithFuncs:fb];
        }
        skillAVC.m_ParentViewController = self;
        currentVC = skillAVC;
    }
    else if ([fb.fv isEqualToString:@"TAB_V8001"] && ![fb.isAcvtList isEqualToString:@"1"])
    {
        WSAcvtListViewController *acvtListVC = [[WSAcvtListViewController alloc] initWithFuncs:fb];
        currentVC = acvtListVC;
    }
    else {
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        
        if([self.currentSubBean.outPlanStoreArray count] > 0){
            currentVC = [[NSClassFromString(className) alloc] initWithFuncs:fb Stores:self.currentSubBean.outPlanStoreArray];
        }else if ([NSClassFromString(className) instancesRespondToSelector:@selector(initWithFuncs:subEmpStore:)]) {
                currentVC =[[NSClassFromString(className) alloc] initWithFuncs:fb subEmpStore:self.currentSubBean];
        }else if ([NSClassFromString(className) instancesRespondToSelector:@selector(initWithFuncs:subempStore:)]){
                currentVC =[[NSClassFromString(className) alloc] initWithFuncs:fb subempStore:self.currentSubBean];
        }else{
                currentVC = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        }
        //      MMSH-4244 董宏 没有业代id
    }
    
    if(currentVC != nil)
    {
        if ([currentVC isKindOfClass:[SuperWorkSpaceViewController class]]) {
            ((SuperWorkSpaceViewController *)currentVC).ownParentViewController = self;
             ((SuperWorkSpaceViewController *)currentVC).subempStore = self.currentSubBean;
           //SaaS蒙牛智网行动-经销商运营系统MN-3360 ios-主管角色照片墙点击照片，没有分享照片按钮
        } else if ([currentVC isKindOfClass:[BaseViewController class]]) {
             ((BaseViewController *)currentVC).ownParentViewController = self;
         }

        
        LogInfo(@"Going to class show:%@", currentVC);
        currentVC.view.frame = self.mainView.bounds;
        currentVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (isAdd) {
            [self addChildViewController:currentVC];
            [self.mainView addSubview:currentVC.view];
            self.selectViewController = currentVC;
            return nil;
        }

    }
    
    return currentVC;
}

/*
// 在不点击segementController的item情况下可显示其对应模块的门店数据
- (void)refreshSegementControllerTitle
{
    NSInteger funcsCount = [self.currentFuncs.funcsArray count];
    if(funcsCount == 0) {
        return;
    }
    for(int i = 0 ; i < funcsCount;i++)
    {
        
        WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:i];
        NSString *title = nil;
        if ([fb.fv isEqualToString:@"TAB_V2001"])
        {
            WSTodayVisitViewController *todayVisitVC = nil;
            if (self.currentSubBean) {
                todayVisitVC = [[WSTodayVisitViewController alloc] initWithFuncs:fb SubempStoreBean:self.currentSubBean];
                
                [todayVisitVC addSubEmpInplanStoresFromDb];
                title = [NSString stringWithFormat:@"%@(0/%lu)",fb.name,(unsigned long)[todayVisitVC.storeArray count]] ;
            }
            
            
        } else if ([fb.fv isEqualToString:@"TAB_V2002"]){
            
            WSAllStoresViewController *allStoresVC = nil;
            if (self.currentSubBean) {
                allStoresVC =[[WSAllStoresViewController alloc]initWithFuncs:fb subempStore:self.currentSubBean];
                allStoresVC.delegate = self;
                allStoresVC.ownParentViewController = self;
                WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
                
                NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                if ([self.currentSubBean.Id length] > 0) {
                    empId = self.currentSubBean.Id;
                }
                NSInteger allStoreCount = [baseStoreDBService queryAllStoresCountWithFuncBean:fb empId:empId];
                
                title  = [NSString stringWithFormat:@"%@(%lu)",fb.name,(unsigned long)allStoreCount];
            }
            allStoresVC.ownParentViewController = nil;
            allStoresVC = nil;
 
           
        }
        if ([title length] > 0) {
             [self.segmentedcontrol setTitle:title forSegmentAtIndex:i];
        }
       

    }
    
}
*/

- (NSString *)getEmpId {
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.currentSubBean.Id;
    NSString *empId = subEmpId ? : currenteEmpId;
    return empId;
}

- (NSArray *)getRefreshedTitleArray
{
    WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
    NSInteger funcsCount = [self.currentFuncs.funcsArray count];
    if(funcsCount == 0) {
        return nil;
    }
    
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:funcsCount];
    NSString *empId = [self getEmpId];
    for(int i = 0 ; i < funcsCount;i++)
    {
        WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:i];
        
        // 如果是关于里面加的funcs，不在外层添加VC
        if ([fb.filter isEqualToString:@"tradocument"] || [fb.fv isEqualToString:@"FV_ROLE_SWITCH"] || [fb.display isEqualToString:@"0"]) {
            continue;
        }
        
        NSString *title = fb.name;
        if ([fb.fv isEqualToString:@"TAB_V2001"]) {
            if ([WSEnvrionment getStoreDataFromDb]) {
                NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                
                WSVisitStoreStatusTable *visitTable = [[WSVisitStoreStatusTable alloc] init];
                NSInteger visitedCount = [visitTable queryInPlanStoresVisitedCountWithFuncBean:fb empId:empId biz_date:bizDate];
                NSInteger planStoreCount = [baseStoreDBService queryInPlanStoresCountWithFuncBean:fb empId:empId biz_date:bizDate];
                title = [NSString stringWithFormat:@"%@(%ld/%ld)",fb.name, (long)visitedCount, (long)planStoreCount] ;
            }
        }else if ([fb.fv isEqualToString:@"TAB_V2002"]) {
            
            if ([WSEnvrionment getStoreDataFromDb]) {

                NSInteger allStoreCount = [baseStoreDBService queryAllStoresCountWithFuncBean:fb empId:empId];
                title = [NSString stringWithFormat:@"%@(%ld)",fb.name,(long)allStoreCount] ;
            }
        }
        
        [titleArray addObject:title];
    }
    
    return titleArray;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - SuperWorkSpaceViewControllerDelegate

- (void)superWorkSpaceVC:(SuperWorkSpaceViewController *)controller refreshControllerTitle:(NSString *)title
{
    if ([title length] > 0) {
        if (_pageViewSubViewControllersArray && _pageViewSubViewControllersArray.count > 0) {
            NSInteger index = [_pageViewSubViewControllersArray indexOfObject:controller];
            [_pageView refreshTitle:title atPageIndex:index];
        }
        
        //        [self.segmentedcontrol setTitle:title forSegmentAtIndex:self.segmentedcontrol.selectedSegmentIndex];

    }
    
}

@end
