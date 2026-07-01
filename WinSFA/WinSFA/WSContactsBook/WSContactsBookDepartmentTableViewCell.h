//
//  WSContactsBookDepartmentTableViewCell.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSContactsBookServiceDataModel.h"
//===================================================================================================================================================================

#pragma mark - 通讯录部门表视图单元格
@interface WSContactsBookDepartmentTableViewCell : UITableViewCell

#pragma mark - 设置单元格数据方法 infoData:数据源 isHiddenLine:是否隐藏线标示
- (void)setCellWithData:(WSContactsStandardInfo *)infoData isHiddenLine:(BOOL)isHiddenLine;

#pragma mark - 获取单元格高度方法
+ (CGFloat)getCellHeight;

@end
//===================================================================================================================================================================
