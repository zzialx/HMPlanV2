//
//  LEOAssistiveWindow.h
//  AssistiveTouch
//
//  Created by liuwenjie on 15/10/24.
//  Copyright © 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOAssistiveWindowMainItem.h"
@class LEOAssistiveWindow;

#define kDragWindowHeight 80
#define kDragMainItemWidth 45
//===========================================================================================================================================

@protocol LEOAssistiveWindowDelegate <NSObject>

@optional
- (void)assistiveWindowMainButtonEvent:(LEOAssistiveWindow *)window; //主按钮点击协议

@end
//===========================================================================================================================================

@interface LEOAssistiveWindow : UIWindow

@property (nonatomic, weak) id <LEOAssistiveWindowDelegate>assistiveDelegate;   //代理指针
@property (nonatomic, strong) LEOAssistiveWindowMainItem *mainButton;           //主按键

@end
//===========================================================================================================================================

