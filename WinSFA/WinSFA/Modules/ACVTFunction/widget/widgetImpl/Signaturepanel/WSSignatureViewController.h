//
//  WSSignatureViewController.h
//  WinSFA
//
//  Created by zhiqing on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"

@protocol WSSignatureViewControllerDelegate <NSObject>

-(void)saveImage:(UIImage *)image;

@optional
- (void)cacellSignature;

@end

@interface WSSignatureViewController : UIViewController
@property(nonatomic,strong) UIImage *signImage;
@property(nonatomic,weak) id delegate;
@end
