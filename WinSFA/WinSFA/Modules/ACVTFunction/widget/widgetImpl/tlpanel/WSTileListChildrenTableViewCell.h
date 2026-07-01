//
//  WSTileListChildrenTableViewCell.h
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "I_W_OptionDataItem.h"

#import "I_W_Children_DataSource.h"

#import "WSOrgBean.h"

@protocol WSTileListChildrenTableCellDelegate;


@interface WSTileListChildrenTableViewCell : UITableViewCell

@property (nonatomic,weak)id <WSTileListChildrenTableCellDelegate> cellDelegate;

@property (nonatomic,assign) NSInteger tableViewTag;

@property (nonatomic,assign) NSInteger allLevelsChildren;

- (void)setObject:(WSOrgBean<I_W_OptionDataItem,I_W_Children_DataSource> *)orgBean;

@end
@protocol WSTileListChildrenTableCellDelegate <NSObject>

- (void)tableViewCell:(WSTileListChildrenTableViewCell *)cell didSelectOrgBean:(WSOrgBean *)orgBean  tag:(NSInteger)tableTag;

@end