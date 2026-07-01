//
//  WCFetchOutplanStoreByGeographicViewController.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/22/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSAllStoresViewController.h"
#import "WSBaseGeographicInfo.h"
@interface WSFetchOutplanStoreByGeographicViewController : WSAllStoresViewController

@property (nonatomic, strong)WSBaseGeographicInfo *iBaseGeographicInfo;

- (id)initWithFuncs:(WSFuncsBean *)funcs andBaseGeographicInfo:(WSBaseGeographicInfo *)aInfo;

@end
