//
//  WSStoreFollowUpHeaderFooterView.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSStoreFollowUpHeaderFooterView : UITableViewHeaderFooterView
- (void)setWithPlanNum:(NSInteger)planNum endNum:(NSInteger)endNum noFollowUpNum:(NSInteger)noFollowUpNum;
@end

NS_ASSUME_NONNULL_END
