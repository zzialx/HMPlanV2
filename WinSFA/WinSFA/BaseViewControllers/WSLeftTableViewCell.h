//
//  WSLeftTableViewCell.h
//  WinSFA
//
//  Created by yang on 14-4-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSFuncsBean;

@interface WSLeftTableViewCell : UITableViewCell

@property (nonatomic, strong) WSFuncsBean *funcsBean;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *eventCountLabel;

@property (nonatomic, strong) UILabel *ValueChangedLabel;


- (void)setData:(WSFuncsBean *)funcsBean;

- (void)setEventIdentifer:(NSString *)identifer;

- (void)setValueChanged:(BOOL)changed;



@end
