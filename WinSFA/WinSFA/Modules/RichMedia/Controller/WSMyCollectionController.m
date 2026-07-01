//
//  WSMyCollectionController.m
//  WinSFA
//
//  Created by mac on 16/9/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyCollectionController.h"
#import "WSRichItemModel.h"
#import "WSShowImageCell.h"
#import "WSRichMediaTemplateTable.h"
#import "WSRichMediaTable.h"
#import "WSRichMediaTemplate.h"

@interface WSMyCollectionController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)NSMutableArray * dataSourceArray;
@end
static NSString * reuserID = @"MyCollecUICollectionViewCell";
@implementation WSMyCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[WSShowImageCell class] forCellWithReuseIdentifier:reuserID];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self getShouChangArray];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 获取收藏数据
    [self getShouChangArray];
}

-(void)getShouChangArray{
    [self.dataSourceArray removeAllObjects];
    NSArray * array = [[WSRichMediaTemplateTable sharedTable]queryAndReturnInfosBySql:@"select * from spe_richMedia_template where type = 'bookmark'" andClassName:@"WSRichMediaDemoList"];
    for (WSRichMediaDemoList  *object in array) {
        NSArray  *tempArray = [[WSRichMediaTable sharedTable] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from spe_richMedia where ID = '%@'",object.sid] andClassName:@"WSRichItemModel"];
        if (tempArray.count) {
            [self.dataSourceArray addObject:tempArray[0]];
        }
    }
    
    [self.collectionView reloadData];
    
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout  *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.minimumLineSpacing = 1;
        flowLayout.itemSize = CGSizeMake((self.view.bounds.size.width - 6) / 5, (self.view.height - 64 -3)/3);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
    }
    return _collectionView;
}

-(NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArray;
}
#pragma mark -  UICollectionViewDelegate,UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WSShowImageCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:reuserID forIndexPath:indexPath];
    cell.model =  _dataSourceArray[indexPath.row];
    cell.deleteBtn.hidden = YES;
    cell.cellIndexPath = indexPath;
    UILongPressGestureRecognizer  *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [cell addGestureRecognizer:longPress];
    longPress.minimumPressDuration = 1.0;
    __weak typeof(self)weakself = self;
    cell.deleteItem = ^(NSIndexPath * index){
       WSRichItemModel * model = weakself.dataSourceArray[indexPath.row];

        [weakself.dataSourceArray removeObjectAtIndex:index.row];
        [[WSRichMediaTemplateTable sharedTable ] deleteProdstWithSqls:@[[NSString stringWithFormat:@"delete from spe_richMedia_template where type = 'bookmark' and sid = '%@'",model.ID]]];
        [weakself.collectionView reloadData];
    };
    return cell;
}

-(void)longPressAction:(UILongPressGestureRecognizer * )action{
    WSShowImageCell *cell = (WSShowImageCell *) action.view;
    cell.deleteBtn.hidden = NO;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSourceArray.count;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    WSRichItemModel *model = _dataSourceArray[indexPath.row];
    [self itemClickCallH5WithItemModel:model];
}

@end
