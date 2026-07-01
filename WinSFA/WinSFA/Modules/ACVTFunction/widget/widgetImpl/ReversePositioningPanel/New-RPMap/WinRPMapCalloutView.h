//
//  WinRPMapCalloutView.h
//  WinSFA
//
//  Created by yuanji on 2019/9/30.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//=================================================================================================================================

#pragma mark - RP地图用户标注视图
@interface WinRPMapCalloutView : UIView

@property (nonatomic, strong) UILabel *titleLabel;      //标题标签
@property (nonatomic, strong) UILabel *subtitleLabel;   //子标题标签

+ (CGSize)getCalloutViewSizeWithTitle:(NSString *)title subtitle:(NSString *)subtitle maxWidth:(CGFloat)maxWidth;   //获取标注视图尺寸方法
- (void)setCalloutViewWithTitle:(NSString *)title subtitle:(NSString *)subtitle;                                    //设置标注视图方法

@end
//=================================================================================================================================

