//
//  WSStoreManageViewCell.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSStoreManageDataInfoModel;
//========================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@protocol WSStoreManageViewCellDelegate <NSObject>

- (void)btnDownStoreManageViewCell:(NSInteger)btnTag andModel:(WSStoreManageDataInfoModel*)model;

@end

@interface WSStoreManageViewCell : UITableViewCell

@property (nonatomic, strong) WSStoreManageDataInfoModel *model;
@property (nonatomic, weak) id<WSStoreManageViewCellDelegate> storeManageViewCellDelegate;

+ (CGFloat)getStoreManageViewCellHeightWithModel:(WSStoreManageDataInfoModel *)model maxWidth:(CGFloat)maxWidth; //获取高度方法

@end

NS_ASSUME_NONNULL_END
//========================================================================================================================================================================
