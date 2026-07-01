//
//  AddNewProductViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtViewController.h"

//@class NewProductBean;

@interface WSAddNewProductViewController : WSAcvtViewController

@property(nonatomic,strong)WSHTextField* textField ;


- (id)initWithFuncs:(WSFuncsBean *)aFuncs;
- (id)initWithFuncs:(WSFuncsBean *)aFuncs ProductInfoArray:(NSArray *)aArray;

@end


