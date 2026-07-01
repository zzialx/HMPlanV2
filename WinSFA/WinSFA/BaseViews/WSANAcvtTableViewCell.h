//
//  WSANAcvtTableViewCell.h
//  WinSFA
//
//  Created by zhangmin on 2018/12/13.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSANAcvtTableViewCellDelegate;

@interface WSANAcvtTableViewCell : UITableViewCell
@property (nonatomic, strong) WSAcvtBean *nestedAcvtBean;
@property (nonatomic, weak) id <WSANAcvtTableViewCellDelegate> delegate;//代理指针
@property (nonatomic, strong) UIView *containerView; //容器
@property (nonatomic, strong) UIButton *deleteButton; //删除按钮

@end



#pragma mark - 子任务问卷视图单元格代理指针
@protocol WSANAcvtTableViewCellDelegate <NSObject>

- (void)anAcvtTableViewCellDidDeleteButton:(WSANAcvtTableViewCell *)tableViewCell index:(NSInteger)index;   //删除按键点击响应

@end
