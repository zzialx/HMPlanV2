//
//  WSStoreKPIViewController.h
//  WinSFA
//
//  Created by Alicia on 17/2/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kKPIViewHeight        75

@interface WSStoreKPIViewController : UIViewController

- (id)initWithFuncs:(WSFuncsBean *)currentFuncs acvtBean:(WSAcvtBean *)acvtBean store:(WSStoreBean *)currentStore;

@end
