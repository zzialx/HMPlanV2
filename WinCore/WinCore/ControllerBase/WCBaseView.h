//
//  WCBaseView.h
//  Quad
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <UIKit/UIKit.h>
//TODO:换肤模块PKResManager不符合需求，未来需要重构这一部分
//#import "PKResManager.h"
/**
 * 所有View的基类，遵循换肤协议，所有集成它的View都能集成换皮肤的接口
 */
@interface WCBaseView : UIView //<PKResChangeStyleDelegate>

@end
