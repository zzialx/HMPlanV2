//
//  WSStoreFollowUpTableViewCell.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreFollowUpDataModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol WSStoreFollowUpTableViewCellDelegate <NSObject>

- (void)btnDownFollowUpDelegate:(NSIndexPath*)IndexPath;

- (void)btnDownCancelFollowUpDelegate:(NSIndexPath*)IndexPath;


@end

@interface WSStoreFollowUpTableViewCell : UITableViewCell
@property(nonatomic,strong) WSStoreFollowUpInfoDataModel *model;
@property(nonatomic,weak) id <WSStoreFollowUpTableViewCellDelegate> followUpTableViewCellDelegate;
@property(nonatomic,strong) NSIndexPath* indexPath;

@end

NS_ASSUME_NONNULL_END
