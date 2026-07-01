//
//  WSStoreManageViewHeaderView.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//============================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@protocol WSStoreManageViewHeaderViewDelegate <NSObject>

- (void)storeManageStatus:(NSInteger)status;
- (void)storeManageTimeStr:(NSString*)timeStr;
- (void)storeManageSearch:(WSAcvtBean*)acvtBean;

@end
//============================================================================================================================================

@interface WSStoreManageViewHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<WSStoreManageViewHeaderViewDelegate> iDelegate;

- (void)setupStatetWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
//============================================================================================================================================
