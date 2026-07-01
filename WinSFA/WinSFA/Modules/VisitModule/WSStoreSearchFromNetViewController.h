//
//  StoreSearchFromNewViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSFuncsBean;

@interface WSStoreSearchFromNetViewController : UIViewController

@property (nonatomic, strong) NSDictionary *shouldAddFilters;

- (id)init;
- (id)initWithFuncs:(WSFuncsBean *)aFuns andFilter:(NSString *)aFilter;

@end
