//
//  WSDownloadDataProgressView.h
//  WinSFA
//
//  Created by zhangmin on 2018/8/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSDownloadDataProgressView : UIView
@property(nonatomic,assign)NSInteger progress;

- (instancetype)initWithSelect:(NSInteger )allNumber;
- (void)showDownListAlertView;
- (void)closeListProgress;
@end
