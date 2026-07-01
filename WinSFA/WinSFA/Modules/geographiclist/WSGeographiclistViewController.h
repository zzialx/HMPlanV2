//
//  WCGeographiclistViewController.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/22/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"

@interface WSGeographiclistViewController : SuperWorkSpaceViewController

@property (nonatomic, strong)NSArray *iGeographicInfos;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (id)initWithFuncs:(WSFuncsBean *)funcs andGeographicinfos:(NSArray *)aInfos;

@end
