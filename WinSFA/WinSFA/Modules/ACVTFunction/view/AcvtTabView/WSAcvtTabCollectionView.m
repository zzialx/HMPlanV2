//
//  WSAcvtTabCollectionView.m
//  WinSFA
//
//  Created by Alicia on 2018/1/25.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtTabCollectionView.h"
#import "WSAcvtTabCell.h"
#import "WSAcvtTabButtonCell.h"

static const CGFloat kButtonLineSpacing = 2;

static NSString * const kAcvtTabCellIdentifier = @"AcvtTabCell";

@interface WSAcvtTabCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) WSAcvtTabStyle style;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, weak) WSAcvtTabCell *seletedCell;

@end

@implementation WSAcvtTabCollectionView


- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray style:(WSAcvtTabStyle)style {
    UICollectionViewFlowLayout *layout = [self createLayoutWithStyle:style];
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.columns = 3;
        self.cellHeight = MAIN_CELL_HEIGHT;
        self.titleArray = titleArray;

        self.style = style;
        
        self.delegate = self;
        self.dataSource = self;

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self setAttributeWithStyle:style];

    }
    return self;
}

- (UICollectionViewFlowLayout *)createLayoutWithStyle:(WSAcvtTabStyle)style {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (style == WSAcvtTabStyleButton) {
        layout.minimumLineSpacing = kButtonLineSpacing;
        layout.minimumInteritemSpacing = 1;
    } else {
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
    }
    return layout;
}

- (void)setAttributeWithStyle:(WSAcvtTabStyle)style {
    if ([_titleArray count] == 0) {
        return;
    }
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    if (style == WSAcvtTabStyleButton) {
        self.cellHeight = 30;

        UIColor *bgColor = [UIColor colorForKey:@"AcvtTabViewTitleBackgroundColor"];
        if (bgColor) {
            [self setBackgroundColor:bgColor];
        }

        NSInteger rows = [_titleArray count] / self.columns;
        CGRect frame = self.frame;
        CGFloat height = rows * self.cellHeight + kButtonLineSpacing * (rows - 1);
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
        
        
        [self registerClass:[WSAcvtTabButtonCell class] forCellWithReuseIdentifier:kAcvtTabCellIdentifier];

    } else if (style == WSAcvtTabStyleSide) {
        self.columns = 1;
        
        
        [self registerClass:[WSAcvtTabCell class] forCellWithReuseIdentifier:kAcvtTabCellIdentifier];
    }
}

#pragma mark - Public Method
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    if (self.selectedAcvtTabBlock) {
        self.selectedAcvtTabBlock(selectedIndex, self.style);
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
      return CGSizeMake((self.width - MAIN_TEXT_IMG_PADDING * (self.columns - 1)) / self.columns, self.cellHeight);
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSAcvtTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAcvtTabCellIdentifier forIndexPath:indexPath];

    [cell setTitle:self.titleArray[indexPath.row]];
    
    return cell;
}

#pragma mark - Collection Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WSAcvtTabCell *cell =  (WSAcvtTabCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.seletedCell == cell) {
        return;
    }
    [cell setSelected:YES];
    
    [self.seletedCell setSelected:NO];
    self.seletedCell = cell;
    
    if (self.selectedAcvtTabBlock) {
        self.selectedAcvtTabBlock(indexPath.row, self.style);
    }
}



@end
