//
//  WSRichShowProdCell.m
//  WinSFA
//
//  Created by zhiqing on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichShowProdCell.h"
#import "PureLayout.h"
#import "WSRichShowCollectionCell.h"
#import "WSRequestHelper.h"

#define k_View_Width self.contentView.width / 7
#define k_View_Height 110
@interface WSRichShowProdCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView * _collectionView;
    NSString * _styleType;   // 是产品品类类型 还是 专业服务类型
}

@end
static NSString * reuserId = @"UICollectionViewCell";
@implementation WSRichShowProdCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(NSString *)styleType {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _styleType = styleType;
        [self setupContentView];
    }
    return self;
}

-(void)setupContentView{

    _filterImageView = [[UIImageView alloc]init];
    if ([_styleType isEqualToString:@"prod"]) {
        _filterImageView.image = [UIImage imageNamed:@"zhantai_ce"];
    }
    [self.contentView addSubview:_filterImageView];

    [_filterImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_filterImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_filterImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    if ([_styleType isEqualToString:@"prod"]) {

        [_filterImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:1/7.0];
    }else{
        [_filterImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:1/3.0];

    }
    
    if ([_styleType isEqualToString:@"prod"]) {
        self.typeImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.typeImageView];
        [self.typeImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.typeImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [self.typeImageView autoSetDimensionsToSize:CGSizeMake(100, 100)];
    }
        
    UICollectionViewFlowLayout  *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing  = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    if ([_styleType isEqualToString:@"prod"]) {
         [_collectionView registerClass:[WSRichShowCollectionCell class] forCellWithReuseIdentifier:reuserId];
    }else{
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuserId];
    }
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_collectionView];
    [_collectionView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_filterImageView];
    [_collectionView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_collectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    if ([_styleType isEqualToString:@"prod"]) {
        [_collectionView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.875 ];
    }else{
        [_collectionView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:2/3.0 ];
    }
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_styleType isEqualToString:@"prod"]) {
         WSRichShowCollectionCell * cell  =[collectionView dequeueReusableCellWithReuseIdentifier:reuserId forIndexPath:indexPath];
        cell.model = self.richItemArray[indexPath.row];
        cell.fontSize = 13;
        return cell;
    }else{
        UICollectionViewCell * cell  =[collectionView dequeueReusableCellWithReuseIdentifier:reuserId forIndexPath:indexPath];
        UIImageView * imageView = [[UIImageView alloc]init];
        [cell addSubview:imageView];
        [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        WSRichItemModel * model = self.richItemArray[indexPath.row];
        
        
        
        NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",model.img_add];
     
        NSFileManager *manager = [NSFileManager defaultManager];

        NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];

        NSURL *path = [url URLByAppendingPathComponent:imgStr2];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:imageView placeholderImage:[UIImage imageNamed:@"sort-0"]];
       
        
        return cell;
    }
   
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   
    return self.richItemArray.count;

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_styleType isEqualToString:@"prod"]) {
        return  CGSizeMake(self.contentView.width /7.0, self.contentView.height);

    }else{
        
        return  CGSizeMake(self.contentView.width /3.0, self.contentView.height);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(popWebViewWith:)]) {
        [self.delegate popWebViewWith:self.richItemArray[indexPath.row]];
    }
}


-(void)setRichItemArray:(NSArray *)richItemArray{
    _richItemArray = richItemArray;
    [_collectionView reloadData];
}

@end
