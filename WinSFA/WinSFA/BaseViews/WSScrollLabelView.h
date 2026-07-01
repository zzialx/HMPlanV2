//
//  WSScrollLabelView.h
//  WinSFA
//
//  Created by Alicia on 2017/11/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSScrollLabelView : UIView


// Scroll speed, default is 30
@property (nonatomic, assign) CGFloat scrollSpeed;
// default is Center
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, copy) NSString *text;

@end
