//
//  WSPITableViewBGScrollView.h
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSPITableView.h"

@interface WSPITableViewBGScrollView : UIScrollView

@property (nonatomic, strong) WSPITableView *parent;

- (void)reDraw;

@end
