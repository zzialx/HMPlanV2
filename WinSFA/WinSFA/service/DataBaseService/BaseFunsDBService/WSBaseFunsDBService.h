//
//  WSBaseFunsDBService.h
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseFunsDBService : WSDBService


- (NSString *)getFuncsIdWithCurrentFc:(NSString *)currentFc;

- (NSString *)getParentFuncsCode:(NSString *)currentFc;

- (NSString *)getFuncsNameWithFilter:(NSString *)filter;
- (NSString *)queryFuncsValueWithParamCol:(NSString *)col funcsBean:(WSFuncsBean *)aFuncsBean;

- (NSArray *)queryShortCutFuncs;
- (BOOL)isStoreFuncsWithFC:(NSString *)fc;
- (NSString *)getParentFCWithSonFC:(NSString *)fc;

@end
