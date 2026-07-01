//
//  WSTableView.h
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "I_CommonFunction.h"
#import "WSStoreTableViewCell.h"



@interface WSBaseTableView : WSWidget<UITableViewDataSource,UITableViewDelegate,I_CommonFunction,WSStoreTableViewCellDelegate>{
    
    
    UITableView   *table_view;
    
    
    NSMutableArray  *table_data;
    
    
    BOOL hiddendetail;
}
@property (nonatomic,strong) NSMutableArray  *table_data;
@property (nonatomic,assign) BOOL hiddendetail;
@property (nonatomic, strong) NSArray *shortCutArray;



@end
