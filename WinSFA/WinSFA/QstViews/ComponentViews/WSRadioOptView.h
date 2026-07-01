//
//  WSRadioButton.h
//  WinSFA
//
//  Created by zhangke on 15/2/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSRadioOptView : UIView

@property (nonatomic,weak) IBOutlet UILabel* optLabel;
@property (nonatomic,weak) IBOutlet UIButton* button;

- (id)initWithFrame:(CGRect)frame optName:(NSString*)optName tag:(NSInteger)tag;


@end
