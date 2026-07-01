//
//  WSStoreKPIViewController.m
//  WinSFA
//
//  Created by Alicia on 17/2/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreKPIViewController.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSStoreKPICell.h"
#import "WSReportFormController.h"

static NSString * const kKPICellId = @"KPICell";

@interface WSStoreKPIViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) WSFuncsBean *currentFuncs;
@property (nonatomic, strong) WSAcvtBean *acvtBean;
@property (nonatomic, strong) WSBaseModel *model;
@property (nonatomic, strong) UICollectionView *dataCollectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation WSStoreKPIViewController


- (id)initWithFuncs:(WSFuncsBean *)currentFuncs acvtBean:(WSAcvtBean *)acvtBean store:(WSStoreBean *)currentStore {
    self = [super init];
    if (self) {
        _currentFuncs = currentFuncs;
        _acvtBean = acvtBean;
        
        WSAcvtModel *model = [[WSAcvtModel alloc] init];
        model.currentFuncs = currentFuncs;
        model.currentAcvtBean = acvtBean;
        model.currentStore = currentStore;
        self.model = model;
        [WSDataSourceManager sharedInstance].currentActiveModel = model;
        
        [self initData];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupViews {
    if (!self.dataArray || [self.dataArray count] == 0) {
        return;
    }
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];

    layout.minimumInteritemSpacing = 1;
   
    // 以第一组数据的个数为准
    CGFloat column = [self.dataArray[0] count];
    CGFloat width = (self.view.width - layout.minimumInteritemSpacing * (column - 1)) / column;
    layout.itemSize = CGSizeMake(width, kKPIViewHeight - 2 );
    
    CGRect frame = CGRectMake(0, 0, self.view.width, self.dataArray.count * kKPIViewHeight);
    self.dataCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.dataCollectionView.delegate = self;
    self.dataCollectionView.dataSource = self;
    [self.dataCollectionView registerClass:[WSStoreKPICell class] forCellWithReuseIdentifier:kKPICellId];
 
    self.dataCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dataCollectionView];
    [self.view setFrame:frame];
}


#pragma mark - Collection DataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat column = [self.dataArray[0] count];
    CGFloat width = (self.view.width - 1 * (column - 1)) / column;
    CGSize itemSize = CGSizeMake(width, kKPIViewHeight - 2 );
    return itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArray[section];
    return [sectionArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSStoreKPICell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kKPICellId forIndexPath:indexPath];
    
    [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSObject<I_W_BuildInfo> *buildInfo = sectionArray[indexPath.row];
    [cell setBuildInfo:buildInfo];
    if (indexPath.row == (sectionArray.count - 1)) {
        cell.separatorLable.hidden = YES;
    }else{
        cell.separatorLable.hidden = NO;
    }
    return cell;
}

//MMSH-7467
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSObject<I_W_BuildInfo> *buildInfo = sectionArray[indexPath.row];
    
    WSStoreKPICell *cell = (WSStoreKPICell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *segmentedResult = [cell getSegmentedResult];
    if (segmentedResult && segmentedResult.length > 0) {
        
        NSURL *url = [NSURL URLWithString:[segmentedResult stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        WSReportFormController *vc = [[WSReportFormController alloc] initWithURL:url];
        vc.title = [buildInfo getQuestName];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Private Method

- (void)initData {
    
    NSArray *qstArray = [self.acvtBean.qsts copy];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < qstArray.count; i++) {
        WSAcvtBean_qst *qstBean = qstArray[i];
        
        if ([[qstBean getGroupName] isEqualToString:HORIZONTAL_GROUP_START] &&
            (![[qstBean getIsHidden] isEqualToString:@"1"])) {
            NSMutableArray *nextArray = [NSMutableArray array];
            [nextArray addObject:qstBean];
            
            NSInteger m = i;
            for (NSInteger k = m + 1; m < [qstArray count]; k++) {
                WSAcvtBean_qst *qstBeanNext = qstArray[k];
                if ([[qstBeanNext getGroupName] isEqualToString:HORIZONTAL_GROUP_START]) {
                    i = k - 1;
                    break;
                }
                
                if (![[qstBean getIsHidden] isEqualToString:@"1"]) {
                    [nextArray addObject:qstBeanNext];
                }
                
                if ([[qstBeanNext getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) {
                    i = k;
                    break;
                }
            }
            
            if ([nextArray count] > 0) {
                [tempArray addObject:nextArray];
            }
        }
    }
    NSArray *dataArray = [NSArray array];
    if ([tempArray count] == 0) {
        // 没有分组
        if ( [qstArray count] > 0 ) {
            dataArray = [NSArray arrayWithObject:qstArray];
        }
    } else {
        dataArray = [tempArray copy];
    }
    self.dataArray = dataArray;
}


@end
