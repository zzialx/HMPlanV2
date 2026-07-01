//
//  WSTAAcvtDataGridViewPanel.h
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

#import "WSTAAcvtDataGridComponentDataSource.h"

#import "DataGridComponent.h"

@interface WSTAAcvtDataGridViewPanel : WSWidget <WSTAAcvtDataGridComponetDataSourceDelegate>

@property (nonatomic, strong) DataGridComponent *dataGridView;

@end
