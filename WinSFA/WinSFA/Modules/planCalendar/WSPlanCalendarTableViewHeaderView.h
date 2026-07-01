//
//  WSPlanCalendarTableViewHeaderView.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^jumpAttendanceVC)(void);

@interface WSPlanCalendarTableViewHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIButton *setAttendanceBtn;
@property (nonatomic, copy) jumpAttendanceVC jumpAttendanceVC;

- (void)setWithTitle:(NSString *)title;
- (void)setAttendanceWithIsValidState:(BOOL)isValidState;

@end

NS_ASSUME_NONNULL_END
