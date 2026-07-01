//
//  AddressSelectViewController.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAcvtViewController.h"

@class WSAddressSelectViewController;

@protocol WSAddressSelectDelegate <NSObject>

@optional
- (void)addressSelected:(WSAddressSelectViewController *)addressSelect resultDic:(NSDictionary *)dic;

@end

@interface WSAddressSelectViewController : WCBaseViewController

//@property (nonatomic, strong) WSAcvtViewController *acvtVC;
@property (nonatomic, copy) NSString *preAddress;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, weak) id<WSAddressSelectDelegate> addressSelectDelegate;

- (id)initWithPreInfoDic:(NSDictionary *)infoDic;

@end
