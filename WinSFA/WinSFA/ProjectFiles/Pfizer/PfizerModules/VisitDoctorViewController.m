//
//  VisitDoctorViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-15.
//
//

#import "VisitDoctorViewController.h"
#import "UIViewController+Additional.h"
#import "WSHosBean.h"
#import "BaseViewController.h"
//#import "PropertyManager.h"
#import "WSPlistHelper.h"
#import "WSAcvtViewController.h"
#import "WSVisitStoreActionTable.h"
#import "UIDevice+Addtional.h"

#import "WSSpecialAcvtViewController.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSVisitCollectionViewCell.h"
#import "WSBaseDictsDBService.h"

#define K_TABLE_CELL_HEIGHT 44

static NSString * const kVisitDoctorCellId = @"VisitDoctorCell";
static NSString * const kVisitDoctorHeaderCellId = @"VisitDoctorHeader";

@interface VisitDoctorViewController ()<UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *currentDataArray;
@property (nonatomic, strong) NSArray *showArray;
@property (nonatomic, strong) NSMutableArray *departmentIDArray;

@property (nonatomic, strong) WSFuncsBean *currentFunc;
@property (nonatomic, strong) UICollectionView *dataCollectionView;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, assign) int  colNumber;
@property (nonatomic, assign) BOOL isDoctor;
@property (nonatomic, assign) int maxRow;

@end

@implementation VisitDoctorViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs  {
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self) {
        self.currentFunc = funcs;
        _colNumber = [funcs.opt.listStyleShowColNum intValue];
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store {
    if(funcs == nil || store == nil)
        return nil;
    
    self = [super init];
    if(self) {
        self.currentFunc = funcs;
        self.currentStore = store;
        self.currentDataArray = store.hosArray;
        _colNumber = [funcs.opt.listStyleShowColNum intValue];
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store hosArray:(NSArray *)aHosArray {
    if(funcs == nil || store == nil)
        return nil;
    
    self = [super init];
    if(self) {
        self.currentFunc = funcs;
        self.currentStore = store;
        self.currentDataArray = aHosArray;
        self.isDoctor = YES;
        return self;
    }
    return nil;
}

- (void)loadView {
    [super loadView];
    
    _searchBar = [[WSSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44.0) isResetTextField:NO isResetBackgroundColor:YES];
    _searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    _searchBar.searchBar.delegate = self;
    _searchBar.backViewColor = [UIColor whiteColor];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_searchBar];
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width;
    layout.minimumInteritemSpacing = 0.1;
    layout.minimumLineSpacing = 0.1;
    if (_colNumber > 1 ) {
        width = (self.view.width - layout.minimumInteritemSpacing * (_colNumber + 1)) / _colNumber;
        layout.itemSize = CGSizeMake(width, K_TABLE_CELL_HEIGHT );
    } else {
        width = self.view.width;
        layout.itemSize = CGSizeMake(width, K_TABLE_CELL_HEIGHT);
    }
    CGRect frame = CGRectMake(0, 44, self.view.width,self.view.height - 44);

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerClass:[WSVisitCollectionViewCell class] forCellWithReuseIdentifier:kVisitDoctorCellId];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVisitDoctorHeaderCellId];
    collectionView.backgroundColor = [UIColor whiteColor];
    self.dataCollectionView = collectionView;
    [self.view addSubview:collectionView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*对于计划内的门店  其下科室医生从stores,dicts节点获取*/
    if (self.currentStore.plan  && [self.currentDataArray count] == 0 ) {
        self.currentDataArray = [self getHosWithStore:self.currentStore withFilter:NO];
    } else if ([self.currentDataArray count] == 0 ) {
        self.currentDataArray = [self getHosWithStore:self.currentStore withFilter:YES];
    }
    if (self.currentDataArray.count > 0) {
        WSHosBean * hos = [self.currentDataArray firstObject];
        self.title = hos.detail_info;
    }
    self.showArray = [NSArray arrayWithArray:self.currentDataArray];
    _maxRow = 1;
    if (_colNumber > 1) {
        float tempCol = _colNumber;
        _maxRow =  (int)roundf(self.showArray.count/tempCol);
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.dataCollectionView reloadData];
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.wsSplitController) {
        if ([self.wsSplitController.leftViewController isKindOfClass:[WCNavigationController class]])
        {
            WCNavigationController *nav = (WCNavigationController *)self.wsSplitController.leftViewController;
            if ([[nav.viewControllers firstObject] isKindOfClass:[WSWorkFlowViewController class]])
            {
                WSWorkFlowViewController *con = (WSWorkFlowViewController *)[nav.viewControllers firstObject];
                [con reloadView];
            }
        }
    }
    
    
}
- (void)viewDidLayoutSubviews{
    
    UICollectionViewFlowLayout *layout  = (UICollectionViewFlowLayout *)self.dataCollectionView.collectionViewLayout;
    CGFloat width;
    layout.minimumInteritemSpacing = 0.1;
    layout.minimumLineSpacing = 0.1;
    if (_colNumber > 1) {
        width = (self.view.width - layout.minimumInteritemSpacing * (_colNumber + 1)) / _colNumber;
        layout.itemSize = CGSizeMake(width, K_TABLE_CELL_HEIGHT);
    } else {
        width = self.view.width;
        layout.itemSize = CGSizeMake(width, K_TABLE_CELL_HEIGHT);
    }
}
/*
 1. 通过医院（门店）id找到 医院下所有医生
 2.通过医生的department_id 归类医院(门店)所有部门
 3.通过部门id 查找每个部门下的医生
 */

- (NSArray *)getHosWithStore:(WSStoreBean *)storeBean withFilter:(BOOL)withFilter {
    self.departmentIDArray = [NSMutableArray array];
    [_departmentIDArray removeAllObjects];

    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc]init];
    //所有医生
    NSArray *allDoctors = [[WSBaseStoreDBService shareInstance] queryStoreWithFilter:nil andNodeName:nil andEmpId:nil andPid:storeBean.Id];
    NSMutableArray *docDepartmentIds = [NSMutableArray array];
    for (WSStoreBean *storeBean in allDoctors) {
        if (![docDepartmentIds containsObject:storeBean.departmentId]) {
            [docDepartmentIds addObject:storeBean.departmentId];
        }
    }
    //所有医生对应的科室
    NSArray *docDepartment = [service queryDictsWithIDs:docDepartmentIds];
    NSMutableArray *hosArray = [NSMutableArray array];
    if (docDepartment) {
        for (NSInteger i = 0 ; i < [docDepartment count]; i++) {
            WSDictBean *departmentDict = docDepartment[i];
            NSString *departmentId = departmentDict.Id;
            [_departmentIDArray addObject:departmentId];
            
            /*用医生(门店)的item_name(里边含有科室人员数)字段当做 科室的名字*/
            NSPredicate *docPredicte;
            if (withFilter && self.currentFunc.filter) {
                docPredicte = [NSPredicate predicateWithFormat:@"self.departmentId == %@ and self.styp == %@", departmentId, self.currentFunc.filter];
            } else {
                docPredicte = [NSPredicate predicateWithFormat:@"self.departmentId == %@",departmentId];
            }
            NSArray *doc_item_names = [allDoctors filteredArrayUsingPredicate:docPredicte];
            NSString *hosBeanName = [(WSStoreBean *)[doc_item_names firstObject] item_name];
            WSHosBean *hosBean = [[WSHosBean alloc] initHosWihDepartmentId:departmentId departmentName:hosBeanName storeId:storeBean.Id isPlan:storeBean.plan iconUrl:departmentDict.iconUrl];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.departmentId == %@",departmentId];
            NSArray *departmentDocts = [allDoctors filteredArrayUsingPredicate:predicate];
            NSMutableArray *doctHosArray = [NSMutableArray array];
            
            for (NSInteger i = 0; i < [departmentDocts count]; i++) {
                WSStoreBean *docStoreBean = departmentDocts[i];
                WSHosBean *docHosBean = [[WSHosBean alloc] initHosWihStore:departmentDocts[i] storeId:storeBean.Id isPlan:docStoreBean.plan];
                docHosBean.detail_info = docStoreBean.detail_info;
                [doctHosArray addObject:docHosBean];
            }
            
            [hosBean.hosBeanArray addObjectsFromArray:doctHosArray];
            [hosArray addObject:hosBean];
            
        }
    }else{
        // SFA-16399  SFA史克医院--医生分级问卷模块--计划内门店未显示医生列表  --- 如果没有科室直接返回医生列表。
        
        for (WSStoreBean * store in allDoctors) {
            if (store.styp && self.currentFunc.filter && [store.styp isEqualToString:self.currentFunc.filter]){
                
                WSHosBean *docHosBean = [[WSHosBean alloc] initHosWihStore:store storeId:storeBean.Id isPlan:store.plan];
                [hosArray addObject:docHosBean];
                
            }
        }
    }
    
    return hosArray;
 
}

- (void)dealloc {
    
    if (self.currentStore.iStoreIdentify) {
        self.currentStore.iStoreIdentify = nil;
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_colNumber && _isDoctor == NO) {
        if ([self.showArray count] < _colNumber) {
            return 1;
        }else{
            return  _maxRow;
        }
    }else{
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_colNumber && _isDoctor == NO) {
        if ([self.showArray count] < _colNumber) {
            return [self.showArray count];
        }else{
            return _colNumber;
        }
    }else{
         return [self.showArray count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WSVisitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVisitDoctorCellId forIndexPath:indexPath];
    WSHosBean *hosBean = nil;
    NSString *title = nil;
    if (indexPath.section + indexPath.row *_maxRow < self.showArray.count) {
        hosBean = [self.showArray objectAtIndex:(indexPath.section + indexPath.row *_maxRow) ];
        title = hosBean.name;
    }
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.func_code = self.currentFunc.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.dict_id = hosBean.Id;
    action.title = title;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
    BOOL isContain = [_departmentIDArray containsObject:hosBean.Id];
    
    [cell setDataWithFuncsBean:self.currentFunc withHosBean:hosBean visitActionStatus:status isContaintDepartment:isContain isDoctor:_isDoctor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section + indexPath.row *_maxRow < self.showArray.count) {
        WSHosBean *hosBean = [self.showArray objectAtIndex:(indexPath.section + indexPath.row * _maxRow)];
        
        UIViewController *pushVC = nil;
        if ([hosBean.hosBeanArray count] == 0) {
            
            WSFuncsBean *l_fb = [self.currentFunc.funcsArray objectAtIndex:0];
            WSFuncsBean *fb = [l_fb.funcsArray objectAtIndex:0];
            
            LogInfo(@"Go into class %@\n", [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName]);
            
            WCBaseViewController *vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName]) alloc] initWithFuncs:fb Store:self.currentStore];
            
            if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
                vc = [[WSSpecialAcvtViewController alloc] initWithFuncs:fb Store:self.currentStore hosBean:hosBean];
            }
            
            
            if (vc == nil) {
                if([fb.isAcvtList isEqualToString:@"1"]) {
                    
                    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                    NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];
                    WSAcvtBean *l_acvtBean = nil;
                    if([filtersArray count] > 0)
                        l_acvtBean = [filtersArray objectAtIndex:0];
                    vc = [[WSAcvtViewController alloc] initWithAcvt:l_acvtBean Funcs:fb Store:self.currentStore];
                }else{
                    self.currentStore.iStoreIdentify = hosBean.Id;
                    LogInfo(@"[%@]",self.currentStore.iStoreIdentify);
                    //                vc = [[NSClassFromString([PropertyManager getPropertybyKey:fb.ds]) alloc] initWithFuncs:fb Store:self.currentStore];
                    vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]) alloc] initWithFuncs:fb Store:self.currentStore];
                    [vc setShowActionTip:YES];
                }
            }
            pushVC = vc;
        } else {
            VisitDoctorViewController *vd = [[VisitDoctorViewController alloc] initWithFuncs:self.currentFunc Store:self.currentStore hosArray:hosBean.hosBeanArray];
            pushVC = vd;
        }
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = self.currentStore.Id;
        action.func_code = self.currentFunc.fc;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = hosBean.name;
        action.func_code = action.func_code;
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        
        pushVC.currentVisitAction = action;
        
        if ([pushVC respondsToSelector:@selector(setRealParentFuncsCode:)]) {
            [pushVC performSelector:@selector(setRealParentFuncsCode:) withObject:self.realParentFuncsCode];
        }
        
        [self.navigationController pushViewController:pushVC animated:YES];
    }
    
}
#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self queryHosNameWith:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self queryHosNameWith:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self queryHosNameWith:searchBar.text];
}

-(void)queryHosNameWith:(NSString *)hosName{
    if (hosName.length > 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@" , hosName];
        self.showArray = [NSArray arrayWithArray:[self.currentDataArray filteredArrayUsingPredicate:predicate]];
    }
    else
        self.showArray = [NSArray arrayWithArray:self.currentDataArray];
    
    [self.dataCollectionView reloadData];
}
@end
