//
//  WSMapSubTrailView.h
//  WinSFA
//
//  Created by wanghaipeng on 2019/4/8.
//  Copyright © 2019年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSMapSubTrailViewDelegate <NSObject>

@required

-(void)didSelectDate:(NSString *)biz_date;

@end

@interface WSMapSubTrailView : UIView

@property (nonatomic, weak) id<WSMapSubTrailViewDelegate> delegate;

@end
