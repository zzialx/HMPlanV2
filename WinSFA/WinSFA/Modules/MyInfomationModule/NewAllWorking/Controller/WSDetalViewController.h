//
//  WSDetalViewController
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCDownLoadingAndShowingImageView.h"
#import "WSMsgContentMediaView.h"
#import "WSServiceDispatcher.h"
#import "WCBaseViewController.h"


@class WSMsgsBean_msg,RevertArrayModel ;


@interface WSDetalViewController : WCBaseViewController<WCBaseViewControllerDelegate>

@property(nonatomic,strong) WSMsgsBean_msg * model;
@property(nonatomic,assign) NSInteger revertCount;
@property(nonatomic,strong) NSString* srid;


// 存储 模型数组
@property(nonatomic,strong) NSMutableArray * revertArray;

// 存储回复后的模型数组(待考虑)
@property(nonatomic,strong)NSMutableArray * afterArray;

@property(nonatomic,strong) NSMutableArray * msgBean;
@property (nonatomic, assign) float height;
@property (nonatomic, strong) NSMutableDictionary *mediaDic;

@property (nonatomic, strong) NSString *msgIDFromWebView;

@property (nonatomic, assign) BOOL isHomePageShow;

//是否是轮播跳转过来的
@property (nonatomic, assign) BOOL isTopBanner;

@end
