//
//  WSRouteStoreListViewController.h
//  WinSFA
//
//  Created by admin on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSRouteStoreListViewController : SuperWorkSpaceViewController

@property (nonatomic, copy) NSString *docDate;          //日期
@property (nonatomic, copy) NSString *selectRouteId;    //路线id
@property (nonatomic, assign) BOOL isRequestStoreList;  //是否实时请求门店数据

@end

NS_ASSUME_NONNULL_END
