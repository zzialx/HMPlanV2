//
//  WSWorkbenchCollectionViewCell.h
//  WinSFA
//
//  Created by yang on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSWorkbenchCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WSFuncsBean *funcsBean;
- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean visitActionStatus:(VisitActionStatus)visitActionStatus badgeCount:(NSInteger)badgeCount;

@property (nonatomic, assign) BOOL isGrid;//蒙牛首页新样式

@end
