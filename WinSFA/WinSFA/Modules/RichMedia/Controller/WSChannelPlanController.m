//
//  WSChannelPlanController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSChannelPlanController.h"

#import "WSCoverFlowView.h"

#import "WSRichShowCollectionCell.h"

#import "WSRichModel.h"
#import "WSRichItemModel.h"

#import "WSSearchTableViewCell.h"
#import "WSRichMediaTemplateTable.h"

#import "WSRichMediaTable.h"
#import "WSRichMediaTemplate.h"
#import "WSBaseDictsTable.h"

#define kButtonMargin 20

@interface WSChannelPlanController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,WSCoverFlowViewDelegate>
{
    NSMutableArray * buttonArray;
    WSCoverFlowView *coverFlowView;
    UIScrollView * buttonBackgroundView;
    UICollectionView * _collectionView;
    
    NSArray * filterArray;
    NSArray  *richItemArray;
    
    UITableView * _bookmarksTable;
    UIButton * _bgButton;
    NSString * currentFilterId;
}

@property(nonatomic,strong)  NSMutableArray  *shouChangArray;
@end

static NSString *reuserId = @"WSRichShowCollectionCell";
@implementation WSChannelPlanController
-(NSMutableArray *)shouChangArray{

    if (_shouChangArray == nil) {
        _shouChangArray  = [[NSMutableArray alloc]init];

    }
    
    return _shouChangArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self getShouChangArray];
    filterArray = [self getFilterItemsWiht:self.filterName];
    
    buttonArray = [NSMutableArray arrayWithCapacity:filterArray.count];
    [self addHeadCoverFlowView];
    [self addSelectCuisineView];
    [self addCollectionView];
    if (buttonArray.count > 0) {
        [self selectCuiSine:buttonArray[0]];
    }
    _bookmarksTable = [[UITableView alloc]initWithFrame:CGRectMake(-300, buttonBackgroundView.centerY - 250, 300, 500) style:UITableViewStylePlain];
    _bookmarksTable.delegate = self;
    _bookmarksTable.dataSource = self;
    _bookmarksTable.allowsSelectionDuringEditing = YES;
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    titleLabel.text = @"我的收藏";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = MAIN_TINT_COLOT;
    _bookmarksTable.tableHeaderView = titleLabel;
    _bookmarksTable.editing = YES;
    _bgButton = [[UIButton alloc]initWithFrame:self.view.bounds];
    [_bgButton addTarget:self action:@selector(hideBookMark) forControlEvents:UIControlEventTouchUpInside];
    _bgButton.hidden = YES;
    [self.view addSubview:_bgButton];
    [self.view addSubview:_bookmarksTable];
    
    
}

-(void)addHeadCoverFlowView{

    NSMutableArray * allImageArray = [[NSMutableArray alloc]init];
//    for ( WSRichModel * model  in filterArray) {
//        
//        NSArray * tempArray = [self getAllItemWith:self.filterName withFilterName:model._id];
//        
//        for (WSRichItemModel  *tempModel in tempArray) {
//            [allImageArray addObject:tempModel];
//        }
//
//    }
//    NSString *sql = [NSString stringWithFormat:@"SELECT spe.ID, spe.speid, spe.cod,spe.name ,spe.typ, spe.memo, spe.img_url, spe.h5_url, spe.levelCode, spe.h5_add, spe.img_add , spe.share_url , spe.isread ,spe.type_,spe.fenleiId FROM  base_dicts AS dict, spe_richMedia AS spe WHERE dict.name = '%@' AND  dict.typ = 'fumeiti_label' AND dict._id = spe.typ  ORDER BY speid;",self.filterName];
//    allImageArray =  [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    allImageArray = [self getAllItemWith:self.filterName].mutableCopy;
    
    if (allImageArray.count > 0) {
        coverFlowView = [WSCoverFlowView coverFlowViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.size.height / 2.5) andImages:allImageArray sideImageCount:4 sideImageScale:0.4 middleImageScale:0.5];
        coverFlowView.backgroundColor = [UIColor blackColor];
        coverFlowView.delegate = self;
        //    coverFlowView.alpha = 0.6;
        [self.view addSubview:coverFlowView];
    }else{
        coverFlowView = (WSCoverFlowView *)[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.size.height / 2.5)];
        coverFlowView.backgroundColor = [UIColor blackColor];

        [self.view addSubview:coverFlowView];
    }
   
}

-(void)addSelectCuisineView{
    
//    CGFloat buttonWidth = (self.view.width - 10 * kButtonMargin - 40) / 9;
    CGFloat buttonWidth = (self.view.width - 10 * kButtonMargin ) / 9;

    CGFloat buttonOriginY = coverFlowView.bottom;
    buttonBackgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, buttonOriginY, self.view.width, 60)];
    buttonBackgroundView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    buttonBackgroundView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:buttonBackgroundView];

    for (int i = 0; i < filterArray.count + 1; i++) {
        WSRichModel * model;
        UIButton * cuisineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cuisineButton.frame = CGRectMake((i - 1)  * buttonWidth  + i *kButtonMargin  , 10, buttonWidth, 40);

        if (i != 0) {
            model = filterArray[i -1];
            cuisineButton.tag = [model._id integerValue];
            [cuisineButton addTarget:self action:@selector(selectCuiSine:) forControlEvents:UIControlEventTouchUpInside];
            [cuisineButton setTitle:model.name forState:UIControlStateNormal];
            [cuisineButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [cuisineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            [cuisineButton setBackgroundImage:[UIImage imageNamed:@"normal_ipad"] forState:UIControlStateNormal];
            [cuisineButton setBackgroundImage:[UIImage imageNamed:@"select_ipad"] forState:UIControlStateSelected];
            
            [buttonArray addObject:cuisineButton];
            [buttonBackgroundView addSubview:cuisineButton];

        }else{
//            cuisineButton.frame = CGRectMake(0, coverFlowView.bottom, 40, 60);
//            cuisineButton.backgroundColor = MAIN_TINT_COLOT;
//            [cuisineButton setImage:[UIImage imageNamed:@"star_must@2x"] forState:UIControlStateNormal];
//            [cuisineButton addTarget:self action:@selector(popBookmarks) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:cuisineButton];
        }
        
        
        UIButton * btn = [buttonArray lastObject];
        buttonBackgroundView.contentSize = CGSizeMake(btn.frame.origin.x +buttonWidth , 0);
    }
    
}

-(void)addCollectionView{
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0 ;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, buttonBackgroundView.bottom , self.view.width, self.view.height - buttonBackgroundView.bottom - buttonBackgroundView.height - 30) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[WSRichShowCollectionCell class] forCellWithReuseIdentifier:reuserId];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
}

-(void)selectCuiSine:(UIButton *)sender{
    currentFilterId = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    richItemArray = [self getAllItemWith:self.filterName withFilterName:currentFilterId];
    
    for (UIButton * button  in buttonArray) {
        if (sender.tag == button.tag) {
            sender.selected = YES;
        }else{
            button.selected = NO;
        }
    }
    [_collectionView reloadData];
}

-(void)popBookmarks{

    [UIView animateWithDuration:0.25 animations:^{
        _bgButton.hidden = NO;
        _bookmarksTable.left = 0.0;
        
    } completion:^(BOOL finished) {
        //
    }];
    
    [self getShouChangArray];

}

-(void)hideBookMark{
    
    [UIView animateWithDuration:0.25 animations:^{
        _bgButton.hidden = YES;
        _bookmarksTable.left = -300.0;
        
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)getShouChangArray{
    [self.shouChangArray removeAllObjects];
    NSArray * array = [[WSRichMediaTemplateTable sharedTable]queryAndReturnInfosBySql:@"select * from spe_richMedia_template where type = 'bookmark'" andClassName:@"WSRichMediaDemoList"];
    for (WSRichMediaDemoList  *object in array) {
        NSArray  *tempArray = [[WSRichMediaTable sharedTable] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from spe_richMedia where ID = '%@'",object.sid] andClassName:@"WSRichItemModel"];
        if (tempArray.count) {
            [self.shouChangArray addObject:tempArray[0]];
        }
    }

    [_bookmarksTable reloadData];

}
#pragma mark - UITableViewDelegate,UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserId = @"UITableViewCellID";
    WSSearchTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[WSSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId withStyle:WSSearchTableViewCellStyleNone];
    }
    WSRichItemModel * model = _shouChangArray[indexPath.row];
    cell.model = model;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _shouChangArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self itemClickCallH5WithItemModel:_shouChangArray[indexPath.row]];
    [self hideBookMark];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    WSRichItemModel * object = self.shouChangArray[sourceIndexPath.row];
    [self.shouChangArray removeObject:object];
    [self.shouChangArray insertObject:object atIndex:destinationIndexPath.row];
    [_bookmarksTable reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WSRichItemModel* object = self.shouChangArray[indexPath.row];

        [self.shouChangArray removeObject:object];
        [[WSRichMediaTemplateTable sharedTable ] deleteProdstWithSqls:@[[NSString stringWithFormat:@"delete from spe_richMedia_template where type = 'bookmark' and sid = '%@'",object.ID]]];
        [_bookmarksTable reloadData];

    }
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WSRichShowCollectionCell * cell  =[collectionView dequeueReusableCellWithReuseIdentifier:reuserId forIndexPath:indexPath];
    cell.model = richItemArray[indexPath.row];
    cell.fontSize = 15;
    return cell;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return richItemArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(_collectionView.width
                       /5, _collectionView.height);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    [self itemClickCallH5WithItemModel:richItemArray[indexPath.row]];
}

#pragma mark - WSCoverFlowViewDelegate
-(void)popImageViewH5With:(WSRichItemModel *)model{
    
    [self itemClickCallH5WithItemModel:model];
}


-(void)reloadData{
    [super reloadData];
    richItemArray = [self getAllItemWith:self.filterName withFilterName:currentFilterId];
    [_collectionView reloadData];

}
@end
