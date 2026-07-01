//
//  WSMutiserieListViewController.h
//  WinSFA
//
//  Created by winchannel on 16/8/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"
#import "WSStoreBean.h"

#define VISIT_SUBSTORE_UPLOAD_NOTIFY    @"visitSubStoreUpload_notify"

@protocol WSMutiserieListViewControllerDelegate <NSObject>

- (void)resetStoreState:(NSArray *)stores withParentStore:(NSObject<I_W_Cell> *)parentStore;

@end

@interface WSMutiserieListViewController : BaseViewController



@property (nonatomic, strong)WSFuncsBean *parentFuncs;

@property (nonatomic, weak)id<WSMutiserieListViewControllerDelegate> delegate;


- (id)initWithStore:(WSStoreBean *)aStore withCurrentDate:(NSString *)currentDate withFilter:(NSString *)filter;

- (void)upload;

@end
