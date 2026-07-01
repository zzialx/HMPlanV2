//
//  WSTextFiledPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "WSSingleTitlePanel.h"
@class WSHTextField;
@protocol WSHTextFieldDelegate;

@interface WSTextFiledPanel : WSSingleTitlePanel<WSHTextFieldDelegate> {
    
    WSHTextField *textField;
}

@property (nonatomic,retain) WSHTextField* textField;
@property (nonatomic, assign) BOOL isNeedResetTitleTextFieldFrame;

- (void)setTextFieldAlignment;
- (void)resetTitleTextFieldFrame;
- (BOOL)getOrientiton;
- (void)runScript;

@end
