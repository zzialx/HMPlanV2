//
//  WSMultiSelectDropListPanel.h
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDropListPanel.h"
@class WSMultiSelectDropListPanel;

@interface WSMultiSelectDropListPanel : WSBaseDropListPanel<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,assign) CGRect oldRect;

@property(nonatomic,strong)UITableView * tableView;


@end
