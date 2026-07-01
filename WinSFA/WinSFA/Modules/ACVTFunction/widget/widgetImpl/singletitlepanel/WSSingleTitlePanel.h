//
//  WSSingleTitlePanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBasePanel.h"

@interface WSSingleTitlePanel : WSBasePanel

@property (nonatomic, assign) BOOL isTitleFold;

- (void)resetTitle:(NSString *)titlecontent;
- (void)setTitle:(NSString *)title;
- (NSString *)getTitle;
- (void)setTitleFoldEnable:(BOOL)isEnable;
- (CGFloat)getFoldedContentHeight;

@end
