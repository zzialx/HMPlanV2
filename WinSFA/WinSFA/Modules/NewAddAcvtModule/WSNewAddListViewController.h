//
//  WSNewAddListViewController.h
//  SKSHU
//
//  Created by heju on 14-4-10.
//  Copyright (c) 2014年 Com.Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WinSFA.h"
#import "WSNavigationBar.h"
#import "WSFacTable.h"
#import "SuperWorkSpaceViewController.h"
#import "WSBaseNewAcvtListViewController.h"

@interface WSNewAddListViewController : WSBaseNewAcvtListViewController

@property (nonatomic ,strong) WSAcvtBean *currentAcvtBen;
@property (nonatomic ,strong) NSMutableArray *serverceDisArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore withSubEmpId:(NSString *)subEmpId;

- (void)initializationBackItemAction;


@end
