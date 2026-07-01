//
//  WSTreeListViewController.h
//  WinSFA
//
//  Created by Alicia on 2018/3/5.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPersonnelListTreeView.h"

typedef void (^WSTreeListSelectBlock)(NSMutableArray *selectArray);
typedef void (^WSTreeListDoneBlock)();

@interface WSTreeListViewController : BaseViewController

@property (nonatomic, weak) NSMutableArray *selectedArray;
@property (nonatomic, strong) WSPersonnelListTreeView *treeListView;
@property (nonatomic, copy) WSTreeListSelectBlock selectBlock;
@property (nonatomic, copy) WSTreeListDoneBlock doneBlock;

@end
