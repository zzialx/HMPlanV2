//
//  WSShowPhotoPannel.h
//  WinSFA
//
//  Created by heju on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"

#import "WSWidget.h"

@class WSPhotoBrowseView;

@interface WSShowPhotoPannel : WSSingleTitlePanel

@property (nonatomic, strong) WSPhotoBrowseView *photoView;
@end
