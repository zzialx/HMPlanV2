//
//  WSPersonnelListTreeController.h
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
#import "WSPersonnelListTreeView.h"

@interface WSPersonnelListTreeController : SuperWorkSpaceViewController<WSPersonnelListTreeViewDelegate>

@property (nonatomic ,strong) NSMutableArray *dataArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
