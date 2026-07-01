//
//  WSStartEndDatePanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "WSSingleTitlePanel.h"
#import "WSAcvtQstBottomLineView.h"

@class WCStartEndDateView;


@interface WSStartEndDatePanel : WSSingleTitlePanel {
    
    WCStartEndDateView *wcSedView;
    
    UIButton  *selectedBtn;
    
    UIView *viewBGPicker;
}

@end
