//
//  WSAlertView.h
//  WinSFA
//
//  Created by heju on 15/5/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WSMsgsBean_msg.h"
#import "WSMsgsBean.h"

@interface  WSMsgAlertView : UIView

- (id)initWithFrame:(CGRect)frame msgBean:(WSMsgsBean_msg *)msg;
    
@end
