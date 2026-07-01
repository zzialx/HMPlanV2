//
//  WSWorkFlowMoreViewController.m
//  WinSFA
//
//  Created by Alicia on 17/2/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWorkFlowMoreViewController.h"
#import "WSWorkFlowCollectionViewCell.h"
#import "WSWorkbenchSectionHeaderView.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreOtherDataDBService.h"

static NSString * const kWorkFlowMoreCellId = @"WorkFlowMoreCell";
static NSString * const kWorkFlowMoreHeaderCellId = @"WorkFlowMoreHeaderCell";

@interface WSWorkFlowMoreViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *dataCollectionView;


@end

@implementation WSWorkFlowMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDictBeanAndDataSource];
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDictBeanAndDataSource {
    [super initDictBeanAndDataSource];
    
    if (self.ignoreMenuTypeId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.Id != %@", self.ignoreMenuTypeId];
        self.dataSource = [self.dataSource filteredArrayUsingPredicate:predicate];
    }
}


- (void)setupViews {
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.1;
    layout.minimumLineSpacing = 0.1;
    CGFloat   width = (self.view.width - layout.minimumInteritemSpacing * (kColumn + 1)) / kColumn;
    layout.itemSize = CGSizeMake(width, width * kWidthHeightRatio);
    
    CGRect frame = CGRectMake(0, 0, self.view.width,self.view.height);
    self.dataCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.dataCollectionView.delegate = self;
    self.dataCollectionView.dataSource = self;
    self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.dataCollectionView registerClass:[WSWorkFlowCollectionViewCell class] forCellWithReuseIdentifier:kWorkFlowMoreCellId];

    [self.dataCollectionView registerClass:[WSWorkbenchSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kWorkFlowMoreHeaderCellId];
    layout.headerReferenceSize = CGSizeMake(self.view.width, MAIN_SECTION_HEIGHT);
    self.dataCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dataCollectionView];
}

#pragma mark - Collection DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataSource[section];
    return [sectionArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
     return [self.dataSource count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSWorkFlowListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWorkFlowMoreCellId forIndexPath:indexPath];
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean* fb = sectionArray[indexPath.row];
    NSInteger total = [sectionArray count];
    
    WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
    VisitActionStatus visitStatus = [self getVisitActionStatusWithFuncsBean:fb action:action];
    BOOL hasTips = [self hasTipsWithStore:self.currentStore funcCode:fb];
    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSInteger badgeCount = [dataService getFuncTipCountWithFC:fb.fc storeId:self.currentStore.Id];
    [cell setDataWithFuncsBean:fb store:self.currentStore visitActionStatus:visitStatus action:action hasTips:hasTips badgeCount:badgeCount indexPath:indexPath totalCount:total];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    WSWorkbenchSectionHeaderView* reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kWorkFlowMoreHeaderCellId forIndexPath:indexPath];
    
    WSDictBean *dictBean = self.dictBeanArray[indexPath.section];
    [reusableView setTitle:dictBean.name];
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.wsSplitController) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];    //选中后的反显颜色即刻消失
    }
    
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean* fb = sectionArray[indexPath.row];
    
    UIViewController *vc = [self checkNextPageWithFuncsBean:fb withShowToast:YES];
    [self gotoNextPageWithViewController:vc withFuncsBean:fb withAutoJump:NO];
}

@end
