//
//  WSQRModule.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSQRModule.h"
#import "QRCodeGenerator.h"
#import <AVFoundation/AVFoundation.h>
#import "WSCameraAuthHelper.h"

@implementation WSQRModule

+ (WSQRModule*) getInstance
{
    static WSQRModule *instance = nil;
    @synchronized(self){
        if (instance == nil) {
            instance = [[WSQRModule alloc] init];
        }
        
        return instance;
    }
}

-(void) showQRViewControllerToViewController:(UIViewController*)parentViewController
                            WithScanTxtBlock:(JFUpdateScanTextBlock)txtBlock
                            withScanImgBlock:(JFUpdateScanImageBlock)imgBlock
{
    self.scanTextBlock = txtBlock;
    self.scanImgBlock = imgBlock;
    
    
    WSCameraAuthHelper *cameraHelper = [[WSCameraAuthHelper alloc] init];
    [cameraHelper authCameraWithBlock:^(BOOL isOK) {
        if (isOK) {
             [self showQRViewControllerToViewController:parentViewController];
        } else {
            self.scanTextBlock = nil;
            self.scanImgBlock = nil;
        }
    }];
}

- (void)showQRViewControllerToViewController:(UIViewController*)parentViewController
{
    
    CGFloat viewLeft =(SCREEN_WIDTH-320)/2;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(viewLeft, 0, 320, 420)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    
    if ([self.codeType isEqualToString:@"I"]) {
        label.text = @"请将扫描的条形码至于下面的框内\n谢谢！";
    }
    else{
        label.text = @"请将扫描的二维码至于下面的框内\n谢谢！";
    }
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    //初始话ZBar
    ZBarReaderViewController * reader = [ZBarReaderViewController new];
    //设置代理
    reader.readerDelegate = self;
    //支持界面旋转
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsHelpOnFail = NO;
    ZBarImageScanner * scanner = reader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    reader.cameraOverlayView = view;
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    image.frame = CGRectMake(20, 80, 280, 280);
    image.center = reader.view.center;
    [view addSubview:image];
    
    //扫描区域
    //    CGRect scanMaskRect = image.frame;
    //    reader.scanCrop = [self getScanCrop:scanMaskRect readerViewBounds:reader.view.bounds]; //CGRectMake(0.1, 0.2, 0.8, 0.8);//扫描的感应框
    //    NSLog(@"ssssssssss:%@", NSStringFromCGRect(reader.scanCrop));
    //
    //
    //    {
    //        UIView * V = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(reader.scanCrop)*1024, CGRectGetMinY(reader.scanCrop)*768, CGRectGetWidth(reader.scanCrop)*1024, CGRectGetHeight(reader.scanCrop)*768)];
    //        [V setBackgroundColor:[UIColor redColor]];
    //        [V setAlpha:0.3];
    //        [view addSubview:V];
    //    }
    
    [parentViewController presentViewController:reader animated:YES completion:^{
    }];
}

#pragma mark - @protocol UIImagePickerControllerDelegate<NSObject> method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.scanTextBlock) {
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        else
        {
            result = symbol.data;
        }
        
        self.scanTextBlock(result);
    }
    
    if (self.scanImgBlock) {
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.scanImgBlock(image);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}

- (UIImage *)generatQRImageForString:(NSString *)string imageSize:(CGFloat)size
{
    return [QRCodeGenerator qrImageForString:string imageSize:size];
}

#pragma mark - private method
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        x = rect.origin.x / readerViewBounds.size.height;
        y = rect.origin.y / readerViewBounds.size.width;
        width = rect.size.width / readerViewBounds.size.height;
        height = rect.size.height / readerViewBounds.size.width;
    }else {
        x = rect.origin.x / readerViewBounds.size.width;
        y = rect.origin.y / readerViewBounds.size.height;
        width = rect.size.width / readerViewBounds.size.width;
        height = rect.size.height / readerViewBounds.size.height;
    }
    
    return CGRectMake(x, y, width, height);
}


@end
