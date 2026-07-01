//
//  WinCameraWatermarkView.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinWatermarkInfo.h"
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 相机水印视图
@interface WinCameraWatermarkView : UIView

- (void)setTopCustomizeWatermarkWithInfoArray:(NSArray<WinWatermarkInfo *> *)infoArray isShrink:(BOOL)isShrink;     //设置顶部水印方法
- (void)setBottomCustomizeWatermarkWithInfoArray:(NSArray<WinWatermarkInfo *> *)infoArray isShrink:(BOOL)isShrink;  //设置底部水印方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
