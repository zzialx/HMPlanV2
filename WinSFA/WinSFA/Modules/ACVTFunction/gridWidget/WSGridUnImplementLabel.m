//
//  WSGridUnImplementLabel.m
//  WinSFA
//
//  Created by Alicia on 2018/10/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridUnImplementLabel.h"

@interface WSGridUnImplementLabel()

@property (nonatomic, strong) UILabel *label;

@end

@implementation WSGridUnImplementLabel

- (void)setupView {
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.label.text = @"暂未实现";
}

- (UIView *)getView {
    return self.label;
}

@end
