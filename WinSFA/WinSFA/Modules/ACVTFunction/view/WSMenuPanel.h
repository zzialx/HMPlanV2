//
//  WSMenuPanel.h
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSMenuPanel;

@protocol WSMenuPanelDelegate <NSObject>

- (void)ChooseMenuIndex:(NSInteger )menuIdexNum;

@end

@interface WSMenuPanel : UIView

@property (nonatomic, weak)   id<WSMenuPanelDelegate>delegate;

- (void)addMenuPanelData:(NSArray *)array;

@end
