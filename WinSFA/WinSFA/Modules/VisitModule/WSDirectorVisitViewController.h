//
//  DirectorVisitViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSFuncsBean;

@interface WSDirectorVisitViewController : UIViewController

@property (nonatomic, strong) NSDictionary *specialMenuFilterAccess;

// Init view controller by FuncsBean
- (id)initWithFuncs:(WSFuncsBean *)aFuncs;

@end


