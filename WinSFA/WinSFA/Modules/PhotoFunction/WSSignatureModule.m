//
//  WSSignatureModule.m
//  WinSFA
//
//  Created by winchannel on 2017/6/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSignatureModule.h"
#import "WSSignatureViewController.h"

@interface WSSignatureModule ()<WSSignatureViewControllerDelegate>

@end

@implementation WSSignatureModule
+ (WSSignatureModule *)getInstance{
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)showSignatureVCWithParentVC:(UIViewController *)parentViewController andSignImage:(UIImage *)signImage withBlock:(SignatureImageBlock)aBlock{
    
    WSSignatureViewController * ctrl = [[WSSignatureViewController alloc]init];
    ctrl.signImage = signImage;
    ctrl.delegate = self;
    [parentViewController presentViewController:ctrl animated:YES completion:nil];
        
    self.signatureImageBlock = aBlock;
}
-(void)saveImage:(UIImage *)image{
    
    self.signatureImageBlock(image, NO);
    
}
- (void)cacellSignature{

    self.signatureImageBlock(nil, YES);
}
@end
