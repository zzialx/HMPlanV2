//
//  FUICheckBox.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FCheckBoxBlock)(BOOL isSelected);

@interface FUICheckBox : UIView

- (id)initWithFrame:(CGRect)frame
          withTitle:(NSString*)title
          withBlock:(FCheckBoxBlock)block;

@end
