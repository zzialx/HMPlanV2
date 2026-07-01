//
//  WSLeftBottomButton.h
//  WinSFA
//
//  Created by Stephanie on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMainBottomCellHeight 40
#define kMainBottomCellWidth 170


@interface WSLeftBottomButton : UIControl

@property (nonatomic, strong, readonly) WSFuncsBean *funcsBean;
@property (nonatomic , assign) BOOL isBottomButton;  // 是不是底部的按钮

- (instancetype)initWithFrame:(CGRect)frame funcsBean:(WSFuncsBean *)funcsBean;

- (void)setEventIdentifer:(NSString *)identifer;

@end
