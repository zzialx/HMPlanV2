//
//  WSStoreTagView.m
//  WinSFA
//
//  Created by zzialx on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSStoreTagView.h"
#import "WSStoreTagTableViewCell.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSShowQstViewForStoreListCell.h"
#import "WSAgreeMentCollectionViewCell.h"

#define K_Row_H   18.0

#define PAD_LEFT        16.0

#define PAD_TOP         10.0

#define LAB_H           18.0

#define ICON_W          12.0

#define ICON_H          12.0

#define k_FoldBTN_W     20.0

#define KView_space     7

#define k_STORE_ATTRIVIEW_SPACE  2.0f

#define K_Left_Dis              (SCREEN_WIDTH == 375.0 ? 20:0)

#define K_NAV_BUTTON_WIDHT      (INTERFACE_IS_PHONE ? 80 : 85)

#define K_NAV_BUTTON_HEGIHT     (INTERFACE_IS_PHONE ? 18 : 20)

#define kView_Space_Left        (INTERFACE_IS_PHONE ? 15 : 20)

#define UI_SubView_Font         (INTERFACE_IS_PHONE ? 13.0f : 15.0f)

#define UI_SubView_Detail_Font  (INTERFACE_IS_PHONE ? 10.0f : 15.0f)

#define kView_Space_Top         (INTERFACE_IS_PHONE ? 14 : 15)

#define K_STORE_ICON_WIDHT      (INTERFACE_IS_PHONE ? 70: 90)

#define K_STORE_ICON_HEIGHT     (INTERFACE_IS_PHONE ? 70: 90)


static NSString * const CellIdentifier = @"CellIdentifier";

@interface WSStoreTagView ()<UICollectionViewDelegate,UICollectionViewDataSource>

/// 背景图
@property(nonatomic,strong)UIView * bgView;

/// 门店标签数据回显
@property (nonatomic , strong)WSBaseAcvtdisDBService * acvtdisService;

/// 标签数据源
@property (nonatomic, strong)NSMutableArray * dataList;


@end

@implementation WSStoreTagView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addSubview:self.collectionView];
        [self p_addMasonry];
    }
    return self;
}
#pragma amrk - # UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataList.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WSAgreeMentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setListModel:self.dataList[indexPath.section]];
    return cell;
}
/**
 cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    WSShowQstViewSingleLineModel * model = self.dataList[indexPath.section];
    if(model!=nil){
        CGFloat width = SCREEN_WIDTH - PAD_LEFT * 2 - K_NAV_BUTTON_WIDHT - K_STORE_ICON_WIDHT - kView_Space_Left + K_Left_Dis;
        NSString * content = [NSString stringWithFormat:@"%@：%@ ",model.qstname,ISNULL(model.qstanwser)];
        CGSize size  = [content ws_sizeWithFont:[UIFont systemFontOfSize:11] constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
        return CGSizeMake(width, size.height<20.0?22.0:size.height + 10);
    }
    return CGSizeMake(0, 0);
}
- (void)setStoreBean:(WSStoreBean *)storeBean{
    _storeBean = storeBean;
    if(_storeBean==nil)return;
    self.dataList = [self.acvtdisService queryAcvtDisWithStoreId:_storeBean.Id acvtCode:_acvtCode qstType:@"T"].mutableCopy;
    if(self.dataList.count==0){
        LogInfo(@"门店协议数据为空：%@_%@",_storeBean.name,_storeBean.Id);
    }
    [self.collectionView reloadData];
   
}
#pragma mark - # Private Method
- (void)p_addMasonry {
    // 协议View
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
#pragma mark - # Get Method
-(WSBaseAcvtdisDBService *)acvtdisService{
    if (!_acvtdisService) {
        _acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
    }
    return _acvtdisService;
}

-(UICollectionView*)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(2.5, 0, 2.5, 0);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.scrollEnabled = NO;
        _collectionView.scrollsToTop = NO;
        [_collectionView registerClass:[WSAgreeMentCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
    }
    return _collectionView;
}
@end
