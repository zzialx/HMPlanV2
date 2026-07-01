//
//  WSMessageForiPadCell.h
//  WinSFA
//
//  Created by winchannel on 2018/3/21.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"
#import "WSMsgsBean.h"
@interface WSMessageForiPadCell : UITableViewCell
// 原项目传入的数据模型
@property(nonatomic,strong) WSMsgsBean_msg * MsgsBean_msg;
// 区分信息分类 的信息
@property(nonatomic,strong) NSMutableArray * msgBean;
@property(nonatomic,assign) CGFloat backGroundViewHeight;
@property(nonatomic,strong) UILabel *titleLabel;
// 通过一个tableView 去缓存里面取cell
+(instancetype)cellWithTableView:(UITableView * )tableView;
+(float)cellHeightForRow:(WSMsgsBean_msg *)msg with:(CGFloat)width;
@end
