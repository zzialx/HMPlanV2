//
//  WSTypeMsgTableViewCell.h
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean.h"
#import "XMBadgeView.h"


@interface WSTypeMsgTableViewCell : UITableViewCell
@property (nonatomic, strong) WSMsgsBean *msgBean;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) XMBadgeView *badgeView;

@end
