//
//  WSDVDataSourceFromStoreDicts.h
//  WinSFA
//
//  Created by zzialx on 2025/5/14.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSBaseDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSDVDataSourceFromStoreDicts : WSBaseDataSource

- (NSArray *)getDVDataSourceByFilter:(NSString *)filter andBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo;


@end

NS_ASSUME_NONNULL_END
