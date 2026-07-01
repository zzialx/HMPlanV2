//
//  WSFuncTipsTableViewCell.h
//  TestDemo
//
//  Created by xq的电脑 on 2023/12/3.
//

#import <UIKit/UIKit.h>
//===================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 菜单提醒单元格
@interface WSFuncTipsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *funcNameLab; //名称标题
@property (nonatomic, strong) UILabel *passLab;     //通过标签
@property (nonatomic, strong) UILabel *refuseLab;   //拒绝标签
@property (nonatomic, strong) UIView *line;         //分割线

@end

NS_ASSUME_NONNULL_END
//===================================================================================================================
