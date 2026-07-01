//
//  WSProductCell.h
//  WinSFA
//
//  Created by yang on 16/1/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSProductCell : UITableViewCell

@property (nonatomic, assign) BOOL isNeedSelect;  //Default is YES

@property (nonatomic, assign) BOOL isCellSelected;

- (void)setContent:(NSString *)content isSelect:(BOOL) isSelect;

+ (CGFloat)heightForRowWithContent:(NSString *)content tableWidth:(CGFloat)tableWidth isNeedSelect:(BOOL)isNeedSelect;

@end
