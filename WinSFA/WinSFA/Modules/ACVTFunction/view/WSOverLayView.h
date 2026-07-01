//
//  WSOverLayView.h
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSOverLayView;

@protocol WSOverLayViewDelegate <NSObject>

-(UIView *)overLayView:(WSOverLayView *)view didHitPoint:(CGPoint)didHitPoint withEvent:(UIEvent *)withEvent;

@end

@interface WSOverLayView : UIView

@property (nonatomic, weak) id<WSOverLayViewDelegate>delegate;

@end
