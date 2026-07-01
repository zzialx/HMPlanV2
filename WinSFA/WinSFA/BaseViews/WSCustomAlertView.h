//
//  WSCustomAlertView.h
//  WinSFA
//
//  Created by lishuli on 2018/10/30.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectButtonBlock)(UIButton *button,NSInteger tag);

@interface WSCustomAlertView : UIView

@property (nonatomic, strong) NSMutableArray *buttonsTitle;
@property (nonatomic, copy) SelectButtonBlock selectButtonBlock;

-(instancetype)initWithFrame:(CGRect)frame buttonsTitle:(NSArray *)buttonsTitle message:(NSString *)message;
- (void)updateAlertViewWithButtonsTitle:(NSMutableArray *)buttonsTitle message:(NSString *)message;
@end
