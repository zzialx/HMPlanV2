//
//  WSRichMediaOptionBar.m
//  选项卡
//
//  Created by huzepei on 16/7/26.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import "WSRichMediaOptionBar.h"
#import "PureLayout.h"
#import "WSRichMediaOptionCell.h"
#import "WSRichModel.h"
#import <QuartzCore/QuartzCore.h>

#define seriesBtnWidth 90
#define allBtnWidth 65
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define isKindOfString [self.dataArray[0] isKindOfClass:[NSString class]]

@interface WSRichMediaOptionBar()<UICollectionViewDataSource, UICollectionViewDelegate>

/**
 * 菜系
 */
@property (nonatomic,strong) UIButton *seriesBtn;
/**
 *  全部按钮
 */
@property (nonatomic,strong) UIButton *allBtn;

/**
 *  内容视图
 */
@property (nonatomic,strong) UICollectionView *contentView;

@property (nonatomic,strong)WSRichMediaOptionCell *currentItem;

@end

@implementation WSRichMediaOptionBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = WSColor(247, 248, 247);
        self.backgroundColor = [UIColor whiteColor];
//        self.layer.cornerRadius = 10.0;
        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"dingbian"]];
//        [self addSubview:imageView];
//        [imageView autoPinEdgesToSuperviewEdges];
    }
    return self;
}
-(void)layoutSubviews
{
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    CGFloat collectionX = seriesBtnWidth + allBtnWidth;
    CGFloat collectionW = self.frame.size.width - collectionX;
    
    if (isKindOfString) {
        
        [self.allBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
        [self.allBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
        [self.allBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [self.allBtn autoSetDimension:ALDimensionWidth toSize:allBtnWidth];
        
        [self.contentView setFrame:CGRectMake(allBtnWidth, 0, self.frame.size.width - allBtnWidth, self.frame.size.height)];
    }else{
        [self.seriesBtn autoSetDimension:ALDimensionWidth toSize:seriesBtnWidth];
        [self.seriesBtn autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeRight];
        
        [self.allBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.seriesBtn];
        [self.allBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
        [self.allBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [self.allBtn autoSetDimension:ALDimensionWidth toSize:allBtnWidth];
        
        [self.contentView setFrame:CGRectMake(collectionX, 0, collectionW, self.frame.size.height)];
    }
    
    [super layoutSubviews];
}

#pragma getter setter
-(void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
}
-(void)setKindStringIDs:(NSArray *)kindStringIDs
{
    _kindStringIDs = kindStringIDs;
}
-(UIButton *)seriesBtn
{
    if (!_seriesBtn) {
        _seriesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seriesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_seriesBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_seriesBtn setTitleColor:WSColor(237, 90, 43) forState:UIControlStateSelected];
        [_seriesBtn setTitleColor:WSColor(127, 127, 127) forState:UIControlStateNormal];
        [self addSubview:_seriesBtn];
    }
    return _seriesBtn;
}
-(UIButton *)allBtn
{
    if (!_allBtn) {
        _allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         _allBtn.selected = YES;
        [_allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_allBtn setTitle:@"all" forState:UIControlStateNormal];
        [_allBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_allBtn setTitleColor:WSColor(237, 90, 43) forState:UIControlStateSelected];
        [_allBtn setTitleColor:WSColor(127, 127, 127) forState:UIControlStateNormal];
        [_allBtn addTarget:self action:@selector(chooseAll:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_allBtn];
    }
    return _allBtn;
}
-(UICollectionView *)contentView
{
    if (!_contentView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.dataSource = self;
        _contentView.delegate = self;
        [self addSubview:_contentView];
        
        [_contentView registerClass:[WSRichMediaOptionCell class] forCellWithReuseIdentifier:NSStringFromClass([WSRichMediaOptionCell class])];
    }
    return _contentView;
}
#pragma mark - event
-(void)chooseAll:(UIButton *)btn
{
    if (btn.selected == YES) {
        btn.selected = YES;
    }else{
        btn.selected = !btn.selected;
    }
    [_currentItem.btn setSelected:NO];
    
    
    NSString *allStr;
    if (isKindOfString) {
        
        allStr = @"000";
        
    }else{
        
        allStr = [NSString stringWithFormat:@"%@:000",self.groupHeaderID];
    }
    
    if ([self.delagate respondsToSelector:@selector(WSRichMediaOptionBarClickWithStringID:)]) {
        [self.delagate WSRichMediaOptionBarClickWithStringID:allStr];
    }
    
}
#pragma mark - setter getter

-(void)setGroupHeaderID:(NSString *)groupHeaderID
{
    _groupHeaderID  = groupHeaderID;
}
-(void)setGroupHeaderName:(NSString *)groupHeaderName
{
    _groupHeaderName = groupHeaderName;
    [self.seriesBtn setTitle:_groupHeaderName forState:UIControlStateNormal];
}
#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSRichMediaOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WSRichMediaOptionCell class]) forIndexPath:indexPath];
    if (isKindOfString) {
        NSString *item = self.dataArray[indexPath.item];
        cell.title = item;
    }else {
        WSFilterItem *item = self.dataArray[indexPath.item];
        cell.title = item.name;
        if (item.isSelected == YES) {
            cell.btn.selected = YES;
        }else{
            cell.btn.selected = NO;
        }

    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (isKindOfString) {
        NSString * item = self.dataArray[indexPath.item];
        
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        
        itemSize = [item boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]} context:nil].size;
#else
        itemSize = [item sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 44) lineBreakMode:NSLineBreakByWordWrapping];
#endif
        
    }else {
        WSFilterItem *item = self.dataArray[indexPath.item];
        
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        itemSize = [item.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]} context:nil].size;
#else
        itemSize = [item.name  sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 44) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    return CGSizeMake(itemSize.width + 20, self.height);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSRichMediaOptionCell *cell = (WSRichMediaOptionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.btn setSelected:YES];
    _currentItem = cell;
    if (self.allBtn.selected == YES) {
        self.allBtn.selected = NO;
    }
    
    NSString *clickStr;
    if (isKindOfString) {
        clickStr = self.kindStringIDs[indexPath.item];
    }else{
        WSFilterItem *item = self.dataArray[indexPath.item];
        if (self.groupHeaderID) {
            clickStr = [NSString stringWithFormat:@"%@:%@",self.groupHeaderID,item._id];
        }else{
            clickStr = [NSString stringWithFormat:@"%@",item._id];
        }
        item.isSelected = YES;
    }
    
    if ([self.delagate respondsToSelector:@selector(WSRichMediaOptionBarClickWithStringID:)]) {
        [self.delagate WSRichMediaOptionBarClickWithStringID:clickStr];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSFilterItem *item = self.dataArray[indexPath.item];
    if (!isKindOfString && item) {
        item.isSelected = NO;
    }
    
    WSRichMediaOptionCell *cell = (WSRichMediaOptionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.btn setSelected:NO];
    
}


- (void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    if (!isKindOfString) {
        
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(currentContext, [UIColor lightGrayColor].CGColor);
        CGContextSetLineWidth(currentContext, 0.5);
        CGContextMoveToPoint(currentContext, 0, self.height - 0.5);
        CGContextAddLineToPoint(currentContext, self.frame.origin.x + self.frame.size.width, self.height - 0.5);
        CGFloat arr[] = {4,4};
        CGContextSetLineDash(currentContext, 0, arr, 2);
        CGContextDrawPath(currentContext, kCGPathStroke);
    }
    
}
@end
