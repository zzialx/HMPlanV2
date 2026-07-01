//
//  WSEmbeddedNewAcvtViewController.h
//  WinSFA
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEmbeddedAcvtViewController.h"

@class WSEmbeddedNewAcvtViewController;

typedef void(^reloadHeaderTitleBlock)(NSString * headerTitle,WSEmbeddedNewAcvtViewController * vc);


@interface WSEmbeddedNewAcvtViewController : WSEmbeddedAcvtViewController

//刷新区头标题
@property(nonatomic,copy)reloadHeaderTitleBlock reloadHeaderTitleBlock;


@end
