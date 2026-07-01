//
//  WSMonthCalenderPanel.h
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "WSYearCalenderBottomScrollView.h"
#import "WSMonthCollectionViewCellModel.h"

#import "WSDutyBeanArray.h"


@protocol WSMonthCalenderPanelDelegate;

@interface WSMonthCalenderPanel : WSWidget <UICollectionViewDelegate,UICollectionViewDataSource,WSYearCalenderBottomScrollViewDelegate>


@property(nonatomic ,strong) UICollectionView* collectionView;//网格视图
@property(nonatomic ,strong) NSMutableArray *months; //  数据源
@property(nonatomic, strong) WSFuncsBean *currentFuncs;

-(id)initWithFrame:(CGRect)frame   funcs:(WSFuncsBean *)funcs;

- (void)relodDataWith:(NSMutableArray *)tmpMonths;

- (void)reloadCollectionView;

@end


