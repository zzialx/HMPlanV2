//
//  WSPersonnalImageViewController.h
//  WinSFA
//
//  Created by winchannel on 2017/5/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@class WSWidget;

typedef void(^ImageIDsBlock)(NSString *imageID);

@interface WSPersonnalImageViewController : WCBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, copy) ImageIDsBlock imageIDsBlock;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic,strong) UIAlertController * alartVC;

- (id)initWithImageID:(NSString *)imageIDStr;

- (void)showPersonnalImageControllerToViewController:(UIViewController *)parentViewController
                                           withBlock:(ImageIDsBlock)aBlock;
@end
