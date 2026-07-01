//
//  WSSignatureModule.h
//  WinSFA
//
//  Created by winchannel on 2017/6/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SignatureImageBlock)(UIImage *image, BOOL isCancel);

@interface WSSignatureModule : NSObject
    
@property (nonatomic,copy)SignatureImageBlock signatureImageBlock;
    + (WSSignatureModule *)getInstance;
    - (void)showSignatureVCWithParentVC:(UIViewController *)parentViewController andSignImage:(UIImage *)signImage withBlock:(SignatureImageBlock)aBlock;
@end
