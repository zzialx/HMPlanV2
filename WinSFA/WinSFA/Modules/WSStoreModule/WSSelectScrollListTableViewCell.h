//
//  WSSelectScrollListTableViewCell.h
//  WinSFA
//
//  Created by wangzhiwei on 2018/9/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSelectListNewTableviewCell.h"
@interface WSSelectScrollListTableViewCell : WSSelectListNewTableviewCell

//获取文本的宽
- (CGFloat)getTextWidthRatio;
//门店地址的宽度
-(CGFloat)getStoreAddressLabelWidthIsHaveVisitState:(BOOL)isHaveVisitState presentStoreAddressLabelWidth:(CGFloat)presentStoreAddressLabelWidth;

@end
