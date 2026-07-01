//
//  WSPopMenuCell.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDictBean.h"
@interface WSPopMenuCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, strong) UIColor * separatorColor;
@property (nonatomic, strong) WSDictBean *dictBean;
@end
