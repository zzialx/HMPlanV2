//
//  WinRPMapTableViewCell.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WinRPMapPOI;
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RP地图表视图单元格
@interface WinRPMapTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *mainTitleLabel;      //主标题
@property (nonatomic, strong) UILabel *subTitleLabel;       //副标题
@property (nonatomic, strong) UILabel *distanceTitleLabel;  //距离标题
@property (nonatomic, strong) UIImageView *distanceImgView; //距离图标
@property (nonatomic, strong) UIImageView *selectImgView;   //选中图标

+ (CGFloat)getCellHeightWithTableView:(UITableView *)tableView data:(WinRPMapPOI *)data;//获取单元格高度方法
- (void)setCellData:(WinRPMapPOI *)data isSelectState:(BOOL)isSelectState;              //设置单元格数据方法

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================

