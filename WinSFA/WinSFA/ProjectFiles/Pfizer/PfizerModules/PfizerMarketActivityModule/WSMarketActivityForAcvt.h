//
//  WCMarketActivityForAcvt.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/20/13.
//
//

#import "WSAcvtViewController.h"

@class WSAcvtBean;
@class WSFuncsBean;
@class WSStoreBean;

@interface WSMarketActivityForAcvt : WSAcvtViewController

- (id)initWithAcvt:(WSAcvtBean *)anAcvt Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

@end
