//
//  UIButton+EnlagerTouchPoint.h
//  WinSFA
//
//  Created by admin on 2022/10/29.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSImagePositionType) {
    SSImagePositionTypeLeft,   //图片在左，标题在右，默认风格
    SSImagePositionTypeRight,  //图片在右，标题在左
    SSImagePositionTypeTop,    //图片在上，标题在下
    SSImagePositionTypeBottom  //图片在下，标题在上
};

typedef NS_ENUM(NSInteger, SSEdgeInsetsType) {
    SSEdgeInsetsTypeTitle,//标题
    SSEdgeInsetsTypeImage//图片
};

typedef NS_ENUM(NSInteger, SSMarginType) {
    SSMarginTypeTop         ,
    SSMarginTypeBottom      ,
    SSMarginTypeLeft        ,
    SSMarginTypeRight       ,
    SSMarginTypeTopLeft     ,
    SSMarginTypeTopRight    ,
    SSMarginTypeBottomLeft  ,
    SSMarginTypeBottomRight
};

@interface UIButton (EnlagerTouchPoint)

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

/**
 *  图片在右，标题在左
 *
 *  @param spacing image 和 title 之间的间隙
 */
- (void)setImageRightTitleLeftWithSpacing:(CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
