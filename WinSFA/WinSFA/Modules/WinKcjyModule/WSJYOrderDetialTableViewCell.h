//
//  WSJYOrderDetialTableViewCell.h
//  WinSFA
//
//  Created by zzialx on 2025/7/10.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSInventoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSJYOrderDetialTableViewCell : UITableViewCell


@property (nonatomic, strong) UILabel *storeCodeLabel;

@property (nonatomic, strong) UILabel *productNameLabel;

@property (nonatomic, strong) UILabel *quantityLabel;

@property (nonatomic, strong) UILabel *buyCountLabel;


- (void)configureWithItem:(WSInventoryModel *)item;

@end

NS_ASSUME_NONNULL_END
