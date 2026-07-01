//
//  WSANActivityHeadView.h
//  WinSFA
//
//  Created by zzialx on 2025/5/12.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSANActivityModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^deleteActivityItemBlock)(void);

typedef void(^expandActivityBlock)(BOOL isSelect);


@interface WSANActivityHeadView : UITableViewHeaderFooterView

@property (strong, nonatomic) UIImageView *headImageView;

@property (strong, nonatomic)  UIButton *deleteBtn;

@property (strong, nonatomic)  UILabel *titleLab;

@property (strong, nonatomic)  UIButton *expandBtn;

@property (strong, nonatomic)  UIView *lineView;

@property (strong, nonatomic) WSANActivityModel * headModel;


- (void)deleteActivityItemBlock:(deleteActivityItemBlock)block;

- (void)expandActivityBlock:(expandActivityBlock)block;


@end

NS_ASSUME_NONNULL_END
