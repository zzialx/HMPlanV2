//
//  WSHomePageViewController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/30.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHomePageViewController.h"
#import "WSHomePageFlowLayout.h"
#import "WSRichMediaTemplateTable.h"
#import "WSVisitStoreStatusTable.h"
#import "WSMappingObject.h"
#import "WSRichMediaTemplate.h"
#import "WSRichItemModel.h"
#import "WSRichMediaTable.h"
#import "WSMappingObject.h"
#import "WSHomePageCollectionViewCell.h"
#import "WSRichMediaOtherInfoTable.h"

#define kTopViewMargin 10

@interface WSHomePageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>

{
    UIImageView * _imageView ;
    UICollectionView * _collectionView;
    UISearchBar * _searchBar;
    UIButton * _backButton ;
    NSArray * _richItemArray;
}
@property(nonatomic,strong) NSMutableArray *dataSourceArray;
@end
static NSString * reuserID = @"UICollectionViewCell";

@implementation WSHomePageViewController

-(NSMutableArray *)dataSourceArray{
    if (_dataSourceArray == nil) {
        _dataSourceArray = [[NSMutableArray alloc]init];
    }
    return _dataSourceArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    WSHomePageFlowLayout * flowlayout = [[WSHomePageFlowLayout alloc]init];
    flowlayout.minimumInteritemSpacing = 30;
    flowlayout.minimumLineSpacing = 30;
    flowlayout.itemSize = CGSizeMake(self.view.bounds.size.width / 5, 300);
    flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 450) collectionViewLayout:flowlayout];
    [_collectionView registerClass:[WSHomePageCollectionViewCell class] forCellWithReuseIdentifier:reuserID];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
    
    [self loadShowData];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadShowData];
}

-(void)loadShowData{

    if (self.m_currentStore) {
        NSArray * visitStores = [[WSVisitStoreStatusTable shareInstance] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from visit_store_action where store_id = '%@' and func_code = 'F20S01_01'",self.m_currentStore.Id] andClassName:@"WSVisitStoreStatusObject"];
        WSVisitStoreStatusObject * object ;
        if (visitStores.count > 0) {
            object = visitStores[0];
        }
//        if ([object.status isEqualToString:@"1"]) {
               _richItemArray = [[WSRichMediaTemplateTable sharedTable] queryTableFordemoList:self.m_currentStore.Id];
//        }else{
//            _richItemArray = nil;
//        }
     
    }else{
        
        _richItemArray = [[WSRichMediaTemplateTable sharedTable] queryTabledemoListNotHavePid];
        
    }
    
    if (_richItemArray.count != 0) {
        
        [self scrollViewDidScroll:_collectionView];
        _collectionView.alpha = 1;
    }else{
        
        _collectionView.alpha = 0;
    }
    
    self.dataSourceArray = _richItemArray.mutableCopy;
    [_collectionView reloadData];

}
#pragma mark -  UICollectionViewDelegate,UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WSHomePageCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:reuserID forIndexPath:indexPath];
    WSRichMediaDemoList * demoList = _richItemArray[indexPath.row];
    cell.model = demoList.itemModel;
    return cell;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSourceArray.count;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    WSRichMediaDemoList * demoList = _dataSourceArray[indexPath.row];
    WSRichItemModel *model = demoList.itemModel;
    if (self.m_currentStore) {
        [self updataRichMediaTableWiht:model];
    }
    [self itemClickCallH5WithItemModel:model];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint pointInView = [self.view convertPoint:_collectionView.center toView:_collectionView];
    
    NSIndexPath  *indexPathNow = [_collectionView indexPathForItemAtPoint:pointInView];
    UICollectionViewCell *cell  = (UICollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPathNow];
    [_collectionView bringSubviewToFront:cell];
}

#pragma mark -  UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.itemModel.name contains[cd] %@",searchText];
        self.dataSourceArray = [_richItemArray filteredArrayUsingPredicate:predicate].mutableCopy;
    }else{
        self.dataSourceArray = _richItemArray.mutableCopy;
    
    }
   
    
    [_collectionView reloadData];
}


-(void)updataRichMediaTableWiht:(WSRichItemModel *)model{
    
    // 如果是门店的演示列表第一次点击的话需要记录点击的时间
    NSString *clickTime = [[WSRichMediaOtherInfoTable sharedTable] getClickTimeWithStoreId:self.m_currentStore.Id richMediaId:model.speid];
    
    if (!clickTime) {
        [[WSRichMediaOtherInfoTable sharedTable] insertClickTimeWithStoreId:self.m_currentStore.Id richMediaId:model.speid clickTime:[WSCurrentTime getCurrentTimeForRichMedia]];
    }
    
}
@end
