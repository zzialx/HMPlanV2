//
//  WSTextViewPanel.h
//  WinSFA
//
//  Created by Stephanie on 16/6/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
@class WSValidateTextView;
//=======================================================================================================================================

@interface WSTextViewPanel : WSSingleTitlePanel

@property (nonatomic,retain) WSValidateTextView *textView;

- (void)textChange;
- (void)setTextColorStrByHex:(NSString *)colorStr;

@end
//=======================================================================================================================================
