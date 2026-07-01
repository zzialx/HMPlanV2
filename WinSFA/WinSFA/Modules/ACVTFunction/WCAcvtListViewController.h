//
//  WCAcvtListViewController.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 12/11/12.
//
//

#import "WSAcvtListViewController.h"
#import "WSFuncsBean.h"
#import "WCBaseViewController.h"

#import "WSAcvtBeanArray.h"

@interface WCAcvtListViewController : WCBaseViewController

@property(nonatomic,strong)WSFuncsBean *currentFunc;
@property(nonatomic,strong)NSMutableArray *acvtArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
