//
//  WinStockOutTableViewCell.h
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSInventoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WinStockOutTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *productNameLabel;

@property (nonatomic, strong) UILabel *quantityLabel;

- (void)configureWithItem:(WSStockOutModel *)item;

@end

NS_ASSUME_NONNULL_END
