//
//  WSWorkbenchView.m
//  WinSFA
//
//  Created by yang on 16/12/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSWorkbenchView.h"
#import "WSWorkbenchSectionHeaderView.h"
#import "WSWorkbenchSectionFooterView.h"
#import "WSWorkbenchCollectionViewCell.h"
#import "WSVisitedMenuArray.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseMsgTable.h"

#define kItemHeight 80
#define kMNItemHeight 108 //蒙牛首页新样式高度

static NSString *cellReuseIdentifer = @"WSWorkbenchCollectionViewCell";
static NSString *sectionHeaderReuseIndentifer = @"WSWorkbenchCollectionViewCell";
static NSString *sectionFooterReuseIndentifer = @"WSWorkbenchSectionFooterView";

@interface WSWorkbenchView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *dictBeanArray;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) NSInteger colNumber;
@property (nonatomic, strong) NSMutableArray *itemWidthArray;
@end

@implementation WSWorkbenchView

- (instancetype)initWithFrame:(CGRect)frame withColNumber:(NSInteger)colNumber{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.sectionInset = UIEdgeInsetsMake(10, 0, 8, 0);
        self.colNumber = colNumber;
        
        CGFloat itemWidth = self.width/colNumber;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, kItemHeight);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = self.sectionInset;
        flowLayout.headerReferenceSize = CGSizeMake(self.width, MAIN_SECTION_HEIGHT);
        flowLayout.footerReferenceSize = CGSizeMake(self.width, 2.5);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [collectionView registerClass:[WSWorkbenchCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifer];
        [collectionView registerClass:[WSWorkbenchSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionHeaderReuseIndentifer];
        [collectionView registerClass:[WSWorkbenchSectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:sectionFooterReuseIndentifer];
        
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = WHITE_COLOR;
        collectionView.bounces = NO;
        
        self.collectionView = collectionView;
        [self addSubview:collectionView];
    }
    
    return self;
}


- (void)setDataSource:(NSArray *)dataSourceArray andDicts:(NSArray *)dictBeanArray
{
    self.dictBeanArray = dictBeanArray;
    
    self.dataSource = dataSourceArray;
    //        MN-1774
    //        IOS-工作图标改成一行3个 参安卓
    [self getSectionItemWidth];
    
    [self.collectionView reloadData];
}
//获取每组item 的宽度
- (void)getSectionItemWidth
{
    self.itemWidthArray = [NSMutableArray array];
    NSInteger colNum = _colNumber;
    CGFloat itemWidth = self.width/colNum;
    for (NSArray *sectionArray in self.dataSource) {
        if (sectionArray && sectionArray.count > 0) {
            WSFuncsBean *fb = (WSFuncsBean *)[sectionArray objectAtIndex:0];
            colNum = fb.colNum;
        }
        
        itemWidth = self.width/colNum;
        
        [self.itemWidthArray addObject:@(itemWidth)];
    }
    
}


- (VisitActionStatus)getVisitActionStatusWithFuncsBean:(WSFuncsBean *)funcsBean
{
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    // 新增门店的 parent_action_id 单独处理
    // 兼容新增即拜访的情况
    if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
        
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
        
        if (self.currentStore.Id) {
            action.parent_action_id = 0;
        } else {
            action.parent_action_id = self.currentVisitAction.ID;
        }
        
        //上述代码逻辑影响到计划外门店拜访状态更新，所以添加下面逻辑，如果下级页面有上级的currentVisitAction，则建立联系。 如果对其他功能有影响，可以找我沟通。MHRL-389的开发者
        if (self.currentVisitAction && [self.currentVisitAction.module_fc length] > 0 && !(self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"])) {
            action.parent_action_id = self.currentVisitAction.ID;
        }
    }
    else
    {
        action.parent_action_id = self.currentVisitAction.ID;
    }
    
    NSString *entryid = nil;
    if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
        entryid = self.currentStore.Id;
    }else{
        entryid = @"";
    }

    action.store_id = entryid/*self.currentStore.Id*/;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.is_required = funcsBean.required;
    action.title = funcsBean.name;
    
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        action.module_fc = action.func_code;
    }
    
    
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action intOutFlag:nil];
    
    return status;
}

- (CGFloat)contentHeight
{
    CGFloat height = 0;
    CGFloat itemHeight = kMNItemHeight;
    if (!_isGridHomeStyle){
        height = MAIN_SECTION_HEIGHT;
        itemHeight = kItemHeight;
    }
    for (NSArray *dataArray in self.dataSource) {
        height += height + self.sectionInset.top + self.sectionInset.bottom;
        height += (dataArray.count/_colNumber + 1) * itemHeight;

    }
    
    return height;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.dataSource[section];
    return [sectionArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSWorkbenchCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifer forIndexPath:indexPath];
    
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean *funcBean = sectionArray[indexPath.row];
    
    VisitActionStatus visitStatus = [self getVisitActionStatusWithFuncsBean:funcBean];
    
//    if ([self.delegate respondsToSelector:@selector(visitActionStatusForFuncBean:)]) {
//        visitStatus = [self.delegate visitActionStatusForFuncBean:funcBean];
//    }
    cell.isGrid = _isGridHomeStyle;

    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSInteger badgeCount = [dataService getFuncTipCountWithFC:funcBean.fc storeId:self.currentStore.Id];
    
    //SFA-25166   count从信息表中查找
    if ( [funcBean.fv isEqualToString:@"TB_V10"] || [funcBean.fv isEqualToString:@"TB_V12"]) {
     badgeCount =  [self getBadgeCountWithFuncBean:funcBean];
    }
    if([funcBean.fv isEqualToString:@"TB_V130"] || [funcBean.fv isEqualToString:@"TB_V140"] )
    {
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        badgeCount = [[WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:FUNC_TIP empId:empId funcode:funcBean.fc] integerValue];
    }
    [cell setDataWithFuncsBean:funcBean visitActionStatus:visitStatus badgeCount:badgeCount];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        WSWorkbenchSectionHeaderView *tmpMonthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionHeaderReuseIndentifer forIndexPath:indexPath];
        
        reusableview = tmpMonthHeader;
        WSDictBean *dictBean = self.dictBeanArray[indexPath.section];
        
        [tmpMonthHeader setTitle:dictBean.name];
    }else if (kind == UICollectionElementKindSectionFooter){
        WSWorkbenchSectionFooterView *tmpMonthFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:sectionFooterReuseIndentifer forIndexPath:indexPath];
        reusableview = tmpMonthFooter;
    }
    
    return reusableview;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    NSArray *sectionArray = self.dataSource[indexPath.section];
    WSFuncsBean *funcBean = sectionArray[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(workbenchView:didSelectItem:)]) {
        [self.delegate workbenchView:self didSelectItem:funcBean];
    }
}
#pragma mark - UICollectionViewDelegateFlowLayout
//每个cell的大小，因为有indexPath，所以可以判断哪一组，或者哪一个item，可一个给特定的大小，等同于layout的itemSize属性
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = self.width/_colNumber;
    if (!_isGridHomeStyle) {
        CGFloat itemWidth = [[self.itemWidthArray objectAtIndex:indexPath.section] floatValue];
        return CGSizeMake(itemWidth, kItemHeight);
    }
    return CGSizeMake(itemWidth,kMNItemHeight);
}

// 设置整个组的缩进量是多少
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (!_isGridHomeStyle) {
        return  self.sectionInset;
    }
    return  UIEdgeInsetsMake(10, 10, 8, 10);
}

// 设置section头视图的参考大小，与tableheaderview类似
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (!_isGridHomeStyle) {
        height = MAIN_SECTION_HEIGHT;
    }
    return CGSizeMake(self.width, height);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGFloat height = 0;
    if (!_isGridHomeStyle) {
        height = MAIN_SECTION_HEIGHT;
    }
    return CGSizeMake(self.width, 15.0);
}
//获取未读条数SFA-25166
- (NSInteger)getBadgeCountWithFuncBean:(WSFuncsBean *)fb {
    
    NSInteger Totalcount = 0;
    for (WSFuncsBean *funcBean in fb.funcsArray) {
        if (funcBean.filter) {
            NSInteger  subCount =   [[WSBaseMsgTable sharedTable] queryNOReadedBaseMsgsWithIsread:@"0" typcode:funcBean.filter];
            Totalcount += subCount;
        }
    }
    return Totalcount;
}

@end
