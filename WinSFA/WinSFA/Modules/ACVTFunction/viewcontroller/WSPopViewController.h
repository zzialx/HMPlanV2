//
//  WSAcvtPopViewController.h
//  WinSFA
//
//  Created by Stephanie on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@class WSPopViewController;

@protocol WSPopViewControllerDelegate <NSObject>

- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm;

@end

@interface WSPopViewController : WCBaseViewController

@property (nonatomic, strong, readonly) WCBaseViewController *contentViewController;

@property (nonatomic, strong)NSString *cancelButtonTitle;

@property (nonatomic, strong)NSString *confirmButtonTitle;

@property (nonatomic, assign)CGSize popViewSize;

@property (nonatomic, assign)SEL confirmSelector;

@property (nonatomic, weak)id<WSPopViewControllerDelegate> delegate;

- (instancetype)initWithContentViewController:(WCBaseViewController *)contentController;

- (void)setConfirmButtonEnable:(BOOL)enable;

- (void)setConfirmButtonHidden:(BOOL)hidden;

@end
