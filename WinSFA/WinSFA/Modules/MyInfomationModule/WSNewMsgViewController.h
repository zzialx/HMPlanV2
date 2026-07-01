//
//  WSNewMsgViewController.h
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  WSFuncsBean;
@class  WSMsgBeanArray;
@class  WSMsgContentController;
@class  WSManuallyUploadViewController;

@interface WSNewMsgViewController : UIViewController
{
    NSMutableArray      *dataArray;
    WSFuncsBean           *funcsBean;
}

@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) WSFuncsBean             *funcsBean;
//@property (nonatomic, strong) WSManuallyUploadViewController* manuallyupload;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

-(void)initializationBackItemAction;


@end
