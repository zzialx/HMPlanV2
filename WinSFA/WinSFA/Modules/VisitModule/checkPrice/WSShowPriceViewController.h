//
//  ShowPriceViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "WSDictBean.h"
#import "WSFptTable.h"
@interface WSShowPriceViewController : BaseViewController {}

@property (nonatomic, strong) WSDictBean *brand;
- (void)insertData;
@end
