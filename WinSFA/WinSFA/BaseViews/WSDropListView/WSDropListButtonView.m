//
//  WSDropListButtonView.m
//  WinSFA
//
//  Created by Alicia on 17/1/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDropListButtonView.h"
#import "WSDropListCollectionViewCell.h"
#import "WSDropListRoundedCell.h"
#import "WSBaseDropListView.h"
#import "NSString+Additions.h"
#import "WSDropListButtonLayout.h"

static NSString * const kDLCellIdentifier = @"DLCollectionCell";

#define kColumnNum      3
#define kSpacing        (MAIN_PADDING / 2)

@interface WSDropListButtonView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *dataCollectionView;
@property (nonatomic, strong) NSArray *itemFrameArray;
@end

@implementation WSDropListButtonView
#pragma mark - Public Method
- (void)setDataSourceArray:(NSArray *)dataSourceArray {
    [super setDataSourceArray:dataSourceArray];
    

    CGFloat height = [self getViewHeight];
    self.height = height + 2 * kSpacing;
    CGRect frame = CGRectMake(0, kSpacing, self.width, height);
    
    if (!self.dataCollectionView) {
        UICollectionViewLayout *layout;
        
        if (self.buttonStyle == WSDropListButtonFit) {
            WSDropListButtonLayout *buttonLayout = [[WSDropListButtonLayout alloc] init];
            [buttonLayout setItemFrameArray:self.itemFrameArray];
            
            layout = buttonLayout;
        } else {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            CGFloat width = (self.width - (kColumnNum + 1) * kSpacing) / kColumnNum;
            flowLayout.itemSize = CGSizeMake(width, MAIN_BUTTON_WH);
            flowLayout.minimumInteritemSpacing = kSpacing;
            flowLayout.minimumLineSpacing = kSpacing;
            
            layout = flowLayout;
        }
       
        self.dataCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        
        self.dataCollectionView.delegate = self;
        self.dataCollectionView.dataSource = self;
        self.dataCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.buttonStyle == WSDropListButtonFit) {
            [self.dataCollectionView registerClass:[WSDropListRoundedCell class] forCellWithReuseIdentifier:kDLCellIdentifier];
        } else {
            [self.dataCollectionView registerClass:[WSDropListCollectionViewCell class] forCellWithReuseIdentifier:kDLCellIdentifier];
        }
        [self.dataCollectionView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.dataCollectionView];
    } else {
        [self.dataCollectionView setFrame:frame];
    }
   
    [self.dataCollectionView reloadData];
}


- (void)setLimitNum:(NSString *)limitNum {
    [super setLimitNum:limitNum];
    
    [self.dataCollectionView reloadData];
}

- (void)setSelectedItemArray:(NSMutableArray *)selectedItemArray {
    [super setSelectedItemArray:selectedItemArray];
    [self.dataCollectionView reloadData];
}

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray {
    [super setUpSelectionByItemIDArray:dataItemIDArray];
    [self.dataCollectionView reloadData];
}


- (void)flushTable {
    [self.dataCollectionView reloadData];
}


#pragma mark - Private Method
- (CGFloat)getViewHeight {
    if (!self.dataSourceArray || self.dataSourceArray.count == 0) {
        return 0;
    }
    
    if (self.buttonStyle == WSDropListButtonFit) {
        // 除了计算出需要高度，还把每个 item 宽高计算出来
        CGFloat height = MAIN_BUTTON_WH;
        CGFloat width = 0;
        NSInteger row = 0;
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.dataSourceArray.count];
        // 保存一行的数据，需要换行时设置该行所有项的 frame
        NSMutableArray *lineArray = [NSMutableArray array];
        for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
            NSString *name = [dataItem getDataItemName];
            CGSize nameSize = [name ws_sizeWithFont:[UIFont systemFontOfSize:kDropListFontSize] constrainedToHeight:MAIN_BUTTON_WH];
            CGFloat nameWidth = nameSize.width + MAIN_PADDING;

            CGFloat col = lineArray.count;
            // 当前行文字间距
            CGFloat paddingWidth = (col - 1) * kSpacing;
            if (width + nameWidth >= self.size.width + paddingWidth) {
                CGFloat padding = (self.size.width - width - paddingWidth) / (col + 1);
                [self setLineArray:lineArray toTempArray:tempArray row:row padding:padding offsetX:padding];
                
                [lineArray removeAllObjects];
                
                height += MAIN_BUTTON_WH;
                width = 0;
                row++;
            }
            
            [lineArray addObject:[NSNumber numberWithFloat:nameWidth]];
            width += nameWidth;
        }
        
        [self setLineArray:lineArray toTempArray:tempArray row:row padding:kSpacing offsetX:0];
        height += MAIN_PADDING;
        self.itemFrameArray = [tempArray copy];
        
        return height;
    }
    else
    {
        //MN-1860 2018-04-18
        NSInteger row = (((self.dataSourceArray.count % kColumnNum) == 0) ? (self.dataSourceArray.count / kColumnNum) : ((self.dataSourceArray.count / kColumnNum) + 1));
        CGFloat height = (row - 1) * kSpacing + row * MAIN_BUTTON_WH;
        return height;
    }
}

- (void)setLineArray:(NSArray *)lineArray toTempArray:(NSMutableArray *)tempArray row:(NSInteger)row  padding:(CGFloat)padding offsetX:(CGFloat)offsetX {
    for (NSNumber *number in lineArray) {
        CGFloat itemWidth = [number floatValue];
        CGRect frame = CGRectMake(offsetX, row * (MAIN_BUTTON_WH + kSpacing), itemWidth, MAIN_BUTTON_WH);
        offsetX += itemWidth + padding;
        [tempArray addObject:NSStringFromCGRect(frame)];
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSDropListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDLCellIdentifier forIndexPath:indexPath];
    
    NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:indexPath.row];
    
    BOOL isSelected = NO;
    //SFA 项目SFA-22753 【SFA泸州老窖】【iOS】客户管理的门店详情中回显数据不全(配额协议没有显示选中颜色，因为走完脚本后此处为只读)
//    if (!self.sourceTableReadOnly && [self.selectedItemArray containsObject:dataItem]) {
    if ([self.selectedItemArray containsObject:dataItem]) {
        isSelected = YES;
    }
    [cell setDataItem:dataItem isSelected:isSelected];
    return cell;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sourceTableReadOnly) {
        return;
    }
    
    NSObject<I_W_OptionDataItem> *dataItem ;
    if (self.dataSourceArray.count > [indexPath row]) {
        dataItem  =  [self.dataSourceArray objectAtIndex:[indexPath row]];
    }
    NSInteger maxCount = 0;
    if (self.limitNum && [self.limitNum integerValue] > 0) {
        maxCount = [self.limitNum integerValue];
    } else if (self.maxNum > 0) {
        maxCount = self.maxNum;
    }
    
    if (![self.selectedItemArray containsObject:dataItem] &&  maxCount >1) {
        if (([self.selectedItemArray count] >= maxCount)) {
            NSString *maxString = NSLocalizedString(@"超过最大选中个数", nil);
            NSString *tips = [NSString stringWithFormat:@"%@:%ld", maxString, maxCount];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:tips tapTarget:self action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }
    
    WSDropListCollectionViewCell *cell = (WSDropListCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL isSelected = [cell getItemSelected];
    if (isSelected) {
        [self.selectedItemArray removeObject:dataItem];
        isSelected = NO;
    }else{
        if (maxCount ==1) {
            if (self.selectedItemArray.count > 0) {
                NSInteger index = [self.dataSourceArray indexOfObject:[self.selectedItemArray firstObject]];
                NSIndexPath *oriIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                WSDropListCollectionViewCell *cell = (WSDropListCollectionViewCell *)[collectionView cellForItemAtIndexPath:oriIndexPath];
                [cell setItemSelected:NO];
            }
            [self.selectedItemArray removeAllObjects];
            [self.selectedItemArray addObject:dataItem];
            isSelected = YES;
        }else if (![self.selectedItemArray containsObject:dataItem]) {
            [self.selectedItemArray addObject:dataItem];
            isSelected = YES;
        } else {
            [self.selectedItemArray removeObject:dataItem];
        }
    }
    
    [cell setItemSelected:isSelected];
    if (self.dropListDelegate &&
        [self.dropListDelegate respondsToSelector:@selector(dropListViewDidChangeSelect:)])  {
        [self.dropListDelegate performSelector:@selector(dropListViewDidChangeSelect:) withObject:self];
    }
    
    self.isValueChange = YES;
}


@end
