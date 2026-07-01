//
//  WSAllStoreProgressView.h
//  WinSFA
//
//  Created by donghong on 2018/5/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAllStoreProgressView : UIView
@property(nonatomic,assign)NSInteger progress;

- (instancetype)initWithSelect:(NSInteger )allNumber;
- (void)showXLAlertView;

@end
