//
//  WSQRModule.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"

typedef void(^JFUpdateScanTextBlock)(NSString* textStr);    //将扫描结果返回
typedef void (^JFUpdateScanImageBlock)(UIImage *img);       //更新扫描图片

@interface WSQRModule : NSObject<ZBarReaderDelegate>
{
}

@property(nonatomic, copy) JFUpdateScanTextBlock   scanTextBlock;
@property(nonatomic, copy) JFUpdateScanImageBlock  scanImgBlock;

@property (nonatomic, strong) NSString *codeType;

+ (WSQRModule*) getInstance;

-(void) showQRViewControllerToViewController:(UIViewController*)parentViewController
                            WithScanTxtBlock:(JFUpdateScanTextBlock)txtBlock
                            withScanImgBlock:(JFUpdateScanImageBlock)imgBlock;

/**
 *  将字符串转换成二维码
 *
 *  @param string 需要转换的字符串
 *  @param size   生成的图片宽度（正方形）
 *
 *  @return 二维码图片
 */
- (UIImage *)generatQRImageForString:(NSString *)string imageSize:(CGFloat)size;

@end
