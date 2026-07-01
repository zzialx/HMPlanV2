//
//  WSInsetLabel.h
//  WinSFA
//
//  Created by Leo Wen on 2017/4/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSInsetLabel : UILabel
@property (nonatomic)UIEdgeInsets insets;

-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets;
-(id) initWithInsets: (UIEdgeInsets) insets;

@end
