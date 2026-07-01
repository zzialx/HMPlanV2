//
//  WSWorkFlowCell.h
//  WinSFA
//
//  Created by yang on 15/11/10.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseTableViewCell.h"

#define WORKFLOW_CELL_DEFAULT_HEIGHT (INTERFACE_IS_PAD ? 55.0f : 52.0f)

@interface WSWorkFlowTableViewCell : WSBaseTableViewCell

@property (nonatomic, assign) CGFloat funcImageWidth; //default is 36
@property (nonatomic, assign) CGFloat cellHeight; //default is WORKFLOW_CELL_DEFAULT_HEIGHT

- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean
                       store:(WSStoreBean *)store
           visitActionStatus:(VisitActionStatus)visitActionStatus
                      action:(WSVisitStoreActionObject *)action
                     hasTips:(BOOL)hasTips
                  badgeCount:(NSInteger)badgeCount
                   indexPath:(NSIndexPath *)indexPath
                  totalCount:(NSInteger)totalCount;

@end
