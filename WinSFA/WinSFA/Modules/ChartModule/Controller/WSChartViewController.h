//
//  WSChartViewController.h
//  WinSFA
//
//  Created by huzepei on 16/12/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "EaseMessageViewController.h"
#import "WSStoreBean.h"
/*
 *类说明：聊天页面VC
 */
@interface WSChartViewController : EaseMessageViewController

@property (nonatomic , strong) NSArray * imageUrlArray;
@property (nonatomic , assign) BOOL isParentShowNavgation; // 上级页面是否显示导航栏

@end
