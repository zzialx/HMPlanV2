//
//  WSDetailHeadView.h
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"
@interface WSDetailHeadView : UIView

@property(nonatomic,strong) NSMutableArray * msgBean;
@property(nonatomic,strong) WSMsgsBean_msg * model;

@end
