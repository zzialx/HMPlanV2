//
//  WSTopBannerCycleScrollView.h
//  WinSFA
//
//  Created by HZH on 17/1/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMsgsBean_msg;
@class WSTopBannerCycleScrollView;

@protocol WSTopBannerCycleScrollViewDelegate <NSObject>

@optional
- (void)topBannerCycleScrollView:(WSTopBannerCycleScrollView *)topBanner didSlectItem:(WSMsgsBean_msg *)msgBean;
@end
@interface WSTopBannerCycleScrollView : UIView
@property (nonatomic, weak)id<WSTopBannerCycleScrollViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withUseTitle:(BOOL)useTitle;

@end
