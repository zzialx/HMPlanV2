//
//  WSTipView.h
//  WinSFA
//
//  Created by macbook  on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTipView : UIView
-(instancetype)initWithFrame:(CGRect)frame image: (UIImage *)image tip: (NSString *)tip;
+(CGSize)getTipViewFrame: (NSString *)qstTip iconImage: (UIImage *)iconImage;
@end
