//
//  MyMessageCell.h
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellModel.h"
#import "WSMsgsBean_msg.h"
#import "WSMsgsBean.h"

#define IS_IPAD_NARGIN 166

@interface WSMyMessageCell : UITableViewCell <NSURLConnectionDataDelegate>

// 通过一个tableView 去缓存里面取cell
+(instancetype)cellWithTableView:(UITableView * )tableView;

// 原项目传入的数据模型
@property(nonatomic,strong) WSMsgsBean_msg * MsgsBean_msg;
// 区分信息分类 的信息
@property(nonatomic,strong) NSMutableArray * msgBean;

@property (nonatomic, strong) NSMutableData             *imageData;
@end
