//
//  RevertTableViewCell.h
//  demo
//
//  Created by admin on 15/10/26.
//  Copyright © 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTitleHeight    20

@class RevertArrayModel;
@class WSFuncsBean;
@interface WSRevertTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel * userName;

@property(nonatomic,strong) UILabel * timeLable;

@property(nonatomic,strong) UILabel * detalLabel;
// 添加分割线
@property(nonatomic,strong)UILabel * separatorline;
// demo 数据模型
 @property(nonatomic,strong) RevertArrayModel * model;

// 原项目传入的数据模型
@property(nonatomic,strong) WSFuncsBean * funsModel;

// 通过一个tableView 去缓存里面取cell
+(instancetype)cellWithTableView:(UITableView * )tableView;

@end
