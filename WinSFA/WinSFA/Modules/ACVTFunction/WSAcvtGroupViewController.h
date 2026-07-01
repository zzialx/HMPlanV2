//
//  WSAcvtGroupViewController.h
//  WinSFA
//
//  Created by Alicia on 2018/2/2.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSAcvtBean;

@interface WSAcvtGroupViewController : UIViewController

- (instancetype)initWithGroupNameArray:(NSArray *)groupNameArray acvtViewArray:(NSArray *)acvtViewArray;

- (void)resetGroupNameArray:(NSArray *)groupNameArray acvtViewArray:(NSArray *)acvtViewArray;

- (void)setHeaderView:(UIView *)headerView;

@end
