//
//  WSAcvtSideView.h
//  WinSFA
//
//  Created by Alicia on 2018/1/29.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAcvtSideView : UIView

- (instancetype)initWithFrame:(CGRect)frame subView:(UIView *)subView title:(NSString *)title;
- (void)showOrHideWithAnimation;

@end
