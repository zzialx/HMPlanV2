//
//  WSMapBottomInfoView.h
//  WinSFA
//
//  Created by yang on 16/11/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMapBottomInfoView : UIView


- (void)setStore:(WSStoreBean *)storeBean;

+ (CGFloat)heightForStore:(WSStoreBean *)store width:(CGFloat)width;

@end
