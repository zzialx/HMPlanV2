//
//  InfoProdViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "SuperWorkSpaceViewController.h"

@interface WSInfoProdViewController : SuperWorkSpaceViewController <UITableViewDataSource, UITableViewDelegate>
{}
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) NSMutableArray    *dictBrandsArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
