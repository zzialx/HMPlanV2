//
//  ReasonViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WSFuncsBean.h"
#import "WSStoreBean.h"

@interface WSReasonViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
{}

@property (nonatomic, strong) NSMutableArray *myArray;
- (id)initWithArray:(NSArray *)array Funcs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

@end
