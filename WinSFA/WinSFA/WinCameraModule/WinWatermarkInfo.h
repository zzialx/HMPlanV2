//
//  WinWatermarkInfo.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 水印信息
@interface WinWatermarkInfo : NSObject

@property (nonatomic, copy) NSString *tilteInfo;    //标题信息
@property (nonatomic, assign) CGFloat tilteFontSize;//标题字体尺寸
@property (nonatomic, strong) UIImage *iconImage;   //图标视图

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
