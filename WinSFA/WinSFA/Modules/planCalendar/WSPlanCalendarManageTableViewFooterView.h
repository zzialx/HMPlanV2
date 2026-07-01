//
//  WSPlanCalendarManageTableViewFooterView.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WSPlanCalendarManageTableViewFooterViewDelegate <NSObject>

- (void)btnDownDelegate:(NSString *)strDS;

@end
@interface WSPlanCalendarManageTableViewFooterView : UITableViewHeaderFooterView
@property (nonatomic, weak) id<WSPlanCalendarManageTableViewFooterViewDelegate> planCalendarTableViewFooterViewDelegate;
@property (nonatomic, copy) NSString *strDS;
@end

NS_ASSUME_NONNULL_END
