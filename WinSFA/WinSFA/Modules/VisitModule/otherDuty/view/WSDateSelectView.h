//
//  WSDateSelectView.h
//  WinSFA
//
//  Created by yang on 16/11/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSDateSelectView : UIView

@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title date:(NSDate *)date;

- (NSString *)getDateString;

@end
