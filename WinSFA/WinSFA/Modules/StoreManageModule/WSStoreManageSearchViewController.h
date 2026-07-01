//
//  WSStoreManageSearchViewController.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/13.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
@class WSStoresSearchDataInfoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol WSStoreManageSearchViewControllerDelegate <NSObject>

- (void)sotreDataInfoModel:(WSStoresSearchDataInfoModel*)storesSearchDataInfoModel;

@end

@interface WSStoreManageSearchViewController : SuperWorkSpaceViewController

@property (nonatomic, weak) id<WSStoreManageSearchViewControllerDelegate> storeManageDelegate;

@end

NS_ASSUME_NONNULL_END
