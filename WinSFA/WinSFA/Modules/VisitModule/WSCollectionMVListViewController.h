//
//  WSCollectionMVListViewController.h
//  WinSFA
//
//  Created by Alicia on 17/1/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "SuperBarViewController.h"

@interface WSCollectionMVListViewController : SuperBarViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@property (nonatomic ,strong) WSFuncsBean *currentFuncs;

@property (nonatomic ,strong) UICollectionView *mvListCollectionView;

- (void)reloadView;

@end
